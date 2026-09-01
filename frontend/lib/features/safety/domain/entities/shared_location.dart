import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a live location shared by someone else (from active_shares_with_me view).
class SharedLocation {
  final String shareId;
  final String sharerId;
  final String sharerName;
  final String? sharerPhoto;
  final String? journeyId;
  final double? latitude;
  final double? longitude;
  final DateTime? lastPingAt;

  const SharedLocation({
    required this.shareId,
    required this.sharerId,
    required this.sharerName,
    this.sharerPhoto,
    this.journeyId,
    this.latitude,
    this.longitude,
    this.lastPingAt,
  });

  factory SharedLocation.fromMap(Map<String, dynamic> map) {
    return SharedLocation(
      shareId: map['share_id'],
      sharerId: map['sharer_id'],
      sharerName: map['sharer_name'],
      sharerPhoto: map['sharer_photo'],
      journeyId: map['journey_id'],
      latitude: (map['last_lat'] as num?)?.toDouble(),
      longitude: (map['last_lng'] as num?)?.toDouble(),
      lastPingAt: map['last_ping_at'] != null 
          ? DateTime.parse(map['last_ping_at']) 
          : null,
    );
  }

  LatLng? get position {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }
}
