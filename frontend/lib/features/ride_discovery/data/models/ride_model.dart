import '../../domain/entities/ride.dart';

class RideModel extends Ride {
  const RideModel({
    required super.id,
    required super.routeNumber,
    required super.routeName,
    required super.destination,
    required super.via,
    required super.status,
    required super.rating,
    required super.reviewCount,
    required super.safetyScore,
    required super.fare,
    super.isRecommended,
    super.transitMode,
    super.lineCode,
    super.lineColor,
  });

  factory RideModel.fromJson(Map<String, dynamic> json, {String? via}) {
    return RideModel(
      id: json['id'] as String,
      routeNumber: json['route_number'] as String,
      routeName: json['route_name'] as String,
      destination: json['end_point_name'] as String? ?? '',
      via: via ?? '',
      status: _statusFromString(json['current_status'] as String?),
      rating: 0,
      reviewCount: 0,
      safetyScore: _safetyScoreToPercent(json['safety_score'] as num?),
      fare: (json['average_fare'] as num?)?.toDouble() ?? 0,
      transitMode: _transitModeFromString(json['transit_mode'] as String?),
      lineCode: json['line_code'] as String?,
      lineColor: json['line_color'] as String?,
    );
  }

  static RideStatus _statusFromString(String? value) {
    return RideStatus.values.firstWhere(
      (status) => status.name == _camelCase(value ?? ''),
      orElse: () => RideStatus.scheduled,
    );
  }

  static TransitMode _transitModeFromString(String? value) {
    return TransitMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => TransitMode.bus,
    );
  }

  static String _camelCase(String snakeCase) {
    final parts = snakeCase.split('_');
    if (parts.isEmpty) return snakeCase;
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1)).join();
  }

  static int _safetyScoreToPercent(num? score) {
    if (score == null) return 0;
    return ((score.toDouble() / 5) * 100).round().clamp(0, 100);
  }
}
