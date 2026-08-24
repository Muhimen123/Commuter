import '../entities/journey.dart';
import '../entities/journey_stop.dart';
import '../entities/post_ride_survey.dart';

abstract class JourneyRepository {
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
  });

  Future<JourneyStop> addStop({
    required String journeyId,
    String? stopName,
    required double latitude,
    required double longitude,
  });

  Future<void> recordPing({
    required String journeyId,
    required double latitude,
    required double longitude,
  });

  Future<Journey> finishJourney({required String journeyId});

  Future<Journey> cancelJourney({required String journeyId});

  Future<PostRideSurvey> submitSurvey({
    required String journeyId,
    double? farePaid,
    String fareType = 'regular',
    double? rideRating,
    double? safetyRating,
    String? feedbackText,
  });

  Future<Journey?> getActiveJourney({required String userId});

  Future<List<JourneyStop>> getStops({required String journeyId});

  Future<List<Journey>> getHistory({required String userId});
}
