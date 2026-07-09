import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/core/utils/meditation_utils.dart';

void main() {
  group('MeditationUtils Unit Tests', () {
    group('formatDuration', () {
      test('formats zero seconds', () {
        expect(formatDuration(0), '00:00');
      });

      test('formats only seconds', () {
        expect(formatDuration(45), '00:45');
      });

      test('formats minutes and seconds', () {
        expect(formatDuration(125), '02:05');
      });

      test('formats large durations', () {
        expect(formatDuration(3661), '61:01');
      });
    });

    group('moodEmoji', () {
      test('returns correct emoji for mood 1', () {
        expect(moodEmoji(1), '😢');
      });

      test('returns correct emoji for mood 5', () {
        expect(moodEmoji(5), '🥰');
      });

      test('clamps values below range', () {
        expect(moodEmoji(0), '😢');
      });

      test('clamps values above range', () {
        expect(moodEmoji(10), '🥰');
      });
    });

    group('moodLabel', () {
      test('returns correct label for mood 1', () {
        expect(moodLabel(1), 'Sad');
      });

      test('returns correct label for mood 3', () {
        expect(moodLabel(3), 'Neutral');
      });

      test('returns correct label for mood 5', () {
        expect(moodLabel(5), 'Joyful');
      });

      test('clamps values below range', () {
        expect(moodLabel(0), 'Sad');
      });

      test('clamps values above range', () {
        expect(moodLabel(10), 'Joyful');
      });
    });

    group('triggerHaptic', () {
      test('is callable when disabled', () {
        triggerHaptic(HapticType.light, enabled: false);
      });
    });
  });
}
