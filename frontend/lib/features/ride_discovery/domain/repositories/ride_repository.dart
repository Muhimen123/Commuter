import '../entities/ride.dart';

abstract class RideRepository {
  Future<List<Ride>> getRides();
}
