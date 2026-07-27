import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsrmRepository {
  final http.Client _client;

  OsrmRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    try {
      // OSRM expects {longitude},{latitude};{longitude},{latitude}
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );
      debugPrint('OSRM requesting: $url');

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 14; Commuter App) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Accept': 'application/json',
        },
      );

      debugPrint('OSRM response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>? ?? [];
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'] as Map<String, dynamic>? ?? {};
          final coordinates = geometry['coordinates'] as List<dynamic>? ?? [];

          return coordinates.map((coord) {
            final lon = (coord[0] as num).toDouble();
            final lat = (coord[1] as num).toDouble();
            return LatLng(lat, lon);
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('OsrmRepository error: $e');
    }

    // Fallback to straight line if routing fails
    return [start, end];
  }
}
