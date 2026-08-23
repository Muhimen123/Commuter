import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/journey/data/models/journey_model.dart';
import 'package:frontend/features/journey/domain/entities/journey_status.dart';

Map<String, dynamic> _row({
  String id = '11111111-1111-1111-1111-111111111111',
  String userId = '00000000-0000-0000-0000-000000000001',
  Object? routeId,
  String? originName = 'Banani',
  String? originPlaceId = 'ChIJ-origin',
  double originLatitude = 23.7937,
  double originLongitude = 90.4066,
  String? destinationName = 'Motijheel',
  String? destinationPlaceId = 'ChIJ-dest',
  double? destinationLatitude = 23.7333,
  double? destinationLongitude = 90.4224,
  String? routePolyline = '_p~iF~ps|U',
  String status = 'active',
  bool liveTrackingEnabled = true,
  double? distanceKm = 8.42,
  String startedAt = '2025-01-01T10:00:00.000Z',
  String? endedAt,
  String createdAt = '2025-01-01T09:59:50.000Z',
}) {
  return {
    'id': id,
    'user_id': userId,
    'route_id': routeId,
    'origin_name': originName,
    'origin_place_id': originPlaceId,
    'origin_latitude': originLatitude,
    'origin_longitude': originLongitude,
    'destination_name': destinationName,
    'destination_place_id': destinationPlaceId,
    'destination_latitude': destinationLatitude,
    'destination_longitude': destinationLongitude,
    'route_polyline': routePolyline,
    'status': status,
    'live_tracking_enabled': liveTrackingEnabled,
    'distance_km': distanceKm,
    'started_at': startedAt,
    'ended_at': endedAt,
    'created_at': createdAt,
  };
}

void main() {
  group('JourneyModel.fromJson', () {
    test('parses a full active journey row (snake_case -> camelCase)', () {
      final journey = JourneyModel.fromJson(_row());

      expect(journey.id, '11111111-1111-1111-1111-111111111111');
      expect(journey.userId, '00000000-0000-0000-0000-000000000001');
      expect(journey.routeId, isNull);
      expect(journey.originName, 'Banani');
      expect(journey.originPlaceId, 'ChIJ-origin');
      expect(journey.originLatitude, 23.7937);
      expect(journey.originLongitude, 90.4066);
      expect(journey.destinationName, 'Motijheel');
      expect(journey.destinationPlaceId, 'ChIJ-dest');
      expect(journey.destinationLatitude, 23.7333);
      expect(journey.destinationLongitude, 90.4224);
      expect(journey.routePolyline, '_p~iF~ps|U');
      expect(journey.status, JourneyStatus.active);
      expect(journey.liveTrackingEnabled, isTrue);
      expect(journey.distanceKm, 8.42);
      expect(journey.startedAt, DateTime.parse('2025-01-01T10:00:00.000Z'));
      expect(journey.endedAt, isNull);
      expect(journey.createdAt, DateTime.parse('2025-01-01T09:59:50.000Z'));
      expect(journey.stops, isEmpty);
    });

    test('coerces integer-valued JSON numbers to double', () {
      // Postgres NUMERIC may arrive as int via JSON in some clients.
      final journey = JourneyModel.fromJson(_row(
        originLatitude: 23,
        originLongitude: 90,
        destinationLatitude: 23,
        destinationLongitude: 90,
        distanceKm: 8,
      ));
      expect(journey.originLatitude, 23.0);
      expect(journey.originLongitude, 90.0);
      expect(journey.destinationLatitude, 23.0);
      expect(journey.destinationLongitude, 90.0);
      expect(journey.distanceKm, 8.0);
    });

    test('parses completed and cancelled statuses', () {
      expect(
        JourneyModel.fromJson(_row(status: 'completed')).status,
        JourneyStatus.completed,
      );
      expect(
        JourneyModel.fromJson(_row(status: 'cancelled')).status,
        JourneyStatus.cancelled,
      );
    });

    test('parses ended_at when present', () {
      final journey = JourneyModel.fromJson(_row(
        status: 'completed',
        endedAt: '2025-01-01T10:30:00.000Z',
      ));
      expect(journey.endedAt, DateTime.parse('2025-01-01T10:30:00.000Z'));
      expect(journey.isCompleted, isTrue);
    });

    test('handles a custom journey with no destination or polyline', () {
      final journey = JourneyModel.fromJson(_row(
        destinationName: null,
        destinationPlaceId: null,
        destinationLatitude: null,
        destinationLongitude: null,
        routePolyline: null,
        distanceKm: null,
      ));
      expect(journey.hasDestination, isFalse);
      expect(journey.destinationLatitude, isNull);
      expect(journey.routePolyline, isNull);
      expect(journey.distanceKm, isNull);
    });

    test('defaults live_tracking_enabled to true when absent', () {
      final row = _row()..remove('live_tracking_enabled');
      expect(JourneyModel.fromJson(row).liveTrackingEnabled, isTrue);
    });

    test('falls back to active for an unknown status string', () {
      final journey = JourneyModel.fromJson(_row(status: 'unknown'));
      expect(journey.status, JourneyStatus.active);
    });
  });

  group('JourneyModel.toJson', () {
    test('produces the snake_case insert payload', () {
      final journey = JourneyModel.fromJson(_row());
      final json = journey.toJson();

      expect(json['user_id'], '00000000-0000-0000-0000-000000000001');
      expect(json['route_id'], isNull);
      expect(json['origin_name'], 'Banani');
      expect(json['origin_place_id'], 'ChIJ-origin');
      expect(json['origin_latitude'], 23.7937);
      expect(json['origin_longitude'], 90.4066);
      expect(json['destination_name'], 'Motijheel');
      expect(json['destination_place_id'], 'ChIJ-dest');
      expect(json['destination_latitude'], 23.7333);
      expect(json['destination_longitude'], 90.4224);
      expect(json['route_polyline'], '_p~iF~ps|U');
      expect(json['live_tracking_enabled'], isTrue);
      expect(json['distance_km'], 8.42);
    });

    test('excludes server-generated fields from the payload', () {
      final json = JourneyModel.fromJson(_row()).toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('status'), isFalse);
      expect(json.containsKey('started_at'), isFalse);
      expect(json.containsKey('ended_at'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
    });
  });

  group('Journey convenience getters', () {
    test('isActive / isCompleted / isCancelled reflect status', () {
      expect(
        JourneyModel.fromJson(_row(status: 'active')).isActive,
        isTrue,
      );
      expect(
        JourneyModel.fromJson(_row(status: 'completed')).isCompleted,
        isTrue,
      );
      expect(
        JourneyModel.fromJson(_row(status: 'cancelled')).isCancelled,
        isTrue,
      );
    });
  });
}
