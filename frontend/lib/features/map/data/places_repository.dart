import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// A location suggestion returned by the Google Places API.
class LocationSuggestion {
  final String name;
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final double lat;
  final double lon;

  const LocationSuggestion({
    required this.name,
    this.street,
    this.city,
    this.state,
    this.country,
    required this.lat,
    required this.lon,
  });

  /// Formatted display string, e.g. "Gulshan, Dhaka, Bangladesh".
  String get displayName {
    final parts = <String>[];
    if (name.isNotEmpty) parts.add(name);
    if (street != null && street!.isNotEmpty && street != name) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}

/// Repository for location search using the Google Places API.
///
/// Uses the legacy Places API endpoints:
/// - Place Autocomplete  → search suggestions
/// - Place Details       → lat/lng for a selected place
class PlacesRepository {
  final http.Client _client;

  PlacesRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches location suggestions matching [query] via Google Places Autocomplete.
  ///
  /// If [center] is provided, results are biased toward that location for
  /// more relevant local suggestions.
  Future<List<LocationSuggestion>> fetchSuggestions(
    String query, {
    int limit = 5,
    LatLng? center,
  }) async {
    if (query.trim().isEmpty) return [];

    final apiKey = googleMapsApiKey;
    if (apiKey.isEmpty) {
      debugPrint('PlacesRepository: No Google Maps API key set');
      return [];
    }

    try {
      var urlStr = StringBuffer(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&limit=$limit'
        '&key=$apiKey',
      );

      // Add location bias if we have a center (radius in meters, ~20km).
      if (center != null) {
        urlStr.write('&location=${center.latitude},${center.longitude}');
        urlStr.write('&radius=20000');
      }

      final url = Uri.parse(urlStr.toString());

      debugPrint('Places Autocomplete requesting: $url');
      final response = await _client.get(url);
      debugPrint('Places Autocomplete response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String? ?? '';

        if (status == 'OK' || status == 'ZERO_RESULTS') {
          final predictions = data['predictions'] as List<dynamic>? ?? [];
          final results = <LocationSuggestion>[];

          // Fetch first [limit] results in parallel batches
          final batch = predictions.take(limit).toList();
          if (batch.isEmpty) return [];

          final futures = batch.map((p) => _placeDetailsToSuggestion(p as Map<String, dynamic>));
          final suggestions = await Future.wait(futures);

          for (final s in suggestions) {
            if (s != null) results.add(s);
          }

          return results;
        } else {
          debugPrint('Places API error status: $status');
        }
      }
    } catch (e) {
      debugPrint('PlacesRepository error: $e');
    }

    return [];
  }

  /// Fetches place details (lat/lng + address components) for a prediction
  /// and returns a [LocationSuggestion].
  Future<LocationSuggestion?> _placeDetailsToSuggestion(
    Map<String, dynamic> prediction,
  ) async {
    final placeId = prediction['place_id'] as String? ?? '';
    final description = prediction['description'] as String? ?? '';

    if (placeId.isEmpty) return null;

    final apiKey = googleMapsApiKey;

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry,address_component'
        '&key=$apiKey',
      );

      final response = await _client.get(url);
      if (response.statusCode != 200) {
        return LocationSuggestion(name: description, lat: 0, lon: 0);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>? ?? {};
      final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
      final location = geometry['location'] as Map<String, dynamic>? ?? {};

      final lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
      final lng = (location['lng'] as num?)?.toDouble() ?? 0.0;

      // Extract address components
      final components = result['address_components'] as List<dynamic>? ?? [];
      String? street, city, state, country;

      for (final c in components) {
        final types = (c as Map<String, dynamic>)['types'] as List<dynamic>? ?? [];
        final longName = c['long_name'] as String? ?? '';
        if (types.contains('route')) street = longName;
        if (types.contains('locality') || types.contains('administrative_area_level_3')) {
          city = longName;
        }
        if (types.contains('administrative_area_level_1')) state = longName;
        if (types.contains('country')) country = longName;
      }

      return LocationSuggestion(
        name: description.split(',').first.trim(),
        street: street,
        city: city,
        state: state,
        country: country,
        lat: lat,
        lon: lng,
      );
    } catch (e) {
      debugPrint('PlaceDetails error: $e');
      return LocationSuggestion(name: description, lat: 0, lon: 0);
    }
  }
}