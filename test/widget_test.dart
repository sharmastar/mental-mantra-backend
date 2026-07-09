import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mental Mantra Core Tests', () {
    test('AppTheme color constants', () {
      expect(AppTheme.primaryColor.toARGB32(), 0xFF42C8B7);
      expect(AppTheme.secondaryColor.toARGB32(), 0xFF00BFA5);
      expect(AppTheme.accentColor.toARGB32(), 0xFFE0F7F6);
      expect(AppTheme.errorColor.toARGB32(), 0xFFE06B7A);
      expect(AppTheme.successColor.toARGB32(), 0xFF5CA380);
      expect(AppTheme.warningColor.toARGB32(), 0xFFD99B4B);
      expect(AppTheme.darkBg.toARGB32(), 0xFF0C2425);
      expect(AppTheme.darkSurface.toARGB32(), 0xFF102E30);
      expect(AppTheme.lightBg.toARGB32(), 0xFFF2F8F7);
    });

    test('AppTheme gradients', () {
      expect(AppTheme.primaryGradient.colors.length, 2);
      expect(AppTheme.calmGradient.colors.length, 2);
      expect(AppTheme.sunriseGradient.colors.length, 2);
      expect(AppTheme.nightGradient.colors.length, 3);
    });
  });
}
