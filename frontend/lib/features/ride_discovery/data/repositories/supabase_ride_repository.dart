import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/review.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/route_stop.dart';
import '../../domain/repositories/ride_repository.dart';
import '../models/review_model.dart';
import '../models/ride_model.dart';
import '../models/route_stop_model.dart';

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return SupabaseRideRepository();
});

class SupabaseRideRepository implements RideRepository {
  static const _routesTable = 'routes';
  static const _stopsTable = 'route_stops';
  static const _surveysTable = 'post_ride_surveys';

  final SupabaseClient _client;

  SupabaseRideRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Ride>> getRides() async {
    final routeRows = await _client
        .from(_routesTable)
        .select()
        .order('route_number', ascending: true);

    if (routeRows.isEmpty) return const [];

    final routeIds = routeRows.map((row) => row['id'] as String).toList();
    final stopRows = await _client
        .from(_stopsTable)
        .select()
        .inFilter('route_id', routeIds)
        .order('sequence_order', ascending: true);

    final viaByRouteId = <String, String>{};
    for (final row in stopRows) {
      final routeId = row['route_id'] as String;
      if (viaByRouteId.containsKey(routeId)) continue;
      if ((row['sequence_order'] as int) < 2) continue;
      viaByRouteId[routeId] = row['stop_name'] as String;
    }

    final ratingSummaries = await _ratingSummaries(routeIds);

    return routeRows
        .map((row) => RideModel.fromJson(
              row,
              via: viaByRouteId[row['id']],
              ratingSummary: ratingSummaries[row['id']],
            ))
        .toList(growable: false);
  }

  Future<Map<String, (double, int)>> _ratingSummaries(List<String> routeIds) async {
    if (routeIds.isEmpty) return const {};

    final rows = await _client
        .from(_surveysTable)
        .select('ride_rating, journeys!inner(route_id, status)')
        .eq('journeys.status', 'completed')
        .not('ride_rating', 'is', null)
        .inFilter('journeys.route_id', routeIds);

    final totalsByRouteId = <String, double>{};
    final countsByRouteId = <String, int>{};
    for (final row in rows) {
      final journey = row['journeys'] as Map<String, dynamic>;
      final routeId = journey['route_id'] as String;
      final rating = (row['ride_rating'] as num).toDouble();
      totalsByRouteId.update(routeId, (total) => total + rating, ifAbsent: () => rating);
      countsByRouteId.update(routeId, (count) => count + 1, ifAbsent: () => 1);
    }

    return {
      for (final routeId in countsByRouteId.keys)
        routeId: (totalsByRouteId[routeId]! / countsByRouteId[routeId]!, countsByRouteId[routeId]!),
    };
  }

  @override
  Future<List<RouteStop>> getRouteStops(String routeId) async {
    final rows = await _client
        .from(_stopsTable)
        .select()
        .eq('route_id', routeId)
        .order('sequence_order', ascending: true);

    return rows
        .map((row) => RouteStopModel.fromJson(row))
        .toList(growable: false);
  }

  @override
  Future<Map<String, List<RouteStop>>> getAllRouteStops() async {
    final rows = await _client
        .from(_stopsTable)
        .select()
        .order('route_id', ascending: true)
        .order('sequence_order', ascending: true);

    final byRouteId = <String, List<RouteStop>>{};
    for (final row in rows) {
      final routeId = row['route_id'] as String;
      byRouteId
          .putIfAbsent(routeId, () => <RouteStop>[])
          .add(RouteStopModel.fromJson(row));
    }
    return byRouteId;
  }

  @override
  Future<List<Review>> getReviews(String routeId) async {
    final rows = await _client
        .from(_surveysTable)
        .select('*, journeys!inner(route_id, status, users(full_name))')
        .eq('journeys.route_id', routeId)
        .eq('journeys.status', 'completed')
        .not('ride_rating', 'is', null)
        .order('created_at', ascending: false);

    return rows
        .map((row) => ReviewModel.fromJson(row))
        .toList(growable: false);
  }
}
