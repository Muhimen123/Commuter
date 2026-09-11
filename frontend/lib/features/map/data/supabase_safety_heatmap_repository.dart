import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/safety_point.dart';
import 'mock_safety_heatmap_repository.dart';

class SupabaseSafetyHeatmapRepository implements SafetyHeatmapRepository {
  final SupabaseClient _client;

  SupabaseSafetyHeatmapRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<SafetyPoint>> getSafetyPoints({required LatLng center}) async {
    try {
      // Query the safety_heatmap_points table.
      // We could also query the aggregated view if points are too dense.
      final response = await _client
          .from('safety_heatmap_points')
          .select('latitude, longitude, safety_score');

      return (response as List).map((row) {
        return SafetyPoint(
          latitude: (row['latitude'] as num).toDouble(),
          longitude: (row['longitude'] as num).toDouble(),
          score: (row['safety_score'] as num).toDouble(),
          reportCount: 1, // Individual point
        );
      }).toList();
    } catch (e) {
      // Fallback to empty list or handle error
      return [];
    }
  }
}
