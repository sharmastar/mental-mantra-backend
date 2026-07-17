import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium glassmorphism card used across the app for consistent premium feel.
/// Supports dark/light mode, soft glow, gradient borders, and padding variants.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool showGlow;
  final bool showBorder;
  final Color? glowColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.showGlow = false,
    this.showBorder = true,
    this.glowColor,
    this.gradient,
    this.onTap,
  });

  const GlassCard.compact({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  })  : borderRadius = 20,
        showGlow = false,
        showBorder = true,
        glowColor = null,
        gradient = null;

  const GlassCard.glow({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.glowColor,
    this.onTap,
  })  : borderRadius = 24,
        showGlow = true,
        showBorder = true,
        gradient = null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveGlowColor = glowColor ?? AppTheme.primaryColor;
    final effectivePadding = padding ?? const EdgeInsets.all(20);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1.0,
              )
            : null,
        gradient: gradient,
        boxShadow: [
          if (showGlow)
            BoxShadow(
              color: effectiveGlowColor.withValues(alpha: isDark ? 0.12 : 0.06),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          BoxShadow(
            color: (isDark ? Colors.black : AppTheme.primaryColor)
                .withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

/// Premium frosted glass overlay with blur effect.
class GlassOverlay extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;

  const GlassOverlay({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: opacity * 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A premium pill-shaped badge for counts, labels, etc.
class GlassBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;

  const GlassBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ?? AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: effectiveColor.withValues(alpha: isDark ? 0.3 : 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: effectiveColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
