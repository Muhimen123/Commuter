enum JourneyStatus {
  active,
  completed,
  cancelled;

  /// Parses the lowercase string returned by Postgres enums.
  static JourneyStatus fromString(String? value) {
    return switch (value) {
      'completed' => JourneyStatus.completed,
      'cancelled' => JourneyStatus.cancelled,
      _ => JourneyStatus.active,
    };
  }

  String get label => name;
}
