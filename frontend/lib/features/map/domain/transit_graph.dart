import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';
import 'package:frontend/features/ride_discovery/domain/entities/route_stop.dart';

/// Straight-line distance in metres.
///
/// [Geolocator.distanceBetween] is plain haversine math on the platform
/// interface — no channel call — so this stays usable from pure unit tests.
double distanceMeters(LatLng a, LatLng b) => Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );

/// One stop *occurrence*: the same physical place served by two routes is two
/// separate nodes, which is what lets a transfer between them cost something.
class StopNode {
  /// Index of this node in [TransitGraph.nodes].
  final int index;
  final String routeId;

  /// Position of this stop within its route's ordered stop list.
  final int stopIndex;
  final RouteStop stop;

  const StopNode({
    required this.index,
    required this.routeId,
    required this.stopIndex,
    required this.stop,
  });

  LatLng get position => LatLng(stop.latitude, stop.longitude);
}

/// The stop network the planner searches over: every stop of every route.
///
/// There is no street network to route a walk over and no cap on how far
/// someone might walk or be dropped off to reach a stop — this app only
/// knows straight-line distance, so [TransitPlanner] considers every stop a
/// reachable candidate and lets the walk-cost penalty prefer the near ones.
/// With the current network size (tens of routes, hundreds of stops) a plain
/// list is fast enough that no spatial index is worth the complexity.
class TransitGraph {
  final List<StopNode> nodes;

  /// Nodes of each route, in `sequence_order`.
  final Map<String, List<StopNode>> nodesByRoute;

  final Map<String, Ride> _ridesById;

  const TransitGraph._({
    required this.nodes,
    required this.nodesByRoute,
    required this._ridesById,
  });

  /// Builds the graph from the rides and their stops.
  ///
  /// Rides with fewer than two stops are skipped — you cannot board and alight
  /// on them, so they only add dead-end nodes.
  factory TransitGraph.build({
    required List<Ride> rides,
    required Map<String, List<RouteStop>> stopsByRoute,
  }) {
    final nodes = <StopNode>[];
    final nodesByRoute = <String, List<StopNode>>{};
    final ridesById = <String, Ride>{};

    for (final ride in rides) {
      final stops = stopsByRoute[ride.id];
      if (stops == null || stops.length < 2) continue;

      final ordered = [...stops]
        ..sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

      ridesById[ride.id] = ride;
      final routeNodes = <StopNode>[];

      for (var i = 0; i < ordered.length; i++) {
        final node = StopNode(
          index: nodes.length,
          routeId: ride.id,
          stopIndex: i,
          stop: ordered[i],
        );
        nodes.add(node);
        routeNodes.add(node);
      }

      nodesByRoute[ride.id] = routeNodes;
    }

    return TransitGraph._(
      nodes: nodes,
      nodesByRoute: nodesByRoute,
      ridesById: ridesById,
    );
  }

  bool get isEmpty => nodes.isEmpty;

  Ride? rideFor(String routeId) => _ridesById[routeId];
}
