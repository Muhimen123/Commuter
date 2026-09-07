import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:frontend/features/map/domain/entities/journey_leg.dart';
import 'package:frontend/features/map/domain/transit_planner.dart';
import 'package:frontend/features/ride_discovery/domain/rides_provider.dart';

/// Origin/destination pair keyed by value, so the provider family caches a
/// plan instead of recomputing it every time the dialog rebuilds.
class TransitPlanRequest {
  final LatLng origin;
  final LatLng destination;

  const TransitPlanRequest({required this.origin, required this.destination});

  @override
  bool operator ==(Object other) =>
      other is TransitPlanRequest &&
      other.origin == origin &&
      other.destination == destination;

  @override
  int get hashCode => Object.hash(origin, destination);
}

/// Walk + ride itineraries between the two points of [request], best first.
///
/// The rides and the stop network are fetched once and shared; only the graph
/// search reruns per request.
final transitPlanProvider = FutureProvider.family<List<TransitItinerary>,
    TransitPlanRequest>((ref, request) async {
  final rides = await ref.watch(ridesProvider.future);
  final stopsByRoute = await ref.watch(allRouteStopsProvider.future);

  final planner = TransitPlanner.fromRides(
    rides: rides,
    stopsByRoute: stopsByRoute,
  );

  return planner.plan(
    origin: request.origin,
    destination: request.destination,
  );
});
