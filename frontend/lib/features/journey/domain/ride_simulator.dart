import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Walks a virtual position along a route's polyline points over time, at a
/// fixed speed, standing in for real GPS movement during ride simulation.
///
/// Segment distances are computed with [Geolocator.distanceBetween]
/// (haversine). Each tick advances the traveled distance by `speedKmh`
/// scaled to [tickInterval], then linearly interpolates between the two
/// route points straddling that distance.
class RideSimulator {
  RideSimulator({
    required List<LatLng> route,
    this.speedKmh = 32,
    this.tickInterval = const Duration(milliseconds: 300),
    this.onComplete,
  })  : assert(route.length >= 2, 'RideSimulator needs at least 2 route points'),
        _route = route,
        _segmentMeters = _computeSegmentMeters(route),
        position = ValueNotifier<LatLng>(route.first),
        progress = ValueNotifier<double>(0.0) {
    _totalMeters = _segmentMeters.fold(0.0, (sum, d) => sum + d);
  }

  final List<LatLng> _route;
  final List<double> _segmentMeters;
  late final double _totalMeters;

  /// Average speed the simulated position advances at.
  final double speedKmh;

  /// How often the position is recomputed.
  final Duration tickInterval;

  /// Called once when the simulated position reaches the end of the route.
  final VoidCallback? onComplete;

  /// Current simulated position, updated every [tickInterval].
  final ValueNotifier<LatLng> position;

  /// Fraction of the route covered so far, from 0.0 to 1.0.
  final ValueNotifier<double> progress;

  Timer? _timer;
  double _traveledMeters = 0;
  bool _isComplete = false;

  bool get isRunning => _timer != null;
  bool get isComplete => _isComplete;

  /// Starts (or resumes) walking the route. No-op if already running or the
  /// route has already been fully walked.
  void start() {
    if (isRunning || _isComplete) return;

    if (_totalMeters <= 0) {
      _finish();
      return;
    }

    final metersPerTick =
        (speedKmh * 1000 / 3600) * tickInterval.inMilliseconds / 1000;
    _timer = Timer.periodic(tickInterval, (_) => _advance(metersPerTick));
  }

  /// Pauses walking without losing progress. [start] resumes from here.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    position.dispose();
    progress.dispose();
  }

  void _advance(double metersPerTick) {
    _traveledMeters = math.min(_traveledMeters + metersPerTick, _totalMeters);
    position.value = _positionAtDistance(_traveledMeters);
    progress.value = _traveledMeters / _totalMeters;

    if (_traveledMeters >= _totalMeters) {
      _finish();
    }
  }

  void _finish() {
    stop();
    _isComplete = true;
    onComplete?.call();
  }

  LatLng _positionAtDistance(double meters) {
    double remaining = meters;
    for (var i = 0; i < _segmentMeters.length; i++) {
      final segment = _segmentMeters[i];
      final isLastSegment = i == _segmentMeters.length - 1;
      if (remaining <= segment || isLastSegment) {
        final t = segment == 0 ? 0.0 : (remaining / segment).clamp(0.0, 1.0);
        return _lerp(_route[i], _route[i + 1], t);
      }
      remaining -= segment;
    }
    return _route.last;
  }

  static LatLng _lerp(LatLng a, LatLng b, double t) {
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  static List<double> _computeSegmentMeters(List<LatLng> route) {
    final distances = <double>[];
    for (var i = 0; i < route.length - 1; i++) {
      distances.add(
        Geolocator.distanceBetween(
          route[i].latitude,
          route[i].longitude,
          route[i + 1].latitude,
          route[i + 1].longitude,
        ),
      );
    }
    return distances;
  }
}
