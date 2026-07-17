import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/features/dashboard/presentation/providers/dashboard_ui_provider.dart';

void main() {
  group('DashboardUiProvider', () {
    late ProviderContainer container;
    late DashboardUiNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(dashboardUiProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has correct defaults', () {
      final state = container.read(dashboardUiProvider);
      expect(state.completedJourneySteps, 0);
      expect(state.waterLogged, false);
      expect(state.habitFlipped, false);
      expect(state.journeySelectedMood, -1);
      expect(state.isBreathingActive, false);
      expect(state.showConfetti, false);
      expect(state.eveningMoodDragValue, 2.0);
      expect(state.eveningMoodSaved, false);
      expect(state.isSoundPlaying, false);
      expect(state.rainVolume, 0.7);
      expect(state.oceanVolume, 0.5);
      expect(state.forestVolume, 0.4);
      expect(state.expandedSoundBubble, null);
    });

    test('setCompletedJourneySteps updates state', () {
      notifier.setCompletedJourneySteps(3);
      expect(container.read(dashboardUiProvider).completedJourneySteps, 3);
    });

    test('advanceJourneyStep increments by 1', () {
      notifier.advanceJourneyStep();
      expect(container.read(dashboardUiProvider).completedJourneySteps, 1);
      notifier.advanceJourneyStep();
      expect(container.read(dashboardUiProvider).completedJourneySteps, 2);
    });

    test('setWaterLogged updates state', () {
      notifier.setWaterLogged(true);
      expect(container.read(dashboardUiProvider).waterLogged, true);
    });

    test('setHabitFlipped updates state', () {
      notifier.setHabitFlipped(true);
      expect(container.read(dashboardUiProvider).habitFlipped, true);
    });

    test('setJourneySelectedMood updates state', () {
      notifier.setJourneySelectedMood(3);
      expect(container.read(dashboardUiProvider).journeySelectedMood, 3);
    });

    test('setBreathingActive sets isBreathingActive and resets phase', () {
      notifier.setBreathingActive(true);
      final state = container.read(dashboardUiProvider);
      expect(state.isBreathingActive, true);
      expect(state.isEmergencyCalm, false);
      expect(state.breathingPhaseText, 'Prepare');
      expect(state.breathingSecondsLeft, 4);
      expect(state.breathingRounds, 0);
    });

    test('setBreathingActive with emergency mode sets longer seconds', () {
      notifier.setBreathingActive(true, isEmergency: true);
      final state = container.read(dashboardUiProvider);
      expect(state.isEmergencyCalm, true);
      expect(state.breathingSecondsLeft, 5);
    });

    test('updateBreathingPhase updates phase, seconds, and rounds', () {
      notifier.updateBreathingPhase(
          phaseText: 'Inhale', secondsLeft: 3, rounds: 1);
      final state = container.read(dashboardUiProvider);
      expect(state.breathingPhaseText, 'Inhale');
      expect(state.breathingSecondsLeft, 3);
      expect(state.breathingRounds, 1);
    });

    test('stopBreathing sets isBreathingActive to false', () {
      notifier.setBreathingActive(true);
      notifier.stopBreathing();
      expect(container.read(dashboardUiProvider).isBreathingActive, false);
    });

    test('setShowConfetti updates state', () {
      notifier.setShowConfetti(true);
      expect(container.read(dashboardUiProvider).showConfetti, true);
      notifier.setShowConfetti(false);
      expect(container.read(dashboardUiProvider).showConfetti, false);
    });

    test('setEveningMoodDragValue updates state', () {
      notifier.setEveningMoodDragValue(3.5);
      expect(container.read(dashboardUiProvider).eveningMoodDragValue, 3.5);
    });

    test('setEveningMoodSaved updates state', () {
      notifier.setEveningMoodSaved(true);
      expect(container.read(dashboardUiProvider).eveningMoodSaved, true);
    });

    test('toggleSoundPlaying toggles isSoundPlaying', () {
      expect(container.read(dashboardUiProvider).isSoundPlaying, false);
      notifier.toggleSoundPlaying();
      expect(container.read(dashboardUiProvider).isSoundPlaying, true);
      notifier.toggleSoundPlaying();
      expect(container.read(dashboardUiProvider).isSoundPlaying, false);
    });

    test('setSoundVolume updates individual volumes', () {
      notifier.setSoundVolume(rain: 0.5, ocean: 0.3);
      final state = container.read(dashboardUiProvider);
      expect(state.rainVolume, 0.5);
      expect(state.oceanVolume, 0.3);
      expect(state.forestVolume, 0.4);
    });

    test('setExpandedSoundBubble toggles correctly', () {
      notifier.setExpandedSoundBubble('rain');
      expect(container.read(dashboardUiProvider).expandedSoundBubble, 'rain');
      notifier.setExpandedSoundBubble('rain');
      expect(container.read(dashboardUiProvider).expandedSoundBubble, null);
    });

    test('setExpandedSoundBubble with null clears it', () {
      notifier.setExpandedSoundBubble('rain');
      notifier.setExpandedSoundBubble(null);
      expect(container.read(dashboardUiProvider).expandedSoundBubble, null);
    });

    test('reset restores initial state', () {
      notifier.setCompletedJourneySteps(5);
      notifier.setWaterLogged(true);
      notifier.setHabitFlipped(true);
      notifier.reset();
      final state = container.read(dashboardUiProvider);
      expect(state.completedJourneySteps, 0);
      expect(state.waterLogged, false);
      expect(state.habitFlipped, false);
    });

    test('state is independent - changing one does not affect others', () {
      notifier.setCompletedJourneySteps(3);
      notifier.setWaterLogged(true);
      notifier.setExpandedSoundBubble('rain');

      final state = container.read(dashboardUiProvider);
      expect(state.completedJourneySteps, 3);
      expect(state.waterLogged, true);
      expect(state.expandedSoundBubble, 'rain');
      expect(state.habitFlipped, false);
      expect(state.isBreathingActive, false);
      expect(state.eveningMoodDragValue, 2.0);
    });
  });
}
