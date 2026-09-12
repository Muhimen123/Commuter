import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/supabase_ride_repository.dart';
import 'entities/review.dart';
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

final allRouteStopsProvider =
    FutureProvider<Map<String, List<RouteStop>>>((ref) {
  final repository = ref.watch(rideRepositoryProvider);
  return repository.getAllRouteStops();
});

final reviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, routeId) {
  final repository = ref.watch(rideRepositoryProvider);
  return repository.getReviews(routeId);
});
