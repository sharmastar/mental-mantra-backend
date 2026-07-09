import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDesign {
  AppDesign._();

  static const Color primary = Color(0xFF42C8B7);
  static const Color primaryLight = Color(0xFF75E6DA);
  static const Color primaryDark = Color(0xFF1E6C64);
  static const Color secondary = Color(0xFF00BFA5);
  static const Color accent = Color(0xFFE0F7F6);
  static const Color warning = Color(0xFFD99B4B);
  static const Color error = Color(0xFFE06B7A);
  static const Color success = Color(0xFF5CA380);
  static const Color background = Color(0xFFF2F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0C2425);
  static const Color darkSurface = Color(0xFF102E30);
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

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF42C8B7), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static TextTheme textTheme(bool isDark) {
    final color = isDark ? const Color(0xFFE2F3F2) : const Color(0xFF092828);
    return GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 34, fontWeight: FontWeight.w700, color: color,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w700, color: color,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w600, color: color,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 22, fontWeight: FontWeight.w600, color: color,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 20, fontWeight: FontWeight.w600, color: color,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 18, fontWeight: FontWeight.w600, color: color,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 16, fontWeight: FontWeight.w600, color: color,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 14, fontWeight: FontWeight.w500, color: color,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16, fontWeight: FontWeight.w400, color: color,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14, fontWeight: FontWeight.w400, color: color,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12, fontWeight: FontWeight.w400, color: color.withValues(alpha: 0.7),
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14, fontWeight: FontWeight.w600, color: color,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 10, fontWeight: FontWeight.w400, color: color.withValues(alpha: 0.6),
      ),
    );
  }
}
