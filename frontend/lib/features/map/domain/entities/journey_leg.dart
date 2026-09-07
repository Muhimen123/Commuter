import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';
import 'package:frontend/features/ride_discovery/domain/entities/route_stop.dart';

/// One step of a planned transit itinerary — either walking or riding.
sealed class JourneyLeg {
  const JourneyLeg();

  /// The geometry of this leg, for drawing on the map.
  List<LatLng> get points;

  /// Straight-line length of this leg in metres.
  double get distanceMeters;
}

/// A stretch the commuter covers on foot: to the first stop, between two
/// stops when transferring, or from the last stop to the destination.
class WalkLeg extends JourneyLeg {
  final LatLng from;
  final LatLng to;

  @override
  final double distanceMeters;

  /// Name of the stop being walked to, when the walk ends at one. Null for
  /// the final walk to the searched destination.
  final String? toStopName;

  const WalkLeg({
    required this.from,
    required this.to,
    required this.distanceMeters,
    this.toStopName,
  });

  @override
  List<LatLng> get points => [from, to];
}

/// A stretch covered on one route, from [boardStop] to [alightStop].
class RideLeg extends JourneyLeg {
  final Ride ride;
  final RouteStop boardStop;
  final RouteStop alightStop;

  /// The stops passed through between board and alight, in travel order.
  /// Empty when the two stops are adjacent on the route.
  final List<RouteStop> viaStops;

  @override
  final double distanceMeters;

  const RideLeg({
    required this.ride,
    required this.boardStop,
    required this.alightStop,
    required this.viaStops,
    required this.distanceMeters,
  });

  /// Number of stops travelled, i.e. how many times the vehicle pulls in
  /// before the commuter gets off.
  int get stopCount => viaStops.length + 1;

  @override
  List<LatLng> get points => [
        LatLng(boardStop.latitude, boardStop.longitude),
        for (final stop in viaStops) LatLng(stop.latitude, stop.longitude),
        LatLng(alightStop.latitude, alightStop.longitude),
      ];
}

/// A complete origin-to-destination plan: an ordered list of walk and ride
/// legs, plus the totals shown in the UI.
class TransitItinerary {
  final List<JourneyLeg> legs;

  const TransitItinerary({required this.legs});

  Iterable<RideLeg> get rideLegs => legs.whereType<RideLeg>();

  Iterable<WalkLeg> get walkLegs => legs.whereType<WalkLeg>();

  int get rideCount => rideLegs.length;

  double get totalWalkMeters =>
      walkLegs.fold(0, (sum, leg) => sum + leg.distanceMeters);

  double get totalRideMeters =>
      rideLegs.fold(0, (sum, leg) => sum + leg.distanceMeters);

  /// Sum of the average fares of the rides taken. Rides with no recorded
  /// fare contribute 0 rather than making the total unknown.
  double get totalFare => rideLegs.fold(0, (sum, leg) => sum + leg.ride.fare);

  /// The whole itinerary as one list of points, for fitting the camera.
  List<LatLng> get points => [for (final leg in legs) ...leg.points];

  /// Identity of this itinerary as a sequence of route ids, used to drop
  /// duplicate options that differ only in where they start walking.
  String get routeSignature => rideLegs.map((leg) => leg.ride.id).join('>');
}
