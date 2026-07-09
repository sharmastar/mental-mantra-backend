import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/core/config/app_config.dart';
import 'package:mental_mantra/services/ai/safety_detector.dart';

void main() {
  group('API Integration, Security & Performance Tests', () {
    test('SafetyDetector handles malicious or extreme security inputs efficiently', () {
      final hugeText = 'I feel fine ' * 10000;
      final stopwatch = Stopwatch()..start();
      final result = SafetyDetector.assess(hugeText);
      stopwatch.stop();

      expect(result.containsCrisisIndicator, isFalse);
      expect(stopwatch.elapsedMilliseconds, lessThan(500), reason: 'Performance audit: safety detection must complete under 500ms');
    });

    test('AppConfig security and timeout configuration audit', () {
      expect(AppConfig.apiBaseUrl, isNotEmpty);
      expect(AppConfig.connectTimeout, greaterThan(Duration.zero));
      expect(AppConfig.receiveTimeout, greaterThan(Duration.zero));
    });
  });
}
