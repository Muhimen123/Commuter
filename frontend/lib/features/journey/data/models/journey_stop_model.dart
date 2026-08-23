import '../../domain/entities/journey_stop.dart';

class JourneyStopModel extends JourneyStop {
  const JourneyStopModel({
    required super.id,
    required super.journeyId,
    required super.stopName,
    required super.latitude,
    required super.longitude,
    required super.sequenceOrder,
    required super.addedAt,
  });

  factory JourneyStopModel.fromJson(Map<String, dynamic> json) {
    return JourneyStopModel(
      id: json['id'] as String,
      journeyId: json['journey_id'] as String,
      stopName: json['stop_name'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      sequenceOrder: (json['sequence_order'] as num).toInt(),
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'journey_id': journeyId,
        'stop_name': stopName,
        'latitude': latitude,
        'longitude': longitude,
        'sequence_order': sequenceOrder,
      };
}
