import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/services/wellness/engines/score_engine.dart';
import 'package:mental_mantra/core/personalization/personalization_context.dart';

void main() {
  group('ScoreEngine Unit Tests', () {
    late ScoreEngine scoreEngine;
    const ctx = PersonalizationContext(currentStreak: 10);

    setUp(() {
      scoreEngine = ScoreEngine();
    });

    test('computes wellness score accurately for optimal inputs', () {
      final score = scoreEngine.compute(
        ctx,
        recentEntries: [],
        todayMood: 5,
        sleepHours: 8,
        waterGlasses: 8,
        meditationMinutes: 30,
        streakDays: 14,
        screenTimeHours: 2,
        aiChatCount: 5,
        journalSentimentAvg: 1.0,
        habitsCompleted: 5,
        habitsTotal: 5,
      );

      expect(score.overall, greaterThanOrEqualTo(80));
      expect(score.sleep, equals(100.0));
      expect(score.hydration, equals(100.0));
      expect(score.habits, equals(100.0));
      expect(score.screenTime, equals(100.0));
      expect(score.aiEngagement, equals(100.0));
      expect(score.needsAttention, isEmpty);
    });

    test('computes wellness score and identifies needsAttention for poor inputs', () {
      final score = scoreEngine.compute(
        ctx,
        recentEntries: [],
        todayMood: 1,
        sleepHours: 4,
        waterGlasses: 2,
        meditationMinutes: 0,
        streakDays: 0,
        screenTimeHours: 10,
        aiChatCount: 0,
        journalSentimentAvg: -0.8,
        habitsCompleted: 0,
        habitsTotal: 5,
      );

      expect(score.overall, lessThan(50));
      expect(score.sleep, equals(20.0));
      expect(score.needsAttention, contains('Sleep'));
      expect(score.needsAttention, contains('Mood'));
      expect(score.needsAttention, contains('Water intake'));
      expect(score.needsAttention, contains('Screen time'));
    });
  });
}
