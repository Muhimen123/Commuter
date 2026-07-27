import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  String get displayName {
    final parts = <String>[];
    if (name.isNotEmpty) parts.add(name);
    if (street != null && street!.isNotEmpty && street != name) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = (geometry['coordinates'] as List<dynamic>?) ?? [0.0, 0.0];

    return LocationSuggestion(
      name: properties['name'] ?? properties['street'] ?? 'Unknown location',
      street: properties['street'],
      city: properties['city'],
      state: properties['state'],
      country: properties['country'],
      lat: (coordinates[1] as num).toDouble(),
      lon: (coordinates[0] as num).toDouble(),
    );
  }
}

class PhotonRepository {
  final http.Client _client;

  PhotonRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<LocationSuggestion>> fetchSuggestions(String query, {int limit = 5}) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse('https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}&limit=$limit');
      debugPrint('Photon requesting: $url');
      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 14; Commuter App) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Accept': 'application/json',
        },
      );
      debugPrint('Photon response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('Photon response body length: ${response.body.length}');
        final data = json.decode(response.body) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];

        return features
            .map((f) => LocationSuggestion.fromJson(f as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('PhotonRepository error: $e');
    }

    return [];
  }
}
