import 'package:flutter/material.dart';
import 'mental_mantra_logo.dart';
export 'mental_mantra_logo.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final bool heroAnimation;
  final LogoVariant variant;
  final bool animateBreathing;

  const AppLogo({
    super.key,
    this.width = 120,
    this.height = 120,
    this.color,
    this.heroAnimation = false,
    this.variant = LogoVariant.full,
    this.animateBreathing = false,
  });

  const AppLogo.small({
    super.key,
    this.width = 42,
    this.height = 42,
    this.color,
    this.heroAnimation = false,
    this.variant = LogoVariant.compact,
    this.animateBreathing = false,
  });

  const AppLogo.medium({
    super.key,
    this.width = 70,
    this.height = 70,
    this.color,
    this.heroAnimation = false,
    this.variant = LogoVariant.compact,
    this.animateBreathing = false,
  });

  const AppLogo.large({
    super.key,
    this.width = 140,
    this.height = 140,
    this.color,
    this.heroAnimation = false,
    this.variant = LogoVariant.full,
    this.animateBreathing = false,
  });

  const AppLogo.hero({
    super.key,
    this.width = 180,
    this.height = 180,
    this.color,
    this.heroAnimation = true,
    this.variant = LogoVariant.full,
    this.animateBreathing = false,
  });

  const AppLogo.icon({
    super.key,
    this.width = 24,
    this.height = 24,
    this.color,
    this.heroAnimation = false,
    this.variant = LogoVariant.compact,
    this.animateBreathing = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoWidget = MentalMantraLogo(
      variant: variant,
      size: width,
      color: color,
      animateBreathing: animateBreathing,
    );

    if (heroAnimation) {
      logoWidget = Hero(
        tag: 'app_logo_hero',
        child: logoWidget,
      );
    }

    return Semantics(
      label: 'Mental Mantra Logo',
      image: true,
      child: Center(child: logoWidget),
    );
  }
}
