import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';
import 'package:frontend/shared/utils/polyline_codec.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/repositories/supabase_journey_repository.dart';
import 'entities/journey.dart';
import 'entities/journey_stop.dart';
import 'journey_state.dart';
import 'repositories/journey_repository.dart';
import 'ride_simulator.dart';
import 'simulation_provider.dart';

const String kDevUserId = '00000000-0000-0000-0000-000000000001';

final journeyProvider =
    NotifierProvider<JourneyNotifier, JourneyState>(JourneyNotifier.new);

class JourneyNotifier extends Notifier<JourneyState> {
  static const _pingInterval = Duration(seconds: 15);

  late final JourneyRepository _repository;
  Timer? _pingTimer;

  // Route points for the active journey, used only to drive [RideSimulator]
  // — kept in memory, never sent to the backend as-is (only the resulting
  // simulated pings are).
  List<LatLng>? _routePoints;
  RideSimulator? _simulator;

  @override
  JourneyState build() {
    _repository = ref.read(journeyRepositoryProvider);
    ref.onDispose(_teardown);
    ref.listen<bool>(simulationEnabledProvider, (_, _) => _syncSimulator());
    return const JourneyState();
  }

  String get _currentUserId =>
      ref.read(authProvider).valueOrNull?.id ?? kDevUserId;

  Future<Journey?> resume() async {
    if (state.hasActiveJourney) return state.activeJourney;
    state = state.copyWith(isResuming: true, clearError: true);
    try {
      final active = await _repository.getActiveJourney(
        userId: _currentUserId,
      );
      state = active == null
          ? const JourneyState()
          : state.copyWith(activeJourney: active, isResuming: false);
      if (active != null) {
        _routePoints = active.routePolyline != null
            ? decodePolyline(active.routePolyline!)
            : null;
        _startPingTimer();
        _syncSimulator();
      }
      return active;
    } catch (e) {
      state = state.copyWith(isResuming: false, error: e.toString());
      return null;
    }
  }

  Future<Journey?> startJourney({
    String? routeId,
    String? originName,
    String? originPlaceId,
    required double originLatitude,
    required double originLongitude,
    String? destinationName,
    String? destinationPlaceId,
    double? destinationLatitude,
    double? destinationLongitude,
    String? routePolyline,
    double? distanceKm,
    bool liveTrackingEnabled = true,
    List<LatLng>? routePoints,
  }) async {
    state = state.copyWith(isStarting: true, clearError: true);
    try {
      final journey = await _repository.startJourney(
        userId: _currentUserId,
        routeId: routeId,
        originName: originName,
        originPlaceId: originPlaceId,
        originLatitude: originLatitude,
        originLongitude: originLongitude,
        destinationName: destinationName,
        destinationPlaceId: destinationPlaceId,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
        routePolyline: routePolyline,
        distanceKm: distanceKm,
        liveTrackingEnabled: liveTrackingEnabled,
      );
      state = state.copyWith(activeJourney: journey, isStarting: false);
      _routePoints = routePoints != null && routePoints.length >= 2
          ? routePoints
          : (routePolyline != null ? decodePolyline(routePolyline) : null);
      _startPingTimer();
      _syncSimulator();
      return journey;
    } catch (e, st) {
      debugPrint('startJourney failed: $e\n$st');
      state = state.copyWith(isStarting: false, error: e.toString());
      return null;
    }
  }

  Future<JourneyStop?> addStop({
    String? stopName,
    required double latitude,
    required double longitude,
  }) async {
    final journey = state.activeJourney;
    if (journey == null) return null;
    state = state.copyWith(isAddingStop: true, clearError: true);
    try {
      final stop = await _repository.addStop(
        journeyId: journey.id,
        stopName: stopName,
        latitude: latitude,
        longitude: longitude,
      );
      final updated = journey.copyWith(stops: [...journey.stops, stop]);
      state = state.copyWith(activeJourney: updated, isAddingStop: false);
      return stop;
    } catch (e) {
      state = state.copyWith(isAddingStop: false, error: e.toString());
      return null;
    }
  }

