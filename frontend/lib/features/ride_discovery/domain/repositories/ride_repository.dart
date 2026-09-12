import '../entities/review.dart';
import '../entities/ride.dart';
import '../entities/route_stop.dart';

abstract class RideRepository {
  Future<List<Ride>> getRides();

  Future<List<RouteStop>> getRouteStops(String routeId);

  Future<Map<String, List<RouteStop>>> getAllRouteStops();

  Future<List<Review>> getReviews(String routeId);
}
