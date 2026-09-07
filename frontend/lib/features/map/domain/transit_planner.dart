import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:frontend/features/map/domain/entities/journey_leg.dart';
import 'package:frontend/features/map/domain/transit_graph.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';
import 'package:frontend/features/ride_discovery/domain/entities/route_stop.dart';

/// Tuning for [TransitPlanner].
///
/// Costs are a single scalar in metres rather than an estimated duration: the
/// database has no timetables, so anything finer would be false precision.
/// Walking is charged at [walkPenalty] times its real length, and each ride
/// boarded adds [boardingPenaltyMeters]. Those two numbers alone produce the
/// behaviour that matters — prefer riding to walking, prefer fewer transfers.
///
/// There is deliberately no walking-distance cap (access, transfer, or
/// direct): this app has no street network to know whether a stop is
/// actually reachable on foot, only straight-line distance, so treating a
/// cap as a hard "unreachable" wall produces false negatives — a stop 1.1km
/// away isn't unreachable, it's just less convenient than one 200m away.
/// The cost penalty already expresses that preference; every stop is always
/// a candidate, and how far someone will really walk (or get dropped off) is
/// left to the commuter reading the distance in the itinerary.
class TransitPlannerOptions {
  /// How much worse a walked metre is than a ridden one.
  final double walkPenalty;

  /// Flat cost added per ride boarded, which is what makes the planner avoid
  /// gratuitous transfers.
  final double boardingPenaltyMeters;

  /// Cap on rides in one itinerary. Also bounds the search space.
  final int maxRides;

  /// Whether a route can be ridden against its `sequence_order`. True by
  /// default: the schema has no direction flag and these routes run both ways.
  final bool bidirectionalRoutes;

  /// How many alternatives to return.
  final int maxResults;

  const TransitPlannerOptions({
    this.walkPenalty = 4,
    this.boardingPenaltyMeters = 2000,
    this.maxRides = 3,
    this.bidirectionalRoutes = true,
    this.maxResults = 3,
  });
}

/// Plans walk + ride itineraries across the stop network.
///
/// Dijkstra over states of `(stop occurrence, rides boarded so far)`. Taking
/// the best label for each distinct ride count gives naturally different
/// options — an all-walk one, a one-ride one, a two-ride one — without needing
/// k-shortest-paths.
class TransitPlanner {
  final TransitGraph graph;
  final TransitPlannerOptions options;

  const TransitPlanner({required this.graph, required this.options});

  factory TransitPlanner.fromRides({
    required List<Ride> rides,
    required Map<String, List<RouteStop>> stopsByRoute,
    TransitPlannerOptions options = const TransitPlannerOptions(),
  }) {
    return TransitPlanner(
      graph: TransitGraph.build(rides: rides, stopsByRoute: stopsByRoute),
      options: options,
    );
  }

