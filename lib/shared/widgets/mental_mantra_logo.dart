import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum LogoVariant {
  full,
  compact,
  watermark,
}

class MentalMantraLogo extends StatefulWidget {
  final LogoVariant variant;
  final double size;
  final Color? color;
  final bool animateBreathing;

  const MentalMantraLogo({
    super.key,
    required this.variant,
    this.size = 120.0,
    this.color,
    this.animateBreathing = false,
  });

  @override
  State<MentalMantraLogo> createState() => _MentalMantraLogoState();
}

class _MentalMantraLogoState extends State<MentalMantraLogo>
    with SingleTickerProviderStateMixin {
  AnimationController? _breathingController;

  @override
  void initState() {
    super.initState();
    if (widget.animateBreathing) {
      _breathingController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3500),
      )..repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MentalMantraLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateBreathing != oldWidget.animateBreathing) {
      if (widget.animateBreathing) {
        _breathingController ??= AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 3500),
        );
        _breathingController!.repeat(reverse: true);
      } else {
        _breathingController?.stop();
        _breathingController?.dispose();
        _breathingController = null;
      }
    }
  }

  @override
  void dispose() {
    _breathingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Brand style guidelines: Soft mint/white typography & deep teal background
    final defaultColor = isDark ? const Color(0xFFE2F3F2) : const Color(0xFF1E9B8E);
    final resolvedColor = widget.color ?? defaultColor;
    const dotColor = Color(0xFFE2A050); // Elegant gold accent dot

    Widget symbolWidget = CustomPaint(
      size: Size(widget.size, widget.size),
      painter: LogoSymbolPainter(
        color: resolvedColor,
        dotColor: dotColor,
      ),
    );

    if (widget.animateBreathing && _breathingController != null) {
      symbolWidget = AnimatedBuilder(
        animation: _breathingController!,
        builder: (context, child) {
          final breathT = Curves.easeInOut.transform(_breathingController!.value);
          final scale = 0.95 + 0.07 * breathT;
          final opacity = 0.8 + 0.2 * breathT;
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          );
        },
        child: symbolWidget,
      );
    }

    if (widget.variant == LogoVariant.compact) {
      return symbolWidget;
    }

    if (widget.variant == LogoVariant.watermark) {
      return IgnorePointer(
        child: Opacity(
          opacity: 0.015, // max 2% opacity
          child: symbolWidget,
        ),
      );
    }

    // LogoVariant.full: Center signal icon flanked by elegant dividers + Playfair text
    final textStyle = GoogleFonts.playfairDisplay(
      fontSize: widget.size * 0.20,
      fontWeight: FontWeight.w500,
      color: resolvedColor,
      letterSpacing: widget.size * 0.09,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.size * 0.09), // Offset letterSpacing on last character
          child: Text(
            'MENTAL',
            style: textStyle,
          ),
        ),
        SizedBox(height: widget.size * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 1.0,
                color: resolvedColor.withValues(alpha: 0.35),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.08),
              child: SizedBox(
                width: widget.size * 0.35,
                height: widget.size * 0.25,
                child: CustomPaint(
                  painter: LogoSymbolPainter(
                    color: resolvedColor,
                    dotColor: dotColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1.0,
                color: resolvedColor.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
        SizedBox(height: widget.size * 0.02),
        Padding(
          padding: EdgeInsets.only(left: widget.size * 0.09), // Offset letterSpacing on last character
          child: Text(
            'MANTRA',
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

class LogoSymbolPainter extends CustomPainter {
  final Color color;
  final Color dotColor;

  LogoSymbolPainter({
    required this.color,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = math.min(size.width, size.height);

    // Draw central golden-yellow dot
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, scale * 0.08, dotPaint);

    // Draw nested parenthesis concentric ripples
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = scale * 0.045
      ..strokeCap = StrokeCap.round;

    final radii = [scale * 0.18, scale * 0.30, scale * 0.42];
    const sweepAngle = 96.0 * math.pi / 180.0;

    for (final r in radii) {
      // Left arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        math.pi - sweepAngle / 2,
        sweepAngle,
        false,
        arcPaint,
      );
      // Right arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -sweepAngle / 2,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LogoSymbolPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dotColor != dotColor;
  }
}
