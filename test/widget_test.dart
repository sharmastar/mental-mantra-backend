import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mental Mantra Core Tests', () {
    test('AppTheme color constants', () {
      // Primary: Warm Therapeutic Teal
      expect(AppTheme.primaryColor.toARGB32(), 0xFF1E9B8E);
      // Secondary: Soft Teal Light
      expect(AppTheme.secondaryColor.toARGB32(), 0xFF5CCABF);
      // Accent: Soft Teal Tint
      expect(AppTheme.accentColor.toARGB32(), 0xFFE6F7F5);
      expect(AppTheme.errorColor.toARGB32(), 0xFFD65D5D);
      expect(AppTheme.successColor.toARGB32(), 0xFF73A99C);
      expect(AppTheme.warningColor.toARGB32(), 0xFFE2A050);
      expect(AppTheme.darkBg.toARGB32(), 0xFF0A1112);
      expect(AppTheme.darkSurface.toARGB32(), 0xFF101719);
      expect(AppTheme.lightBg.toARGB32(), 0xFFF3F7F6);
    });

    test('AppTheme gradients', () {
      expect(AppTheme.primaryGradient.colors.length, 2);
      expect(AppTheme.calmGradient.colors.length, 2);
      expect(AppTheme.sunriseGradient.colors.length, 2);
      expect(AppTheme.nightGradient.colors.length, 3);
    });
  });
}
