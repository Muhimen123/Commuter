enum RideStatus { scheduled, arriving, inTransit, delayed, cancelled }

enum TransitMode { bus, metro, train }

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
  final TransitMode transitMode;
  final String? lineCode;
  final String? lineColor;

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
    this.transitMode = TransitMode.bus,
    this.lineCode,
    this.lineColor,
  });
}
