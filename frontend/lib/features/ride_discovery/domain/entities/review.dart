class Review {
  final String id;
  final String reviewerName;
  final double rating;
  final String? text;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.reviewerName,
    required this.rating,
    this.text,
    required this.createdAt,
  });
}
