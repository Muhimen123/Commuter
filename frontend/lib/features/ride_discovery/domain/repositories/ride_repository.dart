import '../entities/ride.dart';
import '../entities/route_stop.dart';

abstract class RideRepository {
  Future<List<Ride>> getRides();

  Future<List<RouteStop>> getRouteStops(String routeId);

  /// Every stop of every route, grouped by `route_id` and ordered by
  /// `sequence_order` within each group.
  ///
  /// One query for the whole network — the itinerary planner needs the full
  /// stop graph, and fetching it per-route would be N round-trips.
  Future<Map<String, List<RouteStop>>> getAllRouteStops();
}
