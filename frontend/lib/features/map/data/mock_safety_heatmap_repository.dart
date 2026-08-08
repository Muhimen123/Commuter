import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../domain/entities/safety_point.dart';

const LatLng kDhakaSafetyCenter = LatLng(23.8103, 90.4125);

abstract class SafetyHeatmapRepository {
  Future<List<SafetyPoint>> getSafetyPoints({required LatLng center});
}

/// Distance band: points are laid out on concentric rings within
/// [minRadius, maxRadius], `spacing` meters apart along each ring. Bands
/// further from center use larger spacing (fewer points) but a
/// proportionally larger `influenceRadiusMeters` per point, so coverage
/// stays continuous without the point count exploding.
class _Band {
  final double minRadius;
  final double maxRadius;
  final double spacing;
  const _Band({required this.minRadius, required this.maxRadius, required this.spacing});
}

const _bands = [
  _Band(minRadius: 0, maxRadius: 800, spacing: 260), // fine detail right around the user
  _Band(minRadius: 800, maxRadius: 2500, spacing: 650),
  _Band(minRadius: 2500, maxRadius: 5500, spacing: 1300),
  _Band(minRadius: 5500, maxRadius: 10000, spacing: 2400), // wide ambient coverage out to ~10km
];

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

    // Meters -> degrees conversion, corrected for latitude so the ~10km
    // radius stays roughly circular instead of squashed east-west.
    final centerLatRad = center.latitude * pi / 180;
    const metersPerDegLat = 111320.0;
    final metersPerDegLng = 111320.0 * cos(centerLatRad);

    LatLng offsetMeters(double dxEast, double dyNorth) {
      return LatLng(
        center.latitude + dyNorth / metersPerDegLat,
        center.longitude + dxEast / metersPerDegLng,
      );
    }

    // --- Ambient field, ring by ring, band by band ----------------------
    for (final band in _bands) {
      for (var r = band.minRadius + band.spacing / 2; r < band.maxRadius; r += band.spacing) {
        final ringPointCount = max(6, (2 * pi * r / band.spacing).round());
        final angleOffset = random.nextDouble() * pi * 2;
        for (var i = 0; i < ringPointCount; i++) {
          final angle = (2 * pi * i / ringPointCount) + angleOffset;
          final dx = r * cos(angle);
          final dy = r * sin(angle);

          final noise = fieldNoise(dx, dy);
          final jitter = (random.nextDouble() - 0.5) * 0.08;
          final score = (((noise + 1) / 2) + jitter).clamp(0.0, 1.0);
          final pos = offsetMeters(dx, dy);

          points.add(
            SafetyPoint(
              latitude: pos.latitude,
              longitude: pos.longitude,
              score: score,
              reportCount: 2 + random.nextInt(25),
              influenceRadiusMeters: band.spacing * 0.62,
            ),
          );
        }
      }
    }

    // --- Signature hotspots, close to the user, layered on top ----------
    final hotspots = <_MockCluster>[
      _MockCluster(latOffset: 0.0075, lngOffset: -0.0060, baseScore: 0.92, spread: 0.0035, count: 8),
      _MockCluster(latOffset: -0.0080, lngOffset: 0.0070, baseScore: 0.10, spread: 0.0030, count: 7),
      _MockCluster(latOffset: 0.0040, lngOffset: 0.0090, baseScore: 0.85, spread: 0.0030, count: 5),
      _MockCluster(latOffset: -0.0045, lngOffset: -0.0085, baseScore: 0.15, spread: 0.0030, count: 5),
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
