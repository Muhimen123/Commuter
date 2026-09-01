import '../entities/incident_report.dart';

abstract class IncidentReportRepository {
  Future<IncidentReport> submit({
    required String? userId,
    String? locationText,
    double? latitude,
    double? longitude,
    required int lightingRating,
    required int publicVisibilityRating,
    required int crowdDensityRating,
    required int securityPresenceRating,
    required int harassmentFrequencyRating,
    required int theftFrequencyRating,
    required int overallSafetyRating,
    String? notes,
  });
}
