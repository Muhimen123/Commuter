class PostRideSurvey {
  final String journeyId;
  final double? farePaid;
  final String fareType; // 'regular' | 'student'
  final double? rideRating; // 0.0–5.0
  final double? safetyRating; // 0.0–5.0
  final String? feedbackText;
  final DateTime createdAt;

  const PostRideSurvey({
    required this.journeyId,
    this.farePaid,
    this.fareType = 'regular',
    this.rideRating,
    this.safetyRating,
    this.feedbackText,
    required this.createdAt,
  });
}