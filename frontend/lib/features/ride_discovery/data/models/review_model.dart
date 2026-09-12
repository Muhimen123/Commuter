import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.reviewerName,
    required super.rating,
    super.text,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final journey = json['journeys'] as Map<String, dynamic>?;
    final reviewer = journey?['users'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'] as String,
      reviewerName: (reviewer?['full_name'] as String?) ?? 'Anonymous',
      rating: (json['ride_rating'] as num).toDouble(),
      text: json['feedback_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
