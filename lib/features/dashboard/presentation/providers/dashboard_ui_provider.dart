import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardUiState {
  final int completedJourneySteps;
  final bool waterLogged;
  final bool habitFlipped;
  final int journeySelectedMood;
  final bool isBreathingActive;
  final bool isEmergencyCalm;
  final String breathingPhaseText;
  final int breathingSecondsLeft;
  final int breathingRounds;
  final bool showConfetti;
  final double eveningMoodDragValue;
  final bool eveningMoodSaved;
  final bool isSoundPlaying;
  final double rainVolume;
  final double oceanVolume;
  final double forestVolume;
  final String? expandedSoundBubble;

  const DashboardUiState({
    this.completedJourneySteps = 0,
    this.waterLogged = false,
    this.habitFlipped = false,
    this.journeySelectedMood = -1,
    this.isBreathingActive = false,
    this.isEmergencyCalm = false,
    this.breathingPhaseText = 'Prepare',
    this.breathingSecondsLeft = 4,
    this.breathingRounds = 0,
    this.showConfetti = false,
    this.eveningMoodDragValue = 2.0,
    this.eveningMoodSaved = false,
    this.isSoundPlaying = false,
    this.rainVolume = 0.7,
    this.oceanVolume = 0.5,
    this.forestVolume = 0.4,
    this.expandedSoundBubble,
  });

  DashboardUiState copyWith({
    int? completedJourneySteps,
    bool? waterLogged,
    bool? habitFlipped,
    int? journeySelectedMood,
    bool? isBreathingActive,
    bool? isEmergencyCalm,
    String? breathingPhaseText,
    int? breathingSecondsLeft,
    int? breathingRounds,
    bool? showConfetti,
    double? eveningMoodDragValue,
    bool? eveningMoodSaved,
    bool? isSoundPlaying,
    double? rainVolume,
    double? oceanVolume,
    double? forestVolume,
    String? expandedSoundBubble,
    bool clearExpandedSoundBubble = false,
  }) {
    return DashboardUiState(
      completedJourneySteps: completedJourneySteps ?? this.completedJourneySteps,
      waterLogged: waterLogged ?? this.waterLogged,
      habitFlipped: habitFlipped ?? this.habitFlipped,
      journeySelectedMood: journeySelectedMood ?? this.journeySelectedMood,
      isBreathingActive: isBreathingActive ?? this.isBreathingActive,
      isEmergencyCalm: isEmergencyCalm ?? this.isEmergencyCalm,
      breathingPhaseText: breathingPhaseText ?? this.breathingPhaseText,
      breathingSecondsLeft: breathingSecondsLeft ?? this.breathingSecondsLeft,
      breathingRounds: breathingRounds ?? this.breathingRounds,
      showConfetti: showConfetti ?? this.showConfetti,
      eveningMoodDragValue: eveningMoodDragValue ?? this.eveningMoodDragValue,
      eveningMoodSaved: eveningMoodSaved ?? this.eveningMoodSaved,
      isSoundPlaying: isSoundPlaying ?? this.isSoundPlaying,
      rainVolume: rainVolume ?? this.rainVolume,
      oceanVolume: oceanVolume ?? this.oceanVolume,
      forestVolume: forestVolume ?? this.forestVolume,
      expandedSoundBubble: clearExpandedSoundBubble ? null : (expandedSoundBubble ?? this.expandedSoundBubble),
    );
  }
}

class DashboardUiNotifier extends StateNotifier<DashboardUiState> {
  DashboardUiNotifier() : super(const DashboardUiState());

  void setCompletedJourneySteps(int steps) {
    state = state.copyWith(completedJourneySteps: steps);
  }

  void advanceJourneyStep() {
    state = state.copyWith(completedJourneySteps: state.completedJourneySteps + 1);
  }

  void setWaterLogged(bool value) {
    state = state.copyWith(waterLogged: value);
  }

  void setHabitFlipped(bool value) {
    state = state.copyWith(habitFlipped: value);
  }

  void setJourneySelectedMood(int mood) {
    state = state.copyWith(journeySelectedMood: mood);
  }

  void setBreathingActive(bool value, {bool isEmergency = false}) {
    state = state.copyWith(
      isBreathingActive: value,
      isEmergencyCalm: isEmergency,
      breathingPhaseText: 'Prepare',
      breathingSecondsLeft: isEmergency ? 5 : 4,
      breathingRounds: 0,
    );
  }

  void updateBreathingPhase({
    required String phaseText,
    required int secondsLeft,
    required int rounds,
  }) {
    state = state.copyWith(
      breathingPhaseText: phaseText,
      breathingSecondsLeft: secondsLeft,
      breathingRounds: rounds,
    );
  }

  void stopBreathing() {
    state = state.copyWith(isBreathingActive: false);
  }

  void setShowConfetti(bool value) {
    state = state.copyWith(showConfetti: value);
  }

  void setEveningMoodDragValue(double value) {
    state = state.copyWith(eveningMoodDragValue: value);
  }

  void setEveningMoodSaved(bool value) {
    state = state.copyWith(eveningMoodSaved: value);
  }

  void toggleSoundPlaying() {
    state = state.copyWith(isSoundPlaying: !state.isSoundPlaying);
  }

  void setSoundVolume({
    double? rain,
    double? ocean,
    double? forest,
  }) {
    state = state.copyWith(
      rainVolume: rain ?? state.rainVolume,
      oceanVolume: ocean ?? state.oceanVolume,
      forestVolume: forest ?? state.forestVolume,
    );
  }

  void setExpandedSoundBubble(String? key) {
    if (key == null) {
      state = state.copyWith(clearExpandedSoundBubble: true);
    } else if (state.expandedSoundBubble == key) {
      state = state.copyWith(clearExpandedSoundBubble: true);
    } else {
      state = state.copyWith(expandedSoundBubble: key);
    }
  }

  void reset() {
    state = const DashboardUiState();
  }
}

final dashboardUiProvider = StateNotifierProvider<DashboardUiNotifier, DashboardUiState>((ref) {
  return DashboardUiNotifier();
});
