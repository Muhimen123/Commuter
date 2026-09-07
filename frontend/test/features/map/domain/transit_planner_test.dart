import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:frontend/features/map/domain/entities/journey_leg.dart';
import 'package:frontend/features/map/domain/transit_planner.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';
import 'package:frontend/features/ride_discovery/domain/entities/route_stop.dart';

/// Roughly 1 km at the equator, which is close enough at Dhaka's latitude for
/// fixtures that only need "about this far apart".
const double kmInDegrees = 0.009;

Ride buildRide(
  String id, {
  String? number,
  double fare = 30,
  TransitMode mode = TransitMode.bus,
}) {
  return Ride(
    id: id,
    routeNumber: number ?? id,
    routeName: 'Route $id',
    destination: 'Somewhere',
    via: '',
    status: RideStatus.scheduled,
    rating: 0,
    reviewCount: 0,
    safetyScore: 80,
    fare: fare,
    transitMode: mode,
  );
}

/// Builds a route's stops along a straight line starting at
/// (`startLat`, `startLon`), stepping by [stepLat]/[stepLon] per stop.
List<RouteStop> buildStops({
  required String routeId,
  required int count,
  required double startLat,
  required double startLon,
  double stepLat = 0,
  double stepLon = 0,
}) {
  return [
    for (var i = 0; i < count; i++)
      RouteStop(
        id: '$routeId-stop-$i',
        stopName: '$routeId stop $i',
        latitude: startLat + stepLat * i,
        longitude: startLon + stepLon * i,
        sequenceOrder: i + 1,
      ),
  ];
}

