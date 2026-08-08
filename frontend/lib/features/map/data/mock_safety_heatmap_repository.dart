import 'dart:math';
import 'package:latlong2/latlong.dart';
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

    final phases = List.generate(4, (_) => random.nextDouble() * pi * 2);
    const freqs = [0.0011, 0.0019, 0.0031, 0.0047]; 

    double fieldNoise(double xMeters, double yMeters) {
      var value = 0.0;
      for (var i = 0; i < freqs.length; i++) {
        value += sin(xMeters * freqs[i] + phases[i]) * cos(yMeters * freqs[i] * 1.3 + phases[i]);
      }
      return value / freqs.length; 
    }

    const gridStepDeg = 0.0024;
    const gridHalfExtent = 15; // Increased from 4 to cover ~8km across
    for (var gx = -gridHalfExtent; gx <= gridHalfExtent; gx++) {
      for (var gy = -gridHalfExtent; gy <= gridHalfExtent; gy++) {
        final latOffset = gy * gridStepDeg;
        final lngOffset = gx * gridStepDeg;
        final xMeters = gx * 265.0;
        final yMeters = gy * 265.0;

        final noise = fieldNoise(xMeters, yMeters); 
        final jitter = (random.nextDouble() - 0.5) * 0.08;
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
    }

    final hotspots = <_MockCluster>[
      _MockCluster(latOffset: 0.0075, lngOffset: -0.0060, baseScore: 0.92, spread: 0.0035, count: 8),
      _MockCluster(latOffset: -0.0080, lngOffset: 0.0070, baseScore: 0.10, spread: 0.0030, count: 7),
      _MockCluster(latOffset: 0.0040, lngOffset: 0.0090, baseScore: 0.85, spread: 0.0030, count: 5),
      _MockCluster(latOffset: -0.0045, lngOffset: -0.0085, baseScore: 0.15, spread: 0.0030, count: 5),
      _MockCluster(latOffset: 0.0150, lngOffset: 0.0200, baseScore: 0.05, spread: 0.0050, count: 10),
      _MockCluster(latOffset: -0.0200, lngOffset: -0.0150, baseScore: 0.95, spread: 0.0060, count: 12),
      _MockCluster(latOffset: 0.0250, lngOffset: -0.0250, baseScore: 0.20, spread: 0.0080, count: 15),
      _MockCluster(latOffset: -0.0300, lngOffset: 0.0300, baseScore: 0.80, spread: 0.0080, count: 15),
    ];

    for (final cluster in hotspots) {
      for (var i = 0; i < cluster.count; i++) {
        final lat = center.latitude + cluster.latOffset + (random.nextDouble() - 0.5) * cluster.spread;
        final lng = center.longitude + cluster.lngOffset + (random.nextDouble() - 0.5) * cluster.spread;
        final score = (cluster.baseScore + (random.nextDouble() - 0.5) * 0.08).clamp(0.0, 1.0);
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

class _MockCluster {
  final double latOffset;
  final double lngOffset;
  final double baseScore;
  final double spread;
  final int count;

  const _MockCluster({
    required this.latOffset,
    required this.lngOffset,
    required this.baseScore,
    required this.spread,
    required this.count,
  });
}
