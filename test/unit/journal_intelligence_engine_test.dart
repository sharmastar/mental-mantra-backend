import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/services/wellness/engines/journal_intelligence_engine.dart';
import 'package:mental_mantra/services/wellness/models/journal_insight.dart';
import 'package:mental_mantra/features/journal/data/models/journal_entry.dart';

void main() {
  group('JournalIntelligenceEngine Unit Tests', () {
    late JournalIntelligenceEngine engine;

    setUp(() {
      engine = JournalIntelligenceEngine();
    });

    test('analyzes positive entry with themes and sentiment', () {
      final entry = JournalEntry(
        id: '1',
        title: 'Great Day',
        content: 'I feel so happy and grateful today. I had a great workout and achieved my health goal.',
        mood: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final insight = engine.analyzeEntry(entry);
      expect(insight.emotions.sentimentScore, greaterThan(0));
      expect(insight.emotions.sentimentLabel, equals(SentimentLabel.veryPositive));
      expect(insight.dominantThemes, contains('health'));
      expect(insight.dominantThemes, contains('gratitude'));
    });

    test('analyzes negative entry with stress themes', () {
      final entry = JournalEntry(
        id: '2',
        title: 'Rough Day',
        content: 'Work was awful today. My boss gave me so much pressure and deadline stress.',
        mood: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final insight = engine.analyzeEntry(entry);
      expect(insight.emotions.sentimentScore, lessThan(0));
      expect(insight.emotions.sentimentLabel, equals(SentimentLabel.veryNegative));
      expect(insight.dominantThemes, contains('work_stress'));
    });
  });
}
