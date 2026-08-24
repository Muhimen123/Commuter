import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';
import 'package:geolocator/geolocator.dart';

import '../data/repositories/supabase_journey_repository.dart';
import 'entities/journey.dart';
import 'entities/journey_stop.dart';
import 'journey_state.dart';
import 'repositories/journey_repository.dart';

const String kDevUserId = '00000000-0000-0000-0000-000000000001';

final journeyProvider =
    NotifierProvider<JourneyNotifier, JourneyState>(JourneyNotifier.new);

class JourneyNotifier extends Notifier<JourneyState> {
  static const _pingInterval = Duration(seconds: 15);

  late final JourneyRepository _repository;
  Timer? _pingTimer;

  @override
  JourneyState build() {
    _repository = ref.read(journeyRepositoryProvider);
    ref.onDispose(_stopPingTimer);
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
      if (active != null) _startPingTimer();
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
      _startPingTimer();
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
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _repository.recordPing(
        journeyId: journey.id,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      // Best-effort: a missed ping must not disrupt the journey.
    }
  }
}
