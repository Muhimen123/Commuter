import 'journey_status.dart';
import 'journey_stop.dart';

class Journey {
  final String id;
  final String userId;

  final String? routeId;

  final String? originName;
  final String? originPlaceId;
  final double originLatitude;
  final double originLongitude;

  final String? destinationName;
  final String? destinationPlaceId;
  final double? destinationLatitude;
  final double? destinationLongitude;

  final String? routePolyline;

  final JourneyStatus status;
  final bool liveTrackingEnabled;
  final double? distanceKm;

  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;

  final List<JourneyStop> stops;

  const Journey({
    required this.id,
    required this.userId,
    this.routeId,
    this.originName,
    this.originPlaceId,
    required this.originLatitude,
    required this.originLongitude,
    this.destinationName,
    this.destinationPlaceId,
    this.destinationLatitude,
    this.destinationLongitude,
    this.routePolyline,
    required this.status,
    required this.liveTrackingEnabled,
    this.distanceKm,
    required this.startedAt,
    this.endedAt,
    required this.createdAt,
    this.stops = const [],
  });

  bool get isActive => status == JourneyStatus.active;
  bool get isCompleted => status == JourneyStatus.completed;
  bool get isCancelled => status == JourneyStatus.cancelled;

  bool get hasDestination =>
      destinationLatitude != null && destinationLongitude != null;

  Journey copyWith({
    String? id,
    String? userId,
    String? routeId,
    String? originName,
    String? originPlaceId,
    double? originLatitude,
    double? originLongitude,
    String? destinationName,
    String? destinationPlaceId,
    double? destinationLatitude,
    double? destinationLongitude,
    String? routePolyline,
    JourneyStatus? status,
    bool? liveTrackingEnabled,
    double? distanceKm,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
    List<JourneyStop>? stops,
  }) {
    return Journey(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      routeId: routeId ?? this.routeId,
      originName: originName ?? this.originName,
      originPlaceId: originPlaceId ?? this.originPlaceId,
      originLatitude: originLatitude ?? this.originLatitude,
      originLongitude: originLongitude ?? this.originLongitude,
      destinationName: destinationName ?? this.destinationName,
      destinationPlaceId: destinationPlaceId ?? this.destinationPlaceId,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      routePolyline: routePolyline ?? this.routePolyline,
      status: status ?? this.status,
      liveTrackingEnabled: liveTrackingEnabled ?? this.liveTrackingEnabled,
      distanceKm: distanceKm ?? this.distanceKm,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      stops: stops ?? this.stops,
    );
  }
}
