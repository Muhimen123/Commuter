import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/journey/data/repositories/supabase_journey_repository.dart';
import 'package:frontend/features/journey/domain/entities/journey.dart';
import 'package:frontend/features/journey/domain/entities/journey_status.dart';
import 'package:frontend/features/journey/domain/entities/journey_stop.dart';
import 'package:frontend/features/journey/domain/journey_notifier.dart';
import 'package:frontend/features/journey/domain/repositories/journey_repository.dart';

Journey _journey({
  String id = 'journey-1',
  JourneyStatus status = JourneyStatus.active,
  List<JourneyStop> stops = const [],
}) {
  return Journey(
    id: id,
    userId: kDevUserId,
    originLatitude: 23.7937,
    originLongitude: 90.4066,
    originName: 'Banani',
    destinationName: 'Motijheel',
    destinationLatitude: 23.7333,
    destinationLongitude: 90.4224,
    routePolyline: '_p~iF~ps|U',
    distanceKm: 8.42,
    status: status,
    liveTrackingEnabled: true,
    startedAt: DateTime.utc(2025, 1, 1, 10),
    createdAt: DateTime.utc(2025, 1, 1, 10),
    stops: stops,
  );
}

JourneyStop _stop({String id = 'stop-1', int sequenceOrder = 1}) {
  return JourneyStop(
    id: id,
    journeyId: 'journey-1',
    stopName: 'Farmgate',
    latitude: 23.7566,
    longitude: 90.3957,
    sequenceOrder: sequenceOrder,
    addedAt: DateTime.utc(2025, 1, 1, 10, 5),
  );
}

class _FakeJourneyRepository implements JourneyRepository {
  Journey? startReturn;
  Object? startError;
  JourneyStop? addStopReturn;
  Object? addStopError;
  Journey? finishReturn;
  Object? finishError;
  Journey? cancelReturn;
  Object? cancelError;
  Journey? activeJourneyReturn;
  Object? activeJourneyError;
  List<JourneyStop> getStopsReturn = const [];

  final List<Map<String, dynamic>> startCalls = [];
  final List<({String journeyId, String? stopName, double lat, double lon})>
      addStopCalls = [];
  final List<({String journeyId, double lat, double lon})> pingCalls = [];
  final List<String> finishCalls = [];
  final List<String> cancelCalls = [];

  @override
  Future<Journey> startJourney({
    required String userId,
    String? routeId,
    String? originName,
    String? originPlaceId,
    required double originLatitude,
    required double originLongitude,
    String? destinationName,
    String? destinationPlaceId,
    double? destinationLatitude,
    double? destinationLongitude,
    String? routePolyline,
    double? distanceKm,
    bool liveTrackingEnabled = true,
  }) async {
    startCalls.add({
      'userId': userId,
      'routeId': routeId,
      'originName': originName,
      'originPlaceId': originPlaceId,
      'originLatitude': originLatitude,
      'originLongitude': originLongitude,
      'destinationName': destinationName,
      'destinationPlaceId': destinationPlaceId,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'routePolyline': routePolyline,
      'distanceKm': distanceKm,
      'liveTrackingEnabled': liveTrackingEnabled,
    });
    if (startError != null) throw startError!;
    return startReturn ?? _journey();
  }

  @override
  Future<JourneyStop> addStop({
    required String journeyId,
    String? stopName,
    required double latitude,
    required double longitude,
  }) async {
    addStopCalls.add(
      (journeyId: journeyId, stopName: stopName, lat: latitude, lon: longitude),
    );
    if (addStopError != null) throw addStopError!;
    return addStopReturn ?? _stop();
  }

  @override
  Future<void> recordPing({
    required String journeyId,
    required double latitude,
    required double longitude,
  }) async {
    pingCalls.add((journeyId: journeyId, lat: latitude, lon: longitude));
  }

  @override
  Future<Journey> finishJourney({required String journeyId}) async {
    finishCalls.add(journeyId);
    if (finishError != null) throw finishError!;
    return finishReturn ?? _journey(id: journeyId, status: JourneyStatus.completed);
  }

  @override
  Future<Journey> cancelJourney({required String journeyId}) async {
    cancelCalls.add(journeyId);
    if (cancelError != null) throw cancelError!;
    return cancelReturn ?? _journey(id: journeyId, status: JourneyStatus.cancelled);
  }

  @override
  Future<Journey?> getActiveJourney({required String userId}) async {
    if (activeJourneyError != null) throw activeJourneyError!;
    return activeJourneyReturn;
  }

  @override
  Future<List<JourneyStop>> getStops({required String journeyId}) async {
    return getStopsReturn;
  }

  @override
  Future<List<Journey>> getHistory({required String userId}) async => [];
}

