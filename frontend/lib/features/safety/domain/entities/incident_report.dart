class IncidentReport {
  final String id;
  final String? userId;
  final String? locationText;
  final double? latitude;
  final double? longitude;
  final int lightingRating;
  final int publicVisibilityRating;
  final int crowdDensityRating;
  final int securityPresenceRating;
  final int harassmentFrequencyRating;
  final int theftFrequencyRating;
  final int overallSafetyRating;
  final String? notes;
  final DateTime createdAt;

  const IncidentReport({
    required this.id,
    required this.userId,
    required this.locationText,
    required this.latitude,
    required this.longitude,
    required this.lightingRating,
    required this.publicVisibilityRating,
    required this.crowdDensityRating,
    required this.securityPresenceRating,
    required this.harassmentFrequencyRating,
    required this.theftFrequencyRating,
    required this.overallSafetyRating,
    required this.notes,
    required this.createdAt,
  });
}
