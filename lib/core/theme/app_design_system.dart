import 'package:flutter/material.dart';

/// Unified Design System for Mental Mantra
/// Single source of truth for all spacing, radius, color, and layout tokens.
class AppDesign {
  AppDesign._();

  // ── Spacing Scale ─────────────────────────────────────────────────
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;

  // ── Corner Radius ─────────────────────────────────────────────────
  static const double radiusCard = 24;
  static const double radiusButton = 16;
  static const double radiusInput = 16;
  static const double radiusChip = 16;
  static const double radiusSheet = 32;
  static const double radiusBottomNav = 16;

  // ── Colors ────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A1112);
  static const Color primary = Color(0xFF1E9B8E);
  static const Color primaryLight = Color(0xFF5CCABF);
  static const Color primaryDark = Color(0xFF0F5A52);
  static const Color secondary = Color(0xFF8BB5AE);
  static const Color mint = Color(0xFF5CCABF);
  static const Color sage = Color(0xFF8BB5AE);
  static const Color mintLight = Color(0xFF9AE3D5);
  static const Color mintPale = Color(0xFFDCEDEA);
  static const Color deepTeal = Color(0xFF172225);
  static const Color error = Color(0xFFD65D5D);
  static const Color success = Color(0xFF73A99C);
  static const Color warning = Color(0xFFE2A050);

  // Dark surfaces
  static const Color darkBg = Color(0xFF0A1112);
  static const Color darkSurface = Color(0xFF101719);
  static const Color darkCard = Color(0xFF151E20);
  static const Color darkBorder = Color(0xFF1E2A2E);

  // Light surfaces
  static const Color lightBg = Color(0xFFF3F7F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE0EAE9);

  // ── Content Widths ────────────────────────────────────────────────
  static const double maxContentWidth = 600;
  static const double maxTabletWidth = 900;
  static const double maxDesktopWidth = 1200;

  // ── Responsive Breakpoints ────────────────────────────────────────
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1200;
  }
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  // ── Card Decoration ───────────────────────────────────────────────
  static BoxDecoration cardDecoration({
    required BuildContext context,
    bool isSelected = false,
    bool showGlow = false,
    Color? glowColor,
    Gradient? gradient,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? darkCard : lightCard;
    final borderColor = isDark ? darkBorder : lightBorder;
    final effectiveGlowColor = glowColor ?? primary;

    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radiusCard),
      border: Border.all(
        color: isSelected
            ? primary.withValues(alpha: 0.3)
            : borderColor,
        width: isSelected ? 1.5 : 1.0,
      ),
      gradient: gradient,
      boxShadow: [
        if (showGlow)
          BoxShadow(
            color: effectiveGlowColor.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        BoxShadow(
          color: (isDark ? Colors.black : primary)
              .withValues(alpha: isDark ? 0.25 : 0.04),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // ── Card Padding ──────────────────────────────────────────────────
  static const EdgeInsets cardPadding = EdgeInsets.all(space20);
  static const double space20 = 20;

  // ── Consistent Card Widget ────────────────────────────────────────
  static Widget card({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    bool isSelected = false,
    bool showGlow = false,
    Gradient? gradient,
  }) {
    Widget container = Container(
      margin: margin,
      padding: padding ?? cardPadding,
      decoration: cardDecoration(
        context: context,
        isSelected: isSelected,
        showGlow: showGlow,
        gradient: gradient,
      ),
      child: child,
    );

    if (onTap != null) {
      container = GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }

  // ── Consistent Section Title ──────────────────────────────────────
  static Widget sectionTitle(BuildContext context, String title, {Widget? trailing}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0E1A1B);

    return Padding(
      padding: const EdgeInsets.only(bottom: space12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // ── Consistent Subtitle ───────────────────────────────────────────
  static Widget subtitle(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 13,
        color: isDark ? Colors.white54 : Colors.black45,
      ),
    );
  }
}