  /// Returns up to [TransitPlannerOptions.maxResults] itineraries from
  /// [origin] to [destination], cheapest first. A direct walk is always one
  /// of the candidates, however far, so this is only empty when [origin]
  /// and [destination] are effectively the same point.
  List<TransitItinerary> plan({
    required LatLng origin,
    required LatLng destination,
  }) {
    final rideSlots = options.maxRides + 1;
    final stateCount = graph.nodes.length * rideSlots;

    final cost = List<double>.filled(stateCount, double.infinity);
    final steps = List<_Step?>.filled(stateCount, null);
    // Lazy deletion: the heap can hold several entries for one state, so the
    // first (cheapest) pop settles it and later pops are skipped.
    final settled = List<bool>.filled(stateCount, false);

    // Best arrival at the destination for each ride count, tracked separately
    // per count so the alternatives differ in a way a commuter cares about.
    final destCost = List<double>.filled(rideSlots, double.infinity);
    final destFrom = List<int?>.filled(rideSlots, null);

    // Option 0 rides: just walk the whole way. Always on the table — with no
    // street network to say otherwise, "too far to walk" is a judgement call
    // for whoever reads the distance, not a wall the planner enforces.
    destCost[0] = distanceMeters(origin, destination) * options.walkPenalty;

    final queue = _MinHeap();

    // Access edges: walk from the origin to a stop and board there. Every
    // stop is a candidate; the walk-cost penalty is what makes a near one
    // win over a far one.
    if (options.maxRides >= 1) {
      for (final node in graph.nodes) {
        final walk = distanceMeters(origin, node.position);
        final c = walk * options.walkPenalty + options.boardingPenaltyMeters;
        final state = _stateOf(node.index, 1, rideSlots);
        if (c < cost[state]) {
          cost[state] = c;
          steps[state] = const _Step(from: null, kind: _StepKind.access);
          queue.add(state, c);
        }
      }
    }

    while (queue.isNotEmpty) {
      final state = queue.removeMin();
      if (settled[state]) continue;
      settled[state] = true;

      final current = cost[state];
      final nodeIndex = state ~/ rideSlots;
      final ridesUsed = state % rideSlots;
      final node = graph.nodes[nodeIndex];

      // Egress: get off here and walk the rest.
      final egress = distanceMeters(node.position, destination);
      final egressCost = current + egress * options.walkPenalty;
      if (egressCost < destCost[ridesUsed]) {
        destCost[ridesUsed] = egressCost;
        destFrom[ridesUsed] = state;
      }

      // Ride edges: stay aboard to the neighbouring stops on this route.
      final routeNodes = graph.nodesByRoute[node.routeId]!;
      for (final delta in const [1, -1]) {
        if (delta == -1 && !options.bidirectionalRoutes) continue;
        final nextIndex = node.stopIndex + delta;
        if (nextIndex < 0 || nextIndex >= routeNodes.length) continue;

        final next = routeNodes[nextIndex];
        final c = current + distanceMeters(node.position, next.position);
        final nextState = _stateOf(next.index, ridesUsed, rideSlots);
        if (c < cost[nextState]) {
          cost[nextState] = c;
          steps[nextState] = _Step(from: state, kind: _StepKind.ride);
          queue.add(nextState, c);
        }
      }

      // Transfer edges: walk to a stop on a different route and board it.
      // Every other route's stops are candidates, same reasoning as access.
      if (ridesUsed >= options.maxRides) continue;
      for (final other in graph.nodes) {
        if (other.routeId == node.routeId) continue;

        final walk = distanceMeters(node.position, other.position);
        final c = current +
            walk * options.walkPenalty +
            options.boardingPenaltyMeters;
        final nextState = _stateOf(other.index, ridesUsed + 1, rideSlots);
        if (c < cost[nextState]) {
          cost[nextState] = c;
          steps[nextState] = _Step(from: state, kind: _StepKind.transfer);
          queue.add(nextState, c);
        }
      }
    }

    final candidates = <_Candidate>[];
    for (var rides = 0; rides < rideSlots; rides++) {
      if (destCost[rides] == double.infinity) continue;
      final itinerary = _rebuild(
        endState: destFrom[rides],
        steps: steps,
        rideSlots: rideSlots,
        origin: origin,
        destination: destination,
      );
      if (itinerary != null) {
        candidates.add(_Candidate(itinerary, destCost[rides]));
      }
    }

    candidates.sort((a, b) => a.cost.compareTo(b.cost));

    // Two ride counts can collapse to the same journey once zero-length hops
    // are dropped, so dedupe on the route sequence and keep the cheapest.
    final seen = <String>{};
    final results = <TransitItinerary>[];
    for (final candidate in candidates) {
      if (!seen.add(candidate.itinerary.routeSignature)) continue;
      results.add(candidate.itinerary);
      if (results.length == options.maxResults) break;
    }
    return results;
  }

  static int _stateOf(int nodeIndex, int ridesUsed, int rideSlots) =>
      nodeIndex * rideSlots + ridesUsed;

