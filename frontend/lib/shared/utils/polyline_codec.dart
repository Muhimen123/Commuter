import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Decodes a Google-encoded polyline string into a [List<LatLng>].
///
/// Implements the algorithm described at:
/// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
///
/// Shared so any feature that persists a route as an encoded polyline (e.g.
/// a [Journey]) can reconstruct its points without depending on the map
/// feature's data layer.
List<LatLng> decodePolyline(String encoded) {
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
