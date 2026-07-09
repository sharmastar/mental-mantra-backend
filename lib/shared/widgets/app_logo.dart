import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;
  final Color? color;
  final bool showShadow;
  final bool heroAnimation;
  final bool? darkMode;

  const AppLogo({
    super.key,
    this.width = 120,
    this.height = 120,
    this.fit = BoxFit.contain,
    this.color,
    this.showShadow = false,
    this.heroAnimation = false,
    this.darkMode,
  });

  const AppLogo.small({
    super.key,
    this.width = 42,
    this.height = 42,
    this.fit = BoxFit.contain,
    this.color,
    this.showShadow = false,
    this.heroAnimation = false,
    this.darkMode,
  });

  const AppLogo.medium({
    super.key,
    this.width = 70,
    this.height = 70,
    this.fit = BoxFit.contain,
    this.color,
    this.showShadow = false,
    this.heroAnimation = false,
    this.darkMode,
  });

  const AppLogo.large({
    super.key,
    this.width = 140,
    this.height = 140,
    this.fit = BoxFit.contain,
    this.color,
    this.showShadow = true,
    this.heroAnimation = false,
    this.darkMode,
  });

  const AppLogo.hero({
    super.key,
    this.width = 180,
    this.height = 180,
    this.fit = BoxFit.contain,
    this.color,
    this.showShadow = true,
    this.heroAnimation = true,
    this.darkMode,
  });

  const AppLogo.icon({
    super.key,
    this.width = 24,
    this.height = 24,
    this.fit = BoxFit.contain,
    this.color,
    this.showShadow = false,
    this.heroAnimation = false,
    this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Determine theme mode if not explicitly passed
    final isDark = darkMode ?? Theme.of(context).brightness == Brightness.dark;

    // Automatically switch between logo_light and logo_dark based on ThemeMode
    final assetPath = isDark
        ? 'assets/branding/logo_dark.png'
        : 'assets/branding/logo_light.png';

    Widget imageWidget = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      color: color,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('AppLogo error loading image: $error');
        // Show fallback icon on error
        return Icon(
          Icons.health_and_safety,
          size: width * 0.8,
          color: Theme.of(context).primaryColor,
        );
      },
    );

    if (showShadow) {
      imageWidget = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: imageWidget,
      );
    }

    Widget finalWidget = Semantics(
      label: 'Mental Mantra Logo',
      image: true,
      child: Center(child: imageWidget), // Ensures perfect centering
    );

    if (heroAnimation) {
      finalWidget = Hero(
        tag: 'app_logo_hero',
        child: finalWidget,
      );
    }

    return finalWidget;
  }
}