  /// Walks the predecessor chain back to the origin and turns it into legs.
  ///
  /// Returns null if the resulting itinerary has no legs at all, which would
  /// mean the origin and destination resolved to the same point.
  TransitItinerary? _rebuild({
    required int? endState,
    required List<_Step?> steps,
    required int rideSlots,
    required LatLng origin,
    required LatLng destination,
  }) {
    // endState == null is the all-walk option: no stops were involved.
    final chain = <_ChainEntry>[];
    var cursor = endState;
    while (cursor != null) {
      final step = steps[cursor]!;
      chain.add(
        _ChainEntry(graph.nodes[cursor ~/ rideSlots], step.kind),
      );
      cursor = step.from;
    }
    final forward = chain.reversed.toList(growable: false);

    final legs = <JourneyLeg>[];
    var from = origin;

    var i = 0;
    while (i < forward.length) {
      // Every run starts with a walk — access from the origin, or a transfer.
      final boardNode = forward[i].node;
      _addWalk(legs, from, boardNode.position, boardNode.stop.stopName);

      // Consume the ride edges that keep us on this route.
      var j = i;
      while (j + 1 < forward.length && forward[j + 1].kind == _StepKind.ride) {
        j++;
      }

      if (j > i) {
        final alightNode = forward[j].node;
        final ride = graph.rideFor(boardNode.routeId)!;
        final via = [
          for (var k = i + 1; k < j; k++) forward[k].node.stop,
        ];
        legs.add(
          RideLeg(
            ride: ride,
            boardStop: boardNode.stop,
            alightStop: alightNode.stop,
            viaStops: via,
            distanceMeters: _runDistance(forward, i, j),
          ),
        );
        from = alightNode.position;
      } else {
        // Boarded and alighted at the same stop — not a ride at all. Drop it
        // and let the next walk continue from here.
        from = boardNode.position;
      }

      i = j + 1;
    }

    _addWalk(legs, from, destination, null);
    if (legs.isEmpty) return null;

    return TransitItinerary(legs: _coalesceWalks(legs));
  }

  /// Appends a walk leg unless it is too short to be worth mentioning.
  void _addWalk(List<JourneyLeg> legs, LatLng from, LatLng to, String? name) {
    final metres = distanceMeters(from, to);
    if (metres < 1) return;
    legs.add(
      WalkLeg(from: from, to: to, distanceMeters: metres, toStopName: name),
    );
  }

  double _runDistance(List<_ChainEntry> chain, int start, int end) {
    var total = 0.0;
    for (var k = start; k < end; k++) {
      total += distanceMeters(chain[k].node.position, chain[k + 1].node.position);
    }
    return total;
  }

  /// Merges back-to-back walks, which appear when a dropped zero-length ride
  /// leaves a walk-to-stop immediately followed by a walk-away-from-stop.
  List<JourneyLeg> _coalesceWalks(List<JourneyLeg> legs) {
    final merged = <JourneyLeg>[];
    for (final leg in legs) {
      final previous = merged.isEmpty ? null : merged.last;
      if (leg is WalkLeg && previous is WalkLeg) {
        merged[merged.length - 1] = WalkLeg(
          from: previous.from,
          to: leg.to,
          distanceMeters: distanceMeters(previous.from, leg.to),
          toStopName: leg.toStopName,
        );
      } else {
        merged.add(leg);
      }
    }
    return merged;
  }
}

enum _StepKind { access, ride, transfer }

class _Step {
  /// The state this one was reached from; null for an origin access edge.
  final int? from;
  final _StepKind kind;

  const _Step({required this.from, required this.kind});
}

class _ChainEntry {
  final StopNode node;
  final _StepKind kind;

  const _ChainEntry(this.node, this.kind);
}

class _Candidate {
  final TransitItinerary itinerary;
  final double cost;

  const _Candidate(this.itinerary, this.cost);
}

/// Binary min-heap keyed by cost.
///
/// Hand-rolled rather than pulling in `package:collection`, which is only a
/// transitive dependency here.
class _MinHeap {
  final List<int> _states = [];
  final List<double> _costs = [];

  bool get isNotEmpty => _states.isNotEmpty;

  void add(int state, double cost) {
    _states.add(state);
    _costs.add(cost);
    var i = _states.length - 1;
    while (i > 0) {
      final parent = (i - 1) ~/ 2;
      if (_costs[parent] <= _costs[i]) break;
      _swap(i, parent);
      i = parent;
    }
  }

  int removeMin() {
    final top = _states.first;
    final lastIndex = _states.length - 1;
    _swap(0, lastIndex);
    _states.removeLast();
    _costs.removeLast();

    var i = 0;
    while (true) {
      final left = 2 * i + 1;
      final right = left + 1;
      var smallest = i;
      if (left < _states.length && _costs[left] < _costs[smallest]) {
        smallest = left;
      }
      if (right < _states.length && _costs[right] < _costs[smallest]) {
        smallest = right;
      }
      if (smallest == i) break;
      _swap(i, smallest);
      i = smallest;
    }
    return top;
  }

  void _swap(int a, int b) {
    final state = _states[a];
    _states[a] = _states[b];
    _states[b] = state;
    final cost = _costs[a];
    _costs[a] = _costs[b];
    _costs[b] = cost;
  }
}
