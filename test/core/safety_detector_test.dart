import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/services/ai/safety_detector.dart';

void main() {
  group('SafetyDetector', () {
    test('detects suicidal keywords', () {
      final result = SafetyDetector.assess('I want to kill myself');
      expect(result.containsCrisisIndicator, isTrue);
      expect(result.crisisType, 'suicidal');
      expect(result.requiresImmediateEscalation, isTrue);
    });

    test('detects self-harm patterns', () {
      final result = SafetyDetector.assess('I cut myself last night');
      expect(result.containsCrisisIndicator, isTrue);
      expect(result.crisisType, 'self_harm');
    });

    test('detects hopelessness', () {
      final result =
          SafetyDetector.assess('I feel hopeless and nothing matters anymore');
      expect(result.containsCrisisIndicator, isTrue);
      expect(result.crisisType, 'hopelessness');
    });

    test('returns safe for normal content', () {
      final result = SafetyDetector.assess('I had a great day today');
      expect(result.containsCrisisIndicator, isFalse);
      expect(result.extractedConcern, isNull);
    });

    test('returns safe for empty content', () {
      final result = SafetyDetector.assess('');
      expect(result.containsCrisisIndicator, isFalse);
      expect(result.extractedConcern, isNull);
    });

    test('provides suggested response for crises', () {
      final result = SafetyDetector.assess('I want to end my life');
      expect(result.suggestedResponse, isNotNull);
      expect(result.suggestedResponse!.length, greaterThan(10));
    });

    test('confidence is zero for safe content', () {
      final result = SafetyDetector.assess('Feeling good today');
      expect(result.confidence, 0.0);
    });
  });
}
