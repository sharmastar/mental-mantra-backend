import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/features/sleep/data/models/sleep_record.dart';

void main() {
  group('SleepRecord', () {
    test('durationLabel shows only hours when no remainder', () {
      final record = SleepRecord(date: DateTime.now(), durationMinutes: 480);
      expect(record.durationLabel, '8h');
    });

    test('durationLabel shows hours and minutes', () {
      final record = SleepRecord(date: DateTime.now(), durationMinutes: 450);
      expect(record.durationLabel, '7h 30min');
    });

    test('qualityLabel returns correct labels', () {
      final base = SleepRecord(date: DateTime.now(), durationMinutes: 0);
      expect(base.copyWith(qualityRating: 1).qualityLabel, 'Poor');
      expect(base.copyWith(qualityRating: 2).qualityLabel, 'Fair');
      expect(base.copyWith(qualityRating: 3).qualityLabel, 'Good');
      expect(base.copyWith(qualityRating: 4).qualityLabel, 'Very Good');
      expect(base.copyWith(qualityRating: 5).qualityLabel, 'Excellent');
      expect(base.copyWith(qualityRating: 0).qualityLabel, 'Unknown');
    });

    test('fromJson and toJson round-trip', () {
      final original = SleepRecord(
        id: '1',
        date: DateTime(2026, 6, 30),
        durationMinutes: 450,
        qualityRating: 4,
        bedtime: DateTime(2026, 6, 29, 22, 30),
        wakeTime: DateTime(2026, 6, 30, 6, 0),
        notes: ['Slept well'],
        factors: ['Exercise', 'No caffeine'],
        hasNightWakeups: false,
      );
      final json = original.toJson();
      final restored = SleepRecord.fromJson(json);
      expect(restored.id, '1');
      expect(restored.durationMinutes, 450);
      expect(restored.qualityRating, 4);
      expect(restored.notes, ['Slept well']);
      expect(restored.factors, ['Exercise', 'No caffeine']);
    });

    test('fromJson handles missing fields', () {
      final record = SleepRecord.fromJson({'date': '2026-06-30'});
      expect(record.durationMinutes, 0);
      expect(record.qualityRating, 3);
      expect(record.notes, isEmpty);
    });

    test('copyWith does not modify original', () {
      final original = SleepRecord(date: DateTime.now(), durationMinutes: 420, qualityRating: 3);
      final copy = original.copyWith(durationMinutes: 480, qualityRating: 4);
      expect(original.durationMinutes, 420);
      expect(original.qualityRating, 3);
      expect(copy.durationMinutes, 480);
      expect(copy.qualityRating, 4);
    });
  });

  group('SleepStats', () {
    test('has default values', () {
      const stats = SleepStats();
      expect(stats.averageDurationMinutes, 0);
      expect(stats.averageQuality, 0);
      expect(stats.totalSessions, 0);
      expect(stats.currentStreak, 0);
    });
  });
}