void main() {
  group('JourneyNotifier', () {
    late _FakeJourneyRepository repo;
    late ProviderContainer container;
    late JourneyNotifier notifier;

    setUp(() {
      repo = _FakeJourneyRepository();
      container = ProviderContainer(
        overrides: [journeyRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      notifier = container.read(journeyProvider.notifier);
    });

    group('startJourney', () {
      test('resolves the dev user id when no auth session is present', () async {
        await notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
          destinationName: 'Motijheel',
          routePolyline: '_p~iF~ps|U',
          distanceKm: 8.42,
        );

        expect(repo.startCalls, hasLength(1));
        expect(repo.startCalls.last['userId'], kDevUserId);
      });

      test('persists origin, destination, polyline and distance', () async {
        await notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
          originName: 'Banani',
          originPlaceId: 'ChIJ-origin',
          destinationName: 'Motijheel',
          destinationPlaceId: 'ChIJ-dest',
          destinationLatitude: 23.7333,
          destinationLongitude: 90.4224,
          routePolyline: '_p~iF~ps|U',
          distanceKm: 8.42,
        );

        final call = repo.startCalls.last;
        expect(call['originLatitude'], 23.7937);
        expect(call['originName'], 'Banani');
        expect(call['originPlaceId'], 'ChIJ-origin');
        expect(call['destinationName'], 'Motijheel');
        expect(call['destinationPlaceId'], 'ChIJ-dest');
        expect(call['routePolyline'], '_p~iF~ps|U');
        expect(call['distanceKm'], 8.42);
      });

      test('stores the returned journey and clears isStarting', () async {
        final future = notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
        );
        expect(container.read(journeyProvider).isStarting, isTrue);

        final journey = await future;

        expect(journey, isNotNull);
        final state = container.read(journeyProvider);
        expect(state.isStarting, isFalse);
        expect(state.hasActiveJourney, isTrue);
        expect(state.activeJourney!.id, 'journey-1');
      });

      test('captures an error and returns null on failure', () async {
        repo.startError = Exception('network down');

        final journey = await notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
        );

        expect(journey, isNull);
        final state = container.read(journeyProvider);
        expect(state.isStarting, isFalse);
        expect(state.hasActiveJourney, isFalse);
        expect(state.error, isNotNull);
      });
    });

    group('addStop', () {
      test('returns null when there is no active journey', () async {
        final stop = await notifier.addStop(latitude: 23.7566, longitude: 90.3957);
        expect(stop, isNull);
        expect(repo.addStopCalls, isEmpty);
      });

      test('appends the stop to the active journey', () async {
        await notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
        );

        final stop = await notifier.addStop(
          stopName: 'Farmgate',
          latitude: 23.7566,
          longitude: 90.3957,
        );

        expect(stop, isNotNull);
        expect(repo.addStopCalls.last.journeyId, 'journey-1');
        expect(repo.addStopCalls.last.stopName, 'Farmgate');
        final journey = container.read(journeyProvider).activeJourney!;
        expect(journey.stops, hasLength(1));
        expect(journey.stops.last.id, stop!.id);
      });

      test('preserves stop order across multiple additions', () async {
        await notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
        );

        repo.addStopReturn = _stop(id: 'stop-1', sequenceOrder: 1);
        await notifier.addStop(latitude: 23.7, longitude: 90.3);
        repo.addStopReturn = _stop(id: 'stop-2', sequenceOrder: 2);
        await notifier.addStop(latitude: 23.6, longitude: 90.2);

        final stops = container.read(journeyProvider).activeJourney!.stops;
        expect(stops.map((s) => s.id), ['stop-1', 'stop-2']);
        expect(stops.map((s) => s.sequenceOrder), [1, 2]);
      });

      test('returns null and sets error on failure', () async {
        await notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
        );
        repo.addStopError = Exception('rpc failed');

        final stop = await notifier.addStop(latitude: 23.7, longitude: 90.3);

        expect(stop, isNull);
        final state = container.read(journeyProvider);
        expect(state.isAddingStop, isFalse);
        expect(state.error, isNotNull);
      });
    });

    group('endJourney', () {
      test('returns false when there is no active journey', () async {
        expect(await notifier.endJourney(), isFalse);
        expect(repo.finishCalls, isEmpty);
      });

      test('finishes the journey via the RPC and clears state', () async {
        await notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
        );

        final success = await notifier.endJourney();

        expect(success, isTrue);
        expect(repo.finishCalls, ['journey-1']);
        final state = container.read(journeyProvider);
        expect(state.hasActiveJourney, isFalse);
        expect(state.activeJourney, isNull);
      });

      test('returns false on failure and keeps the journey active', () async {
        await notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
        );
        repo.finishError = Exception('rpc failed');

        final success = await notifier.endJourney();

        expect(success, isFalse);
        expect(repo.finishCalls, ['journey-1']);
        final state = container.read(journeyProvider);
        expect(state.isEnding, isFalse);
        expect(state.hasActiveJourney, isTrue);
        expect(state.error, isNotNull);
      });
    });

    group('cancelJourney', () {
      test('returns false when there is no active journey', () async {
        expect(await notifier.cancelJourney(), isFalse);
        expect(repo.cancelCalls, isEmpty);
      });

      test('cancels the journey and clears state', () async {
        await notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
        );

        final success = await notifier.cancelJourney();

        expect(success, isTrue);
        expect(repo.cancelCalls, ['journey-1']);
        expect(container.read(journeyProvider).hasActiveJourney, isFalse);
      });
    });

    group('resume', () {
      test('returns null and keeps a clean state when none is active',
          () async {
        repo.activeJourneyReturn = null;

        final journey = await notifier.resume();

        expect(journey, isNull);
        expect(container.read(journeyProvider).hasActiveJourney, isFalse);
      });

      test('restores the active journey from the repository', () async {
        repo.activeJourneyReturn = _journey(stops: [_stop()]);

        final journey = await notifier.resume();

        expect(journey, isNotNull);
        final state = container.read(journeyProvider);
        expect(state.hasActiveJourney, isTrue);
        expect(state.isResuming, isFalse);
        expect(state.activeJourney!.stops, hasLength(1));
      });

      test('returns the existing journey without refetching if already active',
          () async {
        await notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
        );

        final journey = await notifier.resume();

        expect(journey, isNotNull);
        expect(repo.startCalls, hasLength(1));
        expect(repo.activeJourneyReturn, isNull); // never consulted
      });
    });

    group('clearError', () {
      test('clears a previously set error', () async {
        repo.startError = Exception('boom');
        await notifier.startJourney(
          originLatitude: 23.7937,
          originLongitude: 90.4066,
        );
        expect(container.read(journeyProvider).error, isNotNull);

        notifier.clearError();

        expect(container.read(journeyProvider).error, isNull);
      });
    });
  });
}
