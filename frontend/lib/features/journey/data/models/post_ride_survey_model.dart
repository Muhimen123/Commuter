import '../../domain/entities/post_ride_survey.dart';

class PostRideSurveyModel extends PostRideSurvey {
  const PostRideSurveyModel({
    required super.journeyId,
    super.farePaid,
    super.fareType,
    super.rideRating,
    super.safetyRating,
    super.feedbackText,
    required super.createdAt,
  });

  factory PostRideSurveyModel.fromJson(Map<String, dynamic> json) {
    return PostRideSurveyModel(
      journeyId: json['journey_id'] as String,
      farePaid: (json['fare_paid'] as num?)?.toDouble(),
      fareType: json['fare_type'] as String? ?? 'regular',
      rideRating: (json['ride_rating'] as num?)?.toDouble(),
      safetyRating: (json['safety_rating'] as num?)?.toDouble(),
      feedbackText: json['feedback_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'journey_id': journeyId,
        'fare_paid': farePaid,
        'fare_type': fareType,
        'ride_rating': rideRating,
        'safety_rating': safetyRating,
        'feedback_text': feedbackText,
      };
}
