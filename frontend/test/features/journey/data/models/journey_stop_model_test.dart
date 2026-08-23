import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/journey/data/models/journey_stop_model.dart';

void main() {
  const row = {
    'id': '22222222-2222-2222-2222-222222222222',
    'journey_id': '11111111-1111-1111-1111-111111111111',
    'stop_name': 'Farmgate',
    'latitude': 23.7566,
    'longitude': 90.3957,
    'sequence_order': 1,
    'added_at': '2025-01-01T10:05:00.000Z',
  };

  group('JourneyStopModel.fromJson', () {
    test('parses a full stop row (snake_case -> camelCase)', () {
      final stop = JourneyStopModel.fromJson(row);

      expect(stop.id, '22222222-2222-2222-2222-222222222222');
      expect(stop.journeyId, '11111111-1111-1111-1111-111111111111');
      expect(stop.stopName, 'Farmgate');
      expect(stop.latitude, 23.7566);
      expect(stop.longitude, 90.3957);
      expect(stop.sequenceOrder, 1);
      expect(stop.addedAt, DateTime.parse('2025-01-01T10:05:00.000Z'));
    });

    test('coerces integer-valued JSON numbers to double', () {
      final stop = JourneyStopModel.fromJson({
        ...row,
        'latitude': 23,
        'longitude': 90,
      });
      expect(stop.latitude, 23.0);
      expect(stop.longitude, 90.0);
    });

    test('accepts a null stop_name', () {
      final stop = JourneyStopModel.fromJson({...row, 'stop_name': null});
      expect(stop.stopName, isNull);
    });

    test('isFirst is true for sequence_order 1', () {
      expect(JourneyStopModel.fromJson(row).isFirst, isTrue);
      expect(
        JourneyStopModel.fromJson({...row, 'sequence_order': 2}).isFirst,
        isFalse,
      );
    });
  });

  group('JourneyStopModel.toJson', () {
    test('produces the snake_case insert payload', () {
      final json = JourneyStopModel.fromJson(row).toJson();

      expect(json['journey_id'], '11111111-1111-1111-1111-111111111111');
      expect(json['stop_name'], 'Farmgate');
      expect(json['latitude'], 23.7566);
      expect(json['longitude'], 90.3957);
      expect(json['sequence_order'], 1);
    });

    test('excludes server-generated fields from the payload', () {
      final json = JourneyStopModel.fromJson(row).toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('added_at'), isFalse);
    });
  });
}
