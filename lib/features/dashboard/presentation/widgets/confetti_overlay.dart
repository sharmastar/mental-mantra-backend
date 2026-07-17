import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// ── Particle celebration helper structure ─────────────────────────
class Particle {
  double x = 0.5;
  double y = 0.1;
  double vx = 0;
  double vy = 0;
  double size = 0;
  Color color = Colors.white;

  Particle({List<Color>? palette}) {
    final rnd = Random();
    x = rnd.nextDouble();
    y = -0.05;
    vx = (rnd.nextDouble() - 0.5) * 0.02;
    vy = rnd.nextDouble() * 0.02 + 0.01;
    size = rnd.nextDouble() * 5 + 3;
    final colors = palette ??
        [
          AppTheme.accentColor,
          AppTheme.successColor,
          AppTheme.warningColor,
          AppTheme.primaryColor,
          AppTheme.secondaryColor,
        ];
    color = colors[rnd.nextInt(colors.length)];
  }

  void update() {
    x += vx;
    y += vy;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;
  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      p.update();
      if (p.x < 0 || p.x > 1 || p.y > 1) continue;
      paint.color = p.color;
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConfettiOverlay extends StatefulWidget {
  final bool show;
  final VoidCallback? onComplete;

  const ConfettiOverlay({super.key, required this.show, this.onComplete});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with TickerProviderStateMixin {
  List<Particle> _particles = [];
  Timer? _confettiTimer;

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _triggerCelebration();
    }
  }

  @override
  void dispose() {
    _confettiTimer?.cancel();
    super.dispose();
  }

  void _triggerCelebration() {
    final themeColors = Theme.of(context).colorScheme;
    final colors = [
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      themeColors.primary,
      themeColors.secondary,
    ];
    _particles = List.generate(80, (index) => Particle(palette: colors));
    _confettiTimer?.cancel();
    _confettiTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _particles = [];
        });
        widget.onComplete?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_particles.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: ConfettiPainter(particles: _particles),
        size: Size.infinite,
      ),
    );
  }
}
