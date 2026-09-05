class RouteStop {
  final String id;
  final String stopName;
  final double latitude;
  final double longitude;
  final int sequenceOrder;
  final String? platformNumber;

  const RouteStop({
    required this.id,
    required this.stopName,
    required this.latitude,
    required this.longitude,
    required this.sequenceOrder,
    this.platformNumber,
  });
}
