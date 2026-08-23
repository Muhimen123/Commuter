import '../../domain/entities/journey.dart';
import '../../domain/entities/journey_status.dart';

class JourneyModel extends Journey {
  const JourneyModel({
    required super.id,
    required super.userId,
    required super.routeId,
    required super.originName,
    required super.originPlaceId,
    required super.originLatitude,
    required super.originLongitude,
    required super.destinationName,
    required super.destinationPlaceId,
    required super.destinationLatitude,
    required super.destinationLongitude,
    required super.routePolyline,
    required super.status,
    required super.liveTrackingEnabled,
    required super.distanceKm,
    required super.startedAt,
    required super.endedAt,
    required super.createdAt,
    required super.stops,
  });

  factory JourneyModel.fromJson(Map<String, dynamic> json) {
    return JourneyModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      routeId: json['route_id'] as String?,
      originName: json['origin_name'] as String?,
      originPlaceId: json['origin_place_id'] as String?,
      originLatitude: (json['origin_latitude'] as num).toDouble(),
      originLongitude: (json['origin_longitude'] as num).toDouble(),
      destinationName: json['destination_name'] as String?,
      destinationPlaceId: json['destination_place_id'] as String?,
      destinationLatitude: (json['destination_latitude'] as num?)?.toDouble(),
      destinationLongitude: (json['destination_longitude'] as num?)?.toDouble(),
      routePolyline: json['route_polyline'] as String?,
      status: JourneyStatus.fromString(json['status'] as String?),
      liveTrackingEnabled: (json['live_tracking_enabled'] as bool?) ?? true,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      stops: const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'route_id': routeId,
        'origin_name': originName,
        'origin_place_id': originPlaceId,
        'origin_latitude': originLatitude,
        'origin_longitude': originLongitude,
        'destination_name': destinationName,
        'destination_place_id': destinationPlaceId,
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'route_polyline': routePolyline,
        'live_tracking_enabled': liveTrackingEnabled,
        'distance_km': distanceKm,
      };
}
