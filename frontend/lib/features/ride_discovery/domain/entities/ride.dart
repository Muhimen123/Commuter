enum RideStatus { arriving, scheduled, delayed }

class Ride {
  final String id;
  final String routeNumber;
  final String routeName;
  final String via;
  final String arrivalTime;
  final RideStatus status;
  final double rating;
  final int reviewCount;
  final int safetyScore;
  final double fare;
  final bool isRecommended;
  final String? alertMessage;

  const Ride({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    required this.via,
    required this.arrivalTime,
    required this.status,
    required this.rating,
    required this.reviewCount,
    required this.safetyScore,
    required this.fare,
    this.isRecommended = false,
    this.alertMessage,
  });
}
