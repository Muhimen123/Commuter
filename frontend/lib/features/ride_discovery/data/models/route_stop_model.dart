import '../../domain/entities/route_stop.dart';

class RouteStopModel extends RouteStop {
  const RouteStopModel({
    required super.id,
    required super.stopName,
    required super.latitude,
    required super.longitude,
    required super.sequenceOrder,
    super.platformNumber,
  });

  factory RouteStopModel.fromJson(Map<String, dynamic> json) {
    return RouteStopModel(
      id: json['id'] as String,
      stopName: json['stop_name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      sequenceOrder: (json['sequence_order'] as num).toInt(),
      platformNumber: json['platform_number'] as String?,
    );
  }
}
