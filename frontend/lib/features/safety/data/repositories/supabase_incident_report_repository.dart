import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:frontend/features/auth/domain/auth_notifier.dart';
import '../../domain/entities/incident_report.dart';
import '../../domain/repositories/incident_report_repository.dart';
import '../models/incident_report_model.dart';

// Must match the dev user seeded in supabase/seed.sql — mirrors the same
// placeholder used in incident_report_page.dart until real Supabase Auth
// lands and every report reliably has a real user_id.
const String _kDevUserId = '00000000-0000-0000-0000-000000000001';

final incidentReportRepositoryProvider = Provider<IncidentReportRepository>((ref) {
  return SupabaseIncidentReportRepository();
});

/// The current user's own submitted incident reports, newest first.
final incidentReportHistoryProvider =
    FutureProvider.autoDispose<List<IncidentReport>>((ref) async {
  final userId = ref.watch(authProvider).valueOrNull?.id ?? _kDevUserId;
  return ref.read(incidentReportRepositoryProvider).getHistory(userId: userId);
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

  @override
  Future<List<IncidentReport>> getHistory({required String userId}) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows
        .map((row) => IncidentReportModel.fromJson(row))
        .toList(growable: false);
  }
}
