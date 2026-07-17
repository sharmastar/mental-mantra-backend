import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// @deprecated Use [AppTheme] from core/theme/app_theme.dart instead.
class AppDesign {
  AppDesign._();

  static const Color primary = AppTheme.primaryColor;
  static const Color primaryLight = AppTheme.primaryLight;
  static const Color primaryDark = AppTheme.primaryDark;
  static const Color secondary = AppTheme.secondaryColor;
  static const Color accent = AppTheme.accentColor;
  static const Color warning = AppTheme.warningColor;
  static const Color error = AppTheme.errorColor;
  static const Color success = AppTheme.successColor;
  static const Color background = AppTheme.lightBg;
  static const Color surface = AppTheme.lightSurface;
  static const Color darkBackground = AppTheme.darkBg;
  static const Color darkSurface = AppTheme.darkSurface;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);

  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;

  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radius28 = 28;

  static const LinearGradient primaryGradient = AppTheme.primaryGradient;
}