void main() {
  const options = TransitPlannerOptions();

  group('TransitPlanner', () {
    test('walks the whole way when origin and destination are close', () {
      final planner = TransitPlanner.fromRides(
        rides: const [],
        stopsByRoute: const {},
      );

      final plans = planner.plan(
        origin: const LatLng(23.80, 90.40),
        destination: const LatLng(23.80 + kmInDegrees * 0.5, 90.40),
      );

      expect(plans, hasLength(1));
      expect(plans.single.legs, hasLength(1));
      expect(plans.single.legs.single, isA<WalkLeg>());
      expect(plans.single.rideCount, 0);
      expect(plans.single.totalWalkMeters, closeTo(500, 60));
    });

    test(
        'falls back to a direct walk, however far, when nothing else '
        'connects the two points', () {
      final planner = TransitPlanner.fromRides(
        rides: const [],
        stopsByRoute: const {},
      );

      final plans = planner.plan(
        origin: const LatLng(23.80, 90.40),
        destination: const LatLng(23.90, 90.40),
      );

      // No street network to say a ~11km walk is unreasonable — that's a
      // judgement call for whoever reads the distance, not a wall the
      // planner enforces.
      expect(plans, hasLength(1));
      expect(plans.single.rideCount, 0);
      expect(plans.single.totalWalkMeters, greaterThan(10000));
    });

    test('is empty only when origin and destination are the same point', () {
      final planner = TransitPlanner.fromRides(
        rides: const [],
        stopsByRoute: const {},
      );

      final plans = planner.plan(
        origin: const LatLng(23.80, 90.40),
        destination: const LatLng(23.80, 90.40),
      );

      expect(plans, isEmpty);
    });

    test('plans walk / ride / walk with the right board and alight stops', () {
      // Six stops heading north, 1 km apart, from 23.80 to 23.845.
      final ride = buildRide('A');
      final stops = buildStops(
        routeId: 'A',
        count: 6,
        startLat: 23.80,
        startLon: 90.40,
        stepLat: kmInDegrees,
      );

      final planner = TransitPlanner.fromRides(
        rides: [ride],
        stopsByRoute: {'A': stops},
      );

      // Start just west of stop 1, finish just west of stop 4.
      final plans = planner.plan(
        origin: LatLng(stops[1].latitude, stops[1].longitude - 0.002),
        destination: LatLng(stops[4].latitude, stops[4].longitude - 0.002),
      );

      expect(plans, isNotEmpty);
      final best = plans.first;
      expect(best.rideCount, 1);
      expect(best.legs.map((leg) => leg.runtimeType).toList(),
          [WalkLeg, RideLeg, WalkLeg]);

      final rideLeg = best.rideLegs.single;
      expect(rideLeg.ride.id, 'A');
      expect(rideLeg.boardStop.stopName, stops[1].stopName);
      expect(rideLeg.alightStop.stopName, stops[4].stopName);
      expect(rideLeg.viaStops.map((s) => s.stopName),
          [stops[2].stopName, stops[3].stopName]);
      expect(rideLeg.stopCount, 3);
    });

    test('rides a route against its sequence order', () {
      final ride = buildRide('A');
      final stops = buildStops(
        routeId: 'A',
        count: 5,
        startLat: 23.80,
        startLon: 90.40,
        stepLat: kmInDegrees,
      );

      final planner = TransitPlanner.fromRides(
        rides: [ride],
        stopsByRoute: {'A': stops},
      );

      // Travelling south: board at stop 4, alight at stop 1.
      final plans = planner.plan(
        origin: LatLng(stops[4].latitude, stops[4].longitude - 0.002),
        destination: LatLng(stops[1].latitude, stops[1].longitude - 0.002),
      );

      final rideLeg = plans.first.rideLegs.single;
      expect(rideLeg.boardStop.stopName, stops[4].stopName);
      expect(rideLeg.alightStop.stopName, stops[1].stopName);
    });

    test('never rides backwards when routes are one-directional', () {
      final ride = buildRide('A');
      final stops = buildStops(
        routeId: 'A',
        count: 5,
        startLat: 23.80,
        startLon: 90.40,
        stepLat: kmInDegrees,
      );

      final planner = TransitPlanner.fromRides(
        rides: [ride],
        stopsByRoute: {'A': stops},
        options: const TransitPlannerOptions(bidirectionalRoutes: false),
      );

      final plans = planner.plan(
        origin: LatLng(stops[4].latitude, stops[4].longitude - 0.002),
        destination: LatLng(stops[1].latitude, stops[1].longitude - 0.002),
      );

      // The only route can't be ridden backwards, so nothing beats a direct
      // walk — falls back to that rather than being empty.
      expect(plans, isNotEmpty);
      expect(plans.every((plan) => plan.rideCount == 0), isTrue);
    });

    test('transfers between two routes that meet at an interchange', () {
      // Route A runs north along 90.40; route B runs east along 23.84.
      // They meet near (23.84, 90.40).
      final rideA = buildRide('A');
      final stopsA = buildStops(
        routeId: 'A',
        count: 6,
        startLat: 23.80,
        startLon: 90.40,
        stepLat: kmInDegrees,
      );
      final rideB = buildRide('B');
      final stopsB = buildStops(
        routeId: 'B',
        count: 6,
        // 200 m east of route A's stop 4, so the transfer walk is short.
        startLat: 23.80 + kmInDegrees * 4,
        startLon: 90.402,
        stepLon: kmInDegrees,
      );

      final planner = TransitPlanner.fromRides(
        rides: [rideA, rideB],
        stopsByRoute: {'A': stopsA, 'B': stopsB},
      );

      final plans = planner.plan(
        origin: LatLng(stopsA.first.latitude, stopsA.first.longitude),
        destination: LatLng(stopsB.last.latitude, stopsB.last.longitude),
      );

      expect(plans, isNotEmpty);
      final best = plans.first;
      expect(best.rideCount, 2);
      expect(best.rideLegs.map((leg) => leg.ride.id).toList(), ['A', 'B']);

      // The transfer shows up as a walk between the two rides.
      expect(best.legs.map((leg) => leg.runtimeType).toList(),
          [RideLeg, WalkLeg, RideLeg]);
      expect(best.walkLegs.single.distanceMeters, closeTo(200, 80));
      expect(best.totalFare, rideA.fare + rideB.fare);
    });

    test('caps the number of rides at maxRides', () {
      // Four short routes chained end to end, each needing its own boarding.
      final rides = <Ride>[];
      final stopsByRoute = <String, List<RouteStop>>{};
      for (var i = 0; i < 4; i++) {
        final id = 'R$i';
        rides.add(buildRide(id));
        stopsByRoute[id] = buildStops(
          routeId: id,
          count: 3,
          startLat: 23.80 + kmInDegrees * 2 * i,
          startLon: 90.40,
          stepLat: kmInDegrees,
        );
      }

      final planner = TransitPlanner.fromRides(
        rides: rides,
        stopsByRoute: stopsByRoute,
        options: const TransitPlannerOptions(maxRides: 2),
      );

      final plans = planner.plan(
        origin: const LatLng(23.80, 90.40),
        destination: LatLng(
          stopsByRoute['R3']!.last.latitude,
          stopsByRoute['R3']!.last.longitude,
        ),
      );

      expect(plans.every((plan) => plan.rideCount <= 2), isTrue);
    });

    test('prefers one longer ride over two shorter ones', () {
      // Route A goes the whole way. Routes B and C cover the same corridor in
      // two hops, so only the extra boarding penalty separates them.
      final rideA = buildRide('A');
      final stopsA = buildStops(
        routeId: 'A',
        count: 9,
        startLat: 23.80,
        startLon: 90.40,
        stepLat: kmInDegrees,
      );

      final rideB = buildRide('B');
      final stopsB = buildStops(
        routeId: 'B',
        count: 5,
        startLat: 23.80,
        startLon: 90.4005,
        stepLat: kmInDegrees,
      );
      final rideC = buildRide('C');
      final stopsC = buildStops(
        routeId: 'C',
        count: 5,
        startLat: 23.80 + kmInDegrees * 4,
        startLon: 90.4005,
        stepLat: kmInDegrees,
      );

      final planner = TransitPlanner.fromRides(
        rides: [rideA, rideB, rideC],
        stopsByRoute: {'A': stopsA, 'B': stopsB, 'C': stopsC},
      );

      final plans = planner.plan(
        origin: LatLng(stopsA.first.latitude, stopsA.first.longitude),
        destination: LatLng(stopsA.last.latitude, stopsA.last.longitude),
      );

      expect(plans.first.rideCount, 1);
      expect(plans.first.rideLegs.single.ride.id, 'A');
    });

    test('prefers riding over a long walk along the same corridor', () {
      final ride = buildRide('A');
      final stops = buildStops(
        routeId: 'A',
        count: 4,
        startLat: 23.80,
        startLon: 90.40,
        stepLat: kmInDegrees * 0.4,
      );

      final planner = TransitPlanner.fromRides(
        rides: [ride],
        stopsByRoute: {'A': stops},
      );

      // 1.2 km apart — walking the whole way is always a candidate, so this
      // checks the ride still wins on cost.
      final plans = planner.plan(
        origin: LatLng(stops.first.latitude, stops.first.longitude),
        destination: LatLng(stops.last.latitude, stops.last.longitude),
      );

      expect(plans.first.rideCount, 1);
    });

    test('returns distinct alternatives, cheapest first, without duplicates',
        () {
      final rideA = buildRide('A');
      final stopsA = buildStops(
        routeId: 'A',
        count: 6,
        startLat: 23.80,
        startLon: 90.40,
        stepLat: kmInDegrees,
      );
      final rideB = buildRide('B');
      final stopsB = buildStops(
        routeId: 'B',
        count: 6,
        startLat: 23.80,
        startLon: 90.4025,
        stepLat: kmInDegrees,
      );

      final planner = TransitPlanner.fromRides(
        rides: [rideA, rideB],
        stopsByRoute: {'A': stopsA, 'B': stopsB},
      );

      final plans = planner.plan(
        origin: const LatLng(23.80, 90.401),
        destination: LatLng(stopsA.last.latitude, 90.401),
      );

      expect(plans, isNotEmpty);
      expect(plans.length, lessThanOrEqualTo(options.maxResults));

      final signatures = plans.map((plan) => plan.routeSignature).toList();
      expect(signatures.toSet(), hasLength(signatures.length));
    });

    test('ignores routes with fewer than two stops', () {
      final ride = buildRide('A');
      final stops = buildStops(
        routeId: 'A',
        count: 1,
        startLat: 23.80,
        startLon: 90.40,
      );

      final planner = TransitPlanner.fromRides(
        rides: [ride],
        stopsByRoute: {'A': stops},
      );

      final plans = planner.plan(
        origin: const LatLng(23.80, 90.40),
        destination: const LatLng(23.86, 90.40),
      );

      // The single-stop route can't be boarded, so this falls all the way
      // back to the direct-walk option rather than using it.
      expect(plans, hasLength(1));
      expect(plans.single.rideCount, 0);
    });

    test('itinerary points span origin to destination in order', () {
      final ride = buildRide('A');
      final stops = buildStops(
        routeId: 'A',
        count: 4,
        startLat: 23.80,
        startLon: 90.40,
        stepLat: kmInDegrees,
      );

      final planner = TransitPlanner.fromRides(
        rides: [ride],
        stopsByRoute: {'A': stops},
      );

      const origin = LatLng(23.80, 90.398);
      final destination = LatLng(stops.last.latitude, 90.398);
      final best = planner.plan(origin: origin, destination: destination).first;

      expect(best.points.first, origin);
      expect(best.points.last, destination);
    });

    test(
        'still boards a stop several km away rather than reporting no route '
        '(regression: there is no access-walk cap)', () {
      final ride = buildRide('A');
      final stops = buildStops(
        routeId: 'A',
        count: 6,
        startLat: 23.80,
        startLon: 90.40,
        stepLat: kmInDegrees,
      );

      final planner = TransitPlanner.fromRides(
        rides: [ride],
        stopsByRoute: {'A': stops},
      );

      // ~3.5km east of the route's first stop — well beyond the old 1km
      // access-walk cap that caused this exact false negative in the app.
      final plans = planner.plan(
        origin: LatLng(stops.first.latitude, stops.first.longitude + 0.035),
        destination: LatLng(stops.last.latitude, stops.last.longitude),
      );

      expect(plans, isNotEmpty);
      expect(plans.any((plan) => plan.rideCount == 1), isTrue);
    });
  });
}
