import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/features/meditation/data/models/meditation_session.dart';

void main() {
  group('MeditationCategory', () {
    test('fromJson and toJson round-trip', () {
      const original = MeditationCategory(
        id: 'c1',
        name: 'Stress Relief',
        description: 'Release tension',
        iconUrl: 'icons/stress.png',
        sessionCount: 12,
      );
      final json = original.toJson();
      final restored = MeditationCategory.fromJson(json);
      expect(restored.id, 'c1');
      expect(restored.name, 'Stress Relief');
      expect(restored.sessionCount, 12);
    });
  });

  group('MeditationSession', () {
    test('fromJson and toJson round-trip', () {
      final original = MeditationSession(
        id: 's1',
        title: 'Morning Calm',
        description: 'Start your day with peace',
        type: MeditationType.guided,
        difficulty: DifficultyLevel.beginner,
        durationSeconds: 600,
        narrator: 'Sarah',
        tags: ['morning', 'calm'],
        isFavorite: true,
        timesCompleted: 5,
        lastPlayedAt: DateTime(2026, 6, 29),
      );
      final json = original.toJson();
      final restored = MeditationSession.fromJson(json);
      expect(restored.id, 's1');
      expect(restored.title, 'Morning Calm');
      expect(restored.type, MeditationType.guided);
      expect(restored.isFavorite, true);
      expect(restored.timesCompleted, 5);
      expect(restored.tags, ['morning', 'calm']);
    });

    test('durationLabel formats minutes', () {
      const s = MeditationSession(
          id: 's1', title: 'Test', description: 'Test', durationSeconds: 300);
      expect(s.durationLabel, '5min');
    });

    test('durationLabel formats hours and minutes', () {
      const s = MeditationSession(
          id: 's1', title: 'Test', description: 'Test', durationSeconds: 5400);
      expect(s.durationLabel, '1h 30min');
    });

    test('durationLabel shows only hours when no remainder', () {
      const s = MeditationSession(
          id: 's1', title: 'Test', description: 'Test', durationSeconds: 7200);
      expect(s.durationLabel, '2h');
    });

    test('copyWith does not modify original', () {
      const original =
          MeditationSession(id: 's1', title: 'Test', description: 'Test');
      final copy = original.copyWith(isFavorite: true, timesCompleted: 1);
      expect(original.isFavorite, false);
      expect(original.timesCompleted, 0);
      expect(copy.isFavorite, true);
      expect(copy.timesCompleted, 1);
    });
  });
}
