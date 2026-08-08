import 'package:latlong2/latlong.dart';

/// A single community-reported (or backend-aggregated) safety data point
/// used to render the safety heatmap layer on the map.
class SafetyPoint {
  final double latitude;
  final double longitude;

  /// Normalized safety score: 0.0 = highest risk, 1.0 = safest.
  final double score;

  /// How many community reports back this point (cosmetic/debug for now).
  final int reportCount;

  /// How far this point's rendered "blob" reaches, in meters. Sparse points
  /// further from the map center should use a larger radius so a wide area
  /// still reads as continuous coverage instead of dots with gaps.
  final double influenceRadiusMeters;

  const SafetyPoint({
    required this.latitude,
    required this.longitude,
    required this.score,
    this.reportCount = 0,
    this.influenceRadiusMeters = 260,
  }) : assert(score >= 0.0 && score <= 1.0, 'score must be between 0.0 and 1.0');

  LatLng get position => LatLng(latitude, longitude);
}
