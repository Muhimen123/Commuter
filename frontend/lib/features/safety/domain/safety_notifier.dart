import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';

class SafetyAlert {
  final String id;
  final String userId;
  final String senderName;
  final double? latitude;
  final double? longitude;
  final DateTime triggeredAt;

  SafetyAlert({
    required this.id,
    required this.userId,
    required this.senderName,
    this.latitude,
    this.longitude,
    required this.triggeredAt,
  });

  factory SafetyAlert.fromMap(Map<String, dynamic> map, String senderName) {
    return SafetyAlert(
      id: map['id'],
      userId: map['user_id'],
      senderName: senderName,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      triggeredAt: DateTime.parse(map['triggered_at']),
    );
  }
}

class SafetyNotifier extends StateNotifier<SafetyAlert?> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Ref _ref;
  RealtimeChannel? _subscription;

  SafetyNotifier(this._ref) : super(null) {
    _initAlertListener();
  }

  /// Listens for SOS alerts from people who have added current user as guardian
  void _initAlertListener() {
    final userId = _ref.read(authProvider).valueOrNull?.id;
    if (userId == null) return;

    _subscription = _supabase
        .channel('safety_alerts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'safety_alerts',
          callback: (payload) async {
            final alertData = payload.newRecord;
            final senderId = alertData['user_id'];
            
            // Fetch sender name
            final userRes = await _supabase
                .from('users')
                .select('full_name')
                .eq('id', senderId)
                .single();
            
            state = SafetyAlert.fromMap(alertData, userRes['full_name']);
          },
        )
        .subscribe();
  }

  Future<void> triggerSOS() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      await _supabase.rpc('trigger_sos', params: {
        'p_lat': position.latitude,
        'p_lng': position.longitude,
      });
    } catch (e) {
      debugPrint('SOS Trigger Failed: $e');
    }
  }

  void dismissAlert() {
    state = null;
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}

final safetyAlertProvider = StateNotifierProvider<SafetyNotifier, SafetyAlert?>((ref) {
  return SafetyNotifier(ref);
});
