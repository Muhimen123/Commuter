import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/journey.dart';
import '../../domain/entities/journey_stop.dart';
import '../../domain/repositories/journey_repository.dart';
import '../models/journey_model.dart';
import '../models/journey_stop_model.dart';

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  return SupabaseJourneyRepository();
});

class SupabaseJourneyRepository implements JourneyRepository {
  static const _journeysTable = 'journeys';
  static const _stopsTable = 'journey_stops';
  static const _pingsTable = 'journey_location_pings';

  final SupabaseClient _client;

  SupabaseJourneyRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Journey> startJourney({
    required String userId,
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
    final payload = <String, dynamic>{
      'user_id': userId,
      'route_id': routeId,
      'origin_name': originName,
      'origin_place_id': originPlaceId,
      'origin_latitude': originLatitude,
      'origin_longitude': originLongitude,
      'destination_name': destinationName,
      'destination_place_id': destinationPlaceId,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'route_polyline': routePolyline,
      'live_tracking_enabled': liveTrackingEnabled,
      'distance_km': distanceKm,
    };

    final row = await _client
        .from(_journeysTable)
        .insert(payload)
        .select()
        .single();

    return JourneyModel.fromJson(row);
  }

  @override
  Future<JourneyStop> addStop({
    required String journeyId,
    String? stopName,
    required double latitude,
    required double longitude,
  }) async {
    final row = await _client.rpc('add_journey_stop', params: {
      'p_journey_id': journeyId,
      'p_stop_name': stopName,
      'p_latitude': latitude,
      'p_longitude': longitude,
    });

    return JourneyStopModel.fromJson(row as Map<String, dynamic>);
  }

  @override
  Future<void> recordPing({
    required String journeyId,
    required double latitude,
    required double longitude,
  }) async {
    await _client.from(_pingsTable).insert({
      'journey_id': journeyId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  @override
  Future<Journey> finishJourney({required String journeyId}) async {
    final row = await _client.rpc('finish_journey', params: {
      'p_journey_id': journeyId,
    });

    return JourneyModel.fromJson(row as Map<String, dynamic>);
  }

  @override
  Future<Journey> cancelJourney({required String journeyId}) async {
    final row = await _client
        .from(_journeysTable)
        .update({
          'status': 'cancelled',
          'ended_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', journeyId)
        .select()
        .single();

    return JourneyModel.fromJson(row);
  }

  @override
  Future<Journey?> getActiveJourney({required String userId}) async {
    final rows = await _client
        .from(_journeysTable)
        .select()
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('started_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;

    final journey = JourneyModel.fromJson(rows.first);
    final stops = await getStops(journeyId: journey.id);
    return journey.copyWith(stops: stops);
  }

  @override
  Future<List<JourneyStop>> getStops({required String journeyId}) async {
    final rows = await _client
        .from(_stopsTable)
        .select()
        .eq('journey_id', journeyId)
        .order('sequence_order', ascending: true);

    return rows
        .map((row) => JourneyStopModel.fromJson(row))
        .toList(growable: false);
  }

  @override
  Future<List<Journey>> getHistory({required String userId}) async {
    final rows = await _client
        .from(_journeysTable)
        .select()
        .eq('user_id', userId)
        .inFilter('status', const ['completed', 'cancelled'])
        .order('started_at', ascending: false);

    return rows
        .map((row) => JourneyModel.fromJson(row))
        .toList(growable: false);
  }
}
