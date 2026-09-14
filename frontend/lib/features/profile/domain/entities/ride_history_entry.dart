/// Mirrors `journey_status_enum` in the database schema.
enum RideHistoryStatus { active, completed, cancelled }

/// A single past ride, for the Profile page's "Ride History" list.
class RideHistoryEntry {
  final String id;
  final String routeLabel;
  final String? destinationName;
  final DateTime startedAt;
  final double? farePaid;
  final RideHistoryStatus status;

  const RideHistoryEntry({
    required this.id,
    required this.routeLabel,
    required this.destinationName,
    required this.startedAt,
    required this.farePaid,
    required this.status,
  });
}
