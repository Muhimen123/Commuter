import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/features/journey/domain/ride_simulator.dart';

void main() {
  group('RideSimulator', () {
    test('starts at the first route point with zero progress', () {
      final simulator = RideSimulator(
        route: const [LatLng(0, 0), LatLng(0, 1)],
      );

      expect(simulator.position.value, const LatLng(0, 0));
      expect(simulator.progress.value, 0.0);
      expect(simulator.isRunning, isFalse);
      expect(simulator.isComplete, isFalse);

      simulator.dispose();
    });

    test('advances toward the destination and reports progress', () async {
      final simulator = RideSimulator(
        route: const [LatLng(0, 0), LatLng(0, 0.01)],
        speedKmh: 500, // fast, so the test completes quickly
        tickInterval: const Duration(milliseconds: 20),
      );

      simulator.start();
      await Future<void>.delayed(const Duration(milliseconds: 45));
      simulator.stop();

      expect(simulator.progress.value, greaterThan(0.0));
      expect(simulator.position.value.longitude, greaterThan(0.0));
      expect(simulator.position.value.latitude, closeTo(0, 1e-9));

      simulator.dispose();
    });

    test('completes at the destination and calls onComplete once', () async {
      var completeCount = 0;
      final simulator = RideSimulator(
        route: const [LatLng(0, 0), LatLng(0, 0.001)],
        speedKmh: 5000,
        tickInterval: const Duration(milliseconds: 10),
        onComplete: () => completeCount++,
      );

      simulator.start();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(simulator.isComplete, isTrue);
      expect(simulator.isRunning, isFalse);
      expect(simulator.progress.value, 1.0);
      expect(simulator.position.value, const LatLng(0, 0.001));
      expect(completeCount, 1);

      // start() after completion is a no-op.
      simulator.start();
      expect(simulator.isRunning, isFalse);

      simulator.dispose();
    });

    test('a zero-length route (origin == destination) completes immediately',
        () {
      var completed = false;
      final simulator = RideSimulator(
        route: const [LatLng(1, 1), LatLng(1, 1)],
        onComplete: () => completed = true,
      );

      simulator.start();

      expect(simulator.isComplete, isTrue);
      expect(completed, isTrue);

      simulator.dispose();
    });
  });
}
