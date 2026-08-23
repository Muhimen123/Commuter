import 'entities/journey.dart';

class JourneyState {
  final Journey? activeJourney;
  final bool isResuming;
  final bool isStarting;
  final bool isAddingStop;
  final bool isEnding;
  final bool isCancelling;
  final String? error;

  const JourneyState({
    this.activeJourney,
    this.isResuming = false,
    this.isStarting = false,
    this.isAddingStop = false,
    this.isEnding = false,
    this.isCancelling = false,
    this.error,
  });

  bool get hasActiveJourney => activeJourney?.isActive ?? false;

  JourneyState copyWith({
    Journey? activeJourney,
    bool? isResuming,
    bool? isStarting,
    bool? isAddingStop,
    bool? isEnding,
    bool? isCancelling,
    String? error,
    bool clearError = false,
  }) {
    return JourneyState(
      activeJourney: activeJourney ?? this.activeJourney,
      isResuming: isResuming ?? this.isResuming,
      isStarting: isStarting ?? this.isStarting,
      isAddingStop: isAddingStop ?? this.isAddingStop,
      isEnding: isEnding ?? this.isEnding,
      isCancelling: isCancelling ?? this.isCancelling,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
