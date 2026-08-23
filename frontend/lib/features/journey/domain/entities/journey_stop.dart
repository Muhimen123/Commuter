class JourneyStop {
  final String id;
  final String journeyId;
  final String? stopName;
  final double latitude;
  final double longitude;
  final int sequenceOrder;
  final DateTime addedAt;

  const JourneyStop({
    required this.id,
    required this.journeyId,
    this.stopName,
    required this.latitude,
    required this.longitude,
    required this.sequenceOrder,
    required this.addedAt,
  });

  bool get isFirst => sequenceOrder == 1;
}
