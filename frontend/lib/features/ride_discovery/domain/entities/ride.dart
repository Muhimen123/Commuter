enum RideStatus { arriving, scheduled, delayed }

class Ride {
  final String id;
  final String routeNumber;
  final String routeName;
  final String destination;
  final String via;
  final RideStatus status;
  final double rating;
  final int reviewCount;
  final int safetyScore;
  final double fare;
  final bool isRecommended;

  const Ride({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    required this.destination,
    required this.via,
    required this.status,
    required this.rating,
    required this.reviewCount,
    required this.safetyScore,
    required this.fare,
    this.isRecommended = false,
  });
}
