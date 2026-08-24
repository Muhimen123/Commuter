import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/incident_report.dart';
import '../../domain/repositories/incident_report_repository.dart';
import '../models/incident_report_model.dart';

final incidentReportRepositoryProvider = Provider<IncidentReportRepository>((ref) {
  return SupabaseIncidentReportRepository();
});

class SupabaseIncidentReportRepository implements IncidentReportRepository {
  static const _table = 'incident_reports';

  final SupabaseClient _client;

  SupabaseIncidentReportRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
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
  }) async {
    final payload = <String, dynamic>{
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

    final row = await _client.from(_table).insert(payload).select().single();
    return IncidentReportModel.fromJson(row);
  }
}
