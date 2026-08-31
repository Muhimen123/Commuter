import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'entities/journey.dart';

class JourneyState {
  final Journey? activeJourney;
  final bool isResuming;
  final bool isStarting;
  final bool isAddingStop;
  final bool isEnding;
  final bool isCancelling;
  final bool isSubmittingSurvey;
  final String? error;

  /// Set while a [RideSimulator] is driving this journey's location pings
  /// instead of real GPS. Null when simulation isn't active.
  final LatLng? simulatedPosition;

  const JourneyState({
    this.activeJourney,
    this.isResuming = false,
    this.isStarting = false,
    this.isAddingStop = false,
    this.isEnding = false,
    this.isCancelling = false,
    this.isSubmittingSurvey = false,
    this.error,
    this.simulatedPosition,
  });

  bool get hasActiveJourney => activeJourney?.isActive ?? false;
  bool get isSimulating => simulatedPosition != null;

  JourneyState copyWith({
    Journey? activeJourney,
    bool? isResuming,
    bool? isStarting,
    bool? isAddingStop,
    bool? isEnding,
    bool? isCancelling,
    bool? isSubmittingSurvey,
    String? error,
    bool clearError = false,
    LatLng? simulatedPosition,
    bool clearSimulatedPosition = false,
  }) {
    return JourneyState(
      activeJourney: activeJourney ?? this.activeJourney,
      isResuming: isResuming ?? this.isResuming,
      isStarting: isStarting ?? this.isStarting,
      isAddingStop: isAddingStop ?? this.isAddingStop,
      isEnding: isEnding ?? this.isEnding,
      isCancelling: isCancelling ?? this.isCancelling,
      isSubmittingSurvey: isSubmittingSurvey ?? this.isSubmittingSurvey,
      error: clearError ? null : (error ?? this.error),
      simulatedPosition: clearSimulatedPosition
          ? null
          : (simulatedPosition ?? this.simulatedPosition),
    );
  }
}
