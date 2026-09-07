import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/ride.dart';
import '../../domain/entities/route_stop.dart';
import '../../domain/repositories/ride_repository.dart';
import '../models/ride_model.dart';
import '../models/route_stop_model.dart';

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return SupabaseRideRepository();
});

class SupabaseRideRepository implements RideRepository {
  static const _routesTable = 'routes';
  static const _stopsTable = 'route_stops';

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

    return routeRows
        .map((row) => RideModel.fromJson(row, via: viaByRouteId[row['id']]))
        .toList(growable: false);
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
}
