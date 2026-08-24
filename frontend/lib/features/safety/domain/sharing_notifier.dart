import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'shared_location.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../journey/domain/journey_notifier.dart';

class SharingState {
  final List<SharedLocation> sharedWithMe;
  final List<Map<String, dynamic>> myActiveShares;
  final bool isLoading;
  final String? error;

  SharingState({
    this.sharedWithMe = const [],
    this.myActiveShares = const [],
    this.isLoading = false,
    this.error,
  });

  SharingState copyWith({
    List<SharedLocation>? sharedWithMe,
    List<Map<String, dynamic>>? myActiveShares,
    bool? isLoading,
    String? error,
  }) {
    return SharingState(
      sharedWithMe: sharedWithMe ?? this.sharedWithMe,
      myActiveShares: myActiveShares ?? this.myActiveShares,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SharingNotifier extends StateNotifier<SharingState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Ref _ref;
  StreamSubscription<Position>? _positionSubscription;

  SharingNotifier(this._ref) : super(SharingState()) {
    // Initial load
    refresh();
    
    // Auto-refresh "Shared With Me" every 30 seconds for live updates
    Timer.periodic(const Duration(seconds: 30), (_) => loadSharedWithMe());
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.wait([
      loadSharedWithMe(),
      loadMyActiveShares(),
    ]);
    state = state.copyWith(isLoading: false);
  }

  /// Fetches people sharing their location WITH the current user (Guardian View)
  Future<void> loadSharedWithMe() async {
    try {
      final data = await _supabase
          .from('active_shares_with_me')
          .select();
      
      final locations = (data as List)
          .map((m) => SharedLocation.fromMap(m))
          .toList();
          
      state = state.copyWith(sharedWithMe: locations);
    } catch (e) {
      debugPrint('Error loading shared with me: $e');
    }
  }

  /// Fetches sharing sessions initiated BY the current user
  Future<void> loadMyActiveShares() async {
    final userId = _ref.read(authProvider).user?.id;
    if (userId == null) return;

    try {
      final data = await _supabase
          .from('location_shares')
          .select('*, trusted_contacts(contact_name)')
          .eq('sharer_user_id', userId)
          .eq('is_active', true);
          
      state = state.copyWith(myActiveShares: List<Map<String, dynamic>>.from(data));
      
      // If we have active shares, ensure GPS pings are running
      if (data.isNotEmpty) {
        _startLocationPings();
      } else {
        _stopLocationPings();
      }
    } catch (e) {
      debugPrint('Error loading my shares: $e');
    }
  }

  /// Starts sharing with a contact
  Future<void> startSharing({
    required String contactId,
    String? recipientUserId,
  }) async {
    final userId = _ref.read(authProvider).user?.id;
    if (userId == null) return;

    final journeyId = _ref.read(journeyProvider).activeJourney?.id;

    try {
      await _supabase.rpc('start_sharing_location', params: {
        'p_sharer_user_id': userId,
        'p_journey_id': journeyId,
        'p_recipient_user_id': recipientUserId,
        'p_trusted_contact_id': contactId,
      });
      
      await loadMyActiveShares();
    } catch (e) {
      state = state.copyWith(error: 'Failed to start sharing');
    }
  }

  /// Stops a specific sharing session
  Future<void> stopSharing(String shareId) async {
    try {
      await _supabase.rpc('stop_sharing_location', params: {
        'p_share_id': shareId,
      });
      await loadMyActiveShares();
    } catch (e) {
      state = state.copyWith(error: 'Failed to stop sharing');
    }
  }

  /// Periodically sends GPS coordinates to Supabase
  void _startLocationPings() {
    if (_positionSubscription != null) return;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Ping every 10 meters
      ),
    ).listen((position) async {
      final userId = _ref.read(authProvider).user?.id;
      final journeyId = _ref.read(journeyProvider).activeJourney?.id;
      
      if (userId == null) return;

      try {
        await _supabase.from('journey_location_pings').insert({
          'user_id': userId,
          'journey_id': journeyId,
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      } catch (e) {
        debugPrint('Ping failed: $e');
      }
    });
  }

  void _stopLocationPings() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  void dispose() {
    _stopLocationPings();
    super.dispose();
  }
}

final sharingProvider = StateNotifierProvider<SharingNotifier, SharingState>((ref) {
  return SharingNotifier(ref);
});
