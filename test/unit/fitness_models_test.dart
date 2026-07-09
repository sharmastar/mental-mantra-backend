import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/features/fitness/data/models/fitness_record.dart';

void main() {
  group('FitnessRecord', () {
    test('fromJson and toJson round-trip', () {
      final original = FitnessRecord(
        id: '1',
        date: DateTime(2026, 6, 30),
        steps: 7500,
        caloriesBurned: 320.5,
        activeMinutes: 45,
        heartRateAvg: 120,
        heartRateMax: 155,
        workouts: [
          WorkoutSession(
            id: 'w1',
            type: WorkoutType.walking,
            durationMinutes: 30,
            caloriesBurned: 150,
            startedAt: DateTime(2026, 6, 30, 8, 0),
          ),
        ],
      );
      final json = original.toJson();
      final restored = FitnessRecord.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.steps, original.steps);
      expect(restored.caloriesBurned, original.caloriesBurned);
      expect(restored.activeMinutes, original.activeMinutes);
      expect(restored.heartRateAvg, original.heartRateAvg);
      expect(restored.workouts.length, 1);
      expect(restored.workouts.first.type, WorkoutType.walking);
    });

    test('fromJson handles missing fields', () {
      final record = FitnessRecord.fromJson({'date': '2026-06-30'});
      expect(record.steps, 0);
      expect(record.caloriesBurned, 0);
      expect(record.workouts, isEmpty);
    });
  });

  group('WorkoutSession', () {
    test('typeLabel returns correct labels', () {
      expect(WorkoutSession(type: WorkoutType.walking, durationMinutes: 30, startedAt: DateTime.now()).typeLabel, 'Walking');
      expect(WorkoutSession(type: WorkoutType.running, durationMinutes: 30, startedAt: DateTime.now()).typeLabel, 'Running');
      expect(WorkoutSession(type: WorkoutType.yoga, durationMinutes: 30, startedAt: DateTime.now()).typeLabel, 'Yoga');
      expect(WorkoutSession(type: WorkoutType.meditation, durationMinutes: 30, startedAt: DateTime.now()).typeLabel, 'Meditation');
    });

    test('fromJson and toJson round-trip', () {
      final original = WorkoutSession(
        type: WorkoutType.running,
        durationMinutes: 45,
        caloriesBurned: 400,
        distanceKm: 5.2,
        notes: 'Morning run',
        startedAt: DateTime(2026, 6, 30, 7, 0),
      );
      final json = original.toJson();
      final restored = WorkoutSession.fromJson(json);
      expect(restored.type, WorkoutType.running);
      expect(restored.durationMinutes, 45);
      expect(restored.caloriesBurned, 400);
      expect(restored.distanceKm, 5.2);
      expect(restored.notes, 'Morning run');
    });
  });

  group('FitnessStats', () {
    test('has default values', () {
      const stats = FitnessStats();
      expect(stats.dailyStepGoal, 10000);
      expect(stats.averageSteps, 0);
      expect(stats.streakDays, 0);
    });

    test('weeklyHistory defaults to empty', () {
      const stats = FitnessStats();
      expect(stats.weeklyHistory, isEmpty);
    });
  });
}
