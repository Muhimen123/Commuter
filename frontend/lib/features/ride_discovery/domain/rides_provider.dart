import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/supabase_ride_repository.dart';
import 'entities/ride.dart';
import 'entities/route_stop.dart';

final ridesProvider = FutureProvider<List<Ride>>((ref) {
  final repository = ref.watch(rideRepositoryProvider);
  return repository.getRides();
});

final routeStopsProvider =
    FutureProvider.family<List<RouteStop>, String>((ref, routeId) {
  final repository = ref.watch(rideRepositoryProvider);
  return repository.getRouteStops(routeId);
});

/// The whole stop network, grouped by route id — the input to the transit
/// itinerary planner. Cached for the app's lifetime; stop lists change far
/// less often than a session lasts.
final allRouteStopsProvider =
    FutureProvider<Map<String, List<RouteStop>>>((ref) {
  final repository = ref.watch(rideRepositoryProvider);
  return repository.getAllRouteStops();
});
