import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/core/config/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppConfig', () {
    test('has correct app name and version', () {
      expect(AppConfig.appName, 'Mental Mantra');
      expect(AppConfig.appVersion, '1.0.0');
      expect(AppConfig.buildNumber, 1);
      expect(AppConfig.packageName, 'com.mentalmantra.mental_mantra');
    });

    test('has feature flags', () {
      expect(AppConfig.enableAIChat, isTrue);
      expect(AppConfig.enablePremium, isTrue);
      expect(AppConfig.enableCommunity, isFalse);
    });

    test('has default timeouts', () {
      expect(AppConfig.connectTimeout.inSeconds, 15);
      expect(AppConfig.receiveTimeout.inSeconds, 30);
      expect(AppConfig.sendTimeout.inSeconds, 15);
      expect(AppConfig.healthCheckTimeout.inSeconds, 3);
    });
  });
}
