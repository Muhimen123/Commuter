import '../../domain/entities/incident_report.dart';

class IncidentReportModel extends IncidentReport {
  const IncidentReportModel({
    required super.id,
    required super.userId,
    required super.locationText,
    required super.latitude,
    required super.longitude,
    required super.lightingRating,
    required super.publicVisibilityRating,
    required super.crowdDensityRating,
    required super.securityPresenceRating,
    required super.harassmentFrequencyRating,
    required super.theftFrequencyRating,
    required super.overallSafetyRating,
    required super.notes,
    required super.createdAt,
  });

  factory IncidentReportModel.fromJson(Map<String, dynamic> json) {
    return IncidentReportModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      locationText: json['location_text'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      lightingRating: json['lighting_rating'] as int,
      publicVisibilityRating: json['public_visibility_rating'] as int,
      crowdDensityRating: json['crowd_density_rating'] as int,
      securityPresenceRating: json['security_presence_rating'] as int,
      harassmentFrequencyRating: json['harassment_frequency_rating'] as int,
      theftFrequencyRating: json['theft_frequency_rating'] as int,
      overallSafetyRating: json['overall_safety_rating'] as int,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'user_id': userId,
        'location_text': locationText,
        'latitude': latitude,
        'longitude': longitude,
        'lighting_rating': lightingRating,
        'public_visibility_rating': publicVisibilityRating,
        'crowd_density_rating': crowdDensityRating,
        'security_presence_rating': securityPresenceRating,
        'harassment_frequency_rating': harassmentFrequencyRating,
        'theft_frequency_rating': theftFrequencyRating,
        'overall_safety_rating': overallSafetyRating,
        'notes': notes,
      };
}
