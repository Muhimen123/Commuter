import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain/entities/safety_point.dart';

const LatLng kDhakaSafetyCenter = LatLng(23.8103, 90.4125);

abstract class SafetyHeatmapRepository {
  Future<List<SafetyPoint>> getSafetyPoints({required LatLng center});
}

class MockSafetyHeatmapRepository implements SafetyHeatmapRepository {
  @override
  Future<List<SafetyPoint>> getSafetyPoints({required LatLng center}) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final random = Random(7);
    final points = <SafetyPoint>[];

    // ── Perlin-like noise field for smooth score variation ──
    double noise2D(double x, double y) {
      // Simple layered noise using sin/cos with random phases
      double value = 0.0;
      double amp = 1.0;
      double freq = 0.0008;
      for (var i = 0; i < 4; i++) {
        value += sin(x * freq) * cos(y * freq * 1.3 + 0.7 * i) * amp;
        freq *= 2.1;
        amp *= 0.5;
      }
      return value;
    }

    // ── Random scattered points (no grid) ──
    // Spread over ~10km, with ~1800 random positions
    const spreadDeg = 0.045; // ~5km in each direction
    const pointCount = 1800;
    for (var i = 0; i < pointCount; i++) {
      final latOffset = (random.nextDouble() - 0.5) * spreadDeg * 2;
      final lngOffset = (random.nextDouble() - 0.5) * spreadDeg * 2;
      final xMeters = lngOffset * 111000 * cos(center.latitude * pi / 180);
      final yMeters = latOffset * 111000;

      final noise = noise2D(xMeters, yMeters);
      final jitter = (random.nextDouble() - 0.5) * 0.12;
      final score = (((noise + 1) / 2) + jitter).clamp(0.0, 1.0);

      points.add(
        SafetyPoint(
          latitude: center.latitude + latOffset,
          longitude: center.longitude + lngOffset,
          score: score,
          reportCount: 2 + random.nextInt(25),
        ),
      );
    }

    // ── Hotspot clusters (dangerous areas) ──
    final dangerClusters = <_Cluster>[
      _Cluster(latOffset: 0.007, lngOffset: -0.005, baseScore: 0.08, spread: 0.006, count: 40),
      _Cluster(latOffset: -0.009, lngOffset: 0.008, baseScore: 0.12, spread: 0.005, count: 30),
      _Cluster(latOffset: 0.016, lngOffset: 0.022, baseScore: 0.05, spread: 0.008, count: 35),
      _Cluster(latOffset: -0.025, lngOffset: -0.018, baseScore: 0.10, spread: 0.010, count: 45),
      _Cluster(latOffset: 0.005, lngOffset: 0.012, baseScore: 0.15, spread: 0.007, count: 25),
      _Cluster(latOffset: -0.012, lngOffset: -0.020, baseScore: 0.06, spread: 0.009, count: 30),
    ];

    // ── Safe clusters ──
    final safeClusters = <_Cluster>[
      _Cluster(latOffset: 0.008, lngOffset: -0.015, baseScore: 0.92, spread: 0.005, count: 30),
      _Cluster(latOffset: -0.005, lngOffset: 0.015, baseScore: 0.88, spread: 0.006, count: 25),
      _Cluster(latOffset: 0.020, lngOffset: -0.020, baseScore: 0.95, spread: 0.009, count: 35),
      _Cluster(latOffset: -0.022, lngOffset: 0.025, baseScore: 0.90, spread: 0.008, count: 30),
      _Cluster(latOffset: -0.030, lngOffset: 0.008, baseScore: 0.85, spread: 0.010, count: 25),
      _Cluster(latOffset: 0.030, lngOffset: -0.030, baseScore: 0.93, spread: 0.012, count: 40),
    ];

    for (final cluster in [...dangerClusters, ...safeClusters]) {
      for (var i = 0; i < cluster.count; i++) {
        final lat = center.latitude +
            cluster.latOffset +
            (random.nextDouble() - 0.5) * cluster.spread;
        final lng = center.longitude +
            cluster.lngOffset +
            (random.nextDouble() - 0.5) * cluster.spread;
        final score =
            (cluster.baseScore + (random.nextDouble() - 0.5) * 0.12).clamp(0.0, 1.0);
        points.add(
          SafetyPoint(
            latitude: lat,
            longitude: lng,
            score: score,
            reportCount: 10 + random.nextInt(60),
          ),
        );
      }
    }

    return points;
  }
}

class _Cluster {
  final double latOffset;
  final double lngOffset;
  final double baseScore;
  final double spread;
  final int count;

  const _Cluster({
    required this.latOffset,
    required this.lngOffset,
    required this.baseScore,
    required this.spread,
    required this.count,
  });
}