  Future<bool> endJourney() async {
    final journeyId = state.activeJourney?.id;
    if (journeyId == null) return false;
    state = state.copyWith(isEnding: true, clearError: true);
    try {
      await _repository.finishJourney(journeyId: journeyId);
      _stopPingTimer();
      _stopSimulator();
      state = const JourneyState();
      return true;
    } catch (e) {
      state = state.copyWith(isEnding: false, error: e.toString());
      return false;
    }
  }

  Future<bool> cancelJourney() async {
    final journeyId = state.activeJourney?.id;
    if (journeyId == null) return false;
    state = state.copyWith(isCancelling: true, clearError: true);
    try {
      await _repository.cancelJourney(journeyId: journeyId);
      _stopPingTimer();
      _stopSimulator();
      state = const JourneyState();
      return true;
    } catch (e) {
      state = state.copyWith(isCancelling: false, error: e.toString());
      return false;
    }
  }

  Future<bool> submitSurvey({
    required int fare,
    required int rating,
    required String safetyRating,
    required bool isStudentFare,
    required String feedback,
  }) async {
    final journeyId = state.activeJourney?.id;
    if (journeyId == null) return false;
    state = state.copyWith(isSubmittingSurvey: true, clearError: true);
    try {
      await _repository.submitSurvey(
        journeyId: journeyId,
        farePaid: fare.toDouble(),
        fareType: isStudentFare ? 'student' : 'regular',
        rideRating: rating.toDouble(),
        safetyRating: _safetyStringToRating(safetyRating),
        feedbackText: feedback,
      );
      state = state.copyWith(isSubmittingSurvey: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmittingSurvey: false, error: e.toString());
      return false;
    }
  }

  double _safetyStringToRating(String value) {
    return switch (value) {
      'Safe & Professional' => 5.0,
      'Neutral' => 3.0,
      'Reckless / Unsafe' => 1.0,
      _ => 3.0,
    };
  }

  void clearError() => state = state.copyWith(clearError: true);

  void _startPingTimer() {
    _stopPingTimer();
    final journey = state.activeJourney;
    if (journey == null || !journey.liveTrackingEnabled) return;
    _pingTimer = Timer.periodic(_pingInterval, (_) => _recordPing());
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  Future<void> _recordPing() async {
    final journey = state.activeJourney;
    if (journey == null || !journey.isActive) return;
    try {
      final coords = await _currentCoordinates();
      if (coords == null) return;
      await _repository.recordPing(
        journeyId: journey.id,
        latitude: coords.latitude,
        longitude: coords.longitude,
      );
    } catch (_) {
      // Best-effort: a missed ping must not disrupt the journey.
    }
  }

  /// Resolves the coordinates to ping: the [RideSimulator]'s current point
  /// when simulation is driving this journey, otherwise real device GPS.
  Future<LatLng?> _currentCoordinates() async {
    final simulator = _simulator;
    if (simulator != null) return simulator.position.value;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }

  /// Starts, stops, or leaves the [RideSimulator] alone so it matches
  /// whether simulation is enabled for the current active journey. Safe to
  /// call any time state that affects this changes (journey started/resumed,
  /// simulation toggled).
  void _syncSimulator() {
    final journey = state.activeJourney;
    final shouldSimulate = journey != null &&
        journey.isActive &&
        journey.liveTrackingEnabled &&
        ref.read(simulationEnabledProvider) &&
        (_routePoints?.length ?? 0) >= 2;

    if (!shouldSimulate) {
      _stopSimulator();
      return;
    }
    if (_simulator != null) return; // already simulating this route

    final simulator = RideSimulator(route: _routePoints!);
    simulator.position.addListener(() {
      state = state.copyWith(simulatedPosition: simulator.position.value);
    });
    _simulator = simulator;
    state = state.copyWith(simulatedPosition: simulator.position.value);
    simulator.start();
  }

  void _stopSimulator() {
    _simulator?.dispose();
    _simulator = null;
    if (state.simulatedPosition != null) {
      state = state.copyWith(clearSimulatedPosition: true);
    }
  }

  void _teardown() {
    _stopPingTimer();
    _stopSimulator();
  }
}
