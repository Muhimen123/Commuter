import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Result of a Google Directions API route request.
class DirectionsResult {
  final List<LatLng> points;
  final String? polyline;
  final double? distanceKm;

  const DirectionsResult({
    required this.points,
    this.polyline,
    this.distanceKm,
  });
}

/// Google Directions API client.
///
/// Fetches a driving route between two [LatLng] points and decodes the
/// returned polyline into a [List<LatLng>].
class DirectionsRepository {
  final http.Client _client;

  DirectionsRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches a driving route from [start] to [end] via the Google Directions API.
  ///
  /// Returns a [DirectionsResult] with the decoded polyline [points], the
  /// encoded [polyline] string, and the route [distanceKm]. On failure,
  /// returns a straight-line result with null polyline/distance.
  Future<DirectionsResult> fetchRoute(LatLng start, LatLng end) async {
    try {
      final apiKey = googleMapsApiKey;
      if (apiKey.isEmpty) {
        debugPrint('DirectionsRepository: No Google Maps API key set');
        return DirectionsResult(points: [start, end]);
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${start.latitude},${start.longitude}'
        '&destination=${end.latitude},${end.longitude}'
        '&mode=driving'
        '&key=$apiKey',
      );

      debugPrint('Directions requesting: $url');

      final response = await _client.get(url);
      debugPrint('Directions response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String? ?? '';

        if (status == 'OK') {
          final routes = data['routes'] as List<dynamic>? ?? [];
          if (routes.isNotEmpty) {
            final route = routes[0] as Map<String, dynamic>;
            final overviewPolyline =
                route['overview_polyline'] as Map<String, dynamic>? ?? {};
            final encodedPoints = overviewPolyline['points'] as String? ?? '';

            if (encodedPoints.isNotEmpty) {
              final legs = route['legs'] as List<dynamic>? ?? [];
              final distanceMeters = legs.isNotEmpty
                  ? legs[0]['distance'] as Map<String, dynamic>?
                  : null;
              final distanceValue =
                  (distanceMeters?['value'] as num?)?.toDouble();

              return DirectionsResult(
                points: _decodePolyline(encodedPoints),
                polyline: encodedPoints,
                distanceKm:
                    distanceValue == null ? null : distanceValue / 1000,
              );
            }
          }
        } else {
          debugPrint('Directions API error status: $status');
        }
      }
    } catch (e) {
      debugPrint('DirectionsRepository error: $e');
    }

    return DirectionsResult(points: [start, end]);
  }

  /// Decodes a Google-encoded polyline string into a [List<LatLng>].
  ///
  /// Implements the algorithm described at:
  /// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    final len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}

