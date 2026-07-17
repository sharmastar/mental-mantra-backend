import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum OrbState { idle, thinking, typing, listening }

/// A living, breathing AI presence orb that reacts to Nova's state.
///
/// Calm breathing animation with therapeutic teal palette.
/// 8-second breathing cycle — resembles gentle breathing.
class NovaOrb extends StatefulWidget {
  final OrbState state;
  final double size;

  const NovaOrb({
    super.key,
    required this.state,
    this.size = 76.0,
  });

  @override
  State<NovaOrb> createState() => _NovaOrbState();
}

class _NovaOrbState extends State<NovaOrb> with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(vsync: this);
    _pulseController = AnimationController(vsync: this);
    _rotateController = AnimationController(vsync: this);
    _configureForState(widget.state);
  }

  @override
  void didUpdateWidget(covariant NovaOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _configureForState(widget.state);
    }
  }

  void _configureForState(OrbState orbState) {
    _breatheController.stop();
    _pulseController.stop();
    _rotateController.stop();

    switch (orbState) {
      case OrbState.idle:
        _breatheController.duration = const Duration(milliseconds: 8000);
        _pulseController.duration = const Duration(milliseconds: 6000);
        _rotateController.duration = const Duration(milliseconds: 30000);
        break;
      case OrbState.thinking:
        _breatheController.duration = const Duration(milliseconds: 4000);
        _pulseController.duration = const Duration(milliseconds: 3000);
        _rotateController.duration = const Duration(milliseconds: 20000);
        break;
      case OrbState.typing:
        _breatheController.duration = const Duration(milliseconds: 5000);
        _pulseController.duration = const Duration(milliseconds: 4000);
        _rotateController.duration = const Duration(milliseconds: 25000);
        break;
      case OrbState.listening:
        _breatheController.duration = const Duration(milliseconds: 6000);
        _pulseController.duration = const Duration(milliseconds: 5000);
        _rotateController.duration = const Duration(milliseconds: 28000);
        break;
    }

    _breatheController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Color _coreColor(OrbState s) {
    switch (s) {
      case OrbState.idle:
        return AppTheme.primaryColor;
      case OrbState.thinking:
        return const Color(0xFF5CCABF);
      case OrbState.typing:
        return AppTheme.secondaryColor;
      case OrbState.listening:
        return const Color(0xFF9AE3D5);
    }
  }

  Color _glowColor(OrbState s) => _coreColor(s).withValues(alpha: 0.25);

  @override
  Widget build(BuildContext context) {
    final core = _coreColor(widget.state);
    final glow = _glowColor(widget.state);
    final size = widget.size;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _breatheController,
        _pulseController,
        _rotateController,
      ]),
      builder: (context, _) {
        final breatheT = Curves.easeInOut.transform(_breatheController.value);
        final scale = 0.96 + 0.08 * breatheT;

        final pulseT = Curves.easeInOutSine.transform(_pulseController.value);
        final glowRadius = 10.0 + 14.0 * pulseT;
        final outerRingAlpha = 0.06 + 0.10 * pulseT;

        final rotation = _rotateController.value * 2 * math.pi;

        return SizedBox(
          width: size * 1.5,
          height: size * 1.5,
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.state != OrbState.idle)
                      Transform.rotate(
                        angle: rotation,
                        child: SizedBox(
                          width: size * 1.4,
                          height: size * 1.4,
                          child: CustomPaint(
                            painter: _ParticleRingPainter(
                              color: core,
                              particleCount: widget.state == OrbState.thinking ? 5 : 3,
                            ),
                          ),
                        ),
                      ),

                    Container(
                      width: size * 1.35,
                      height: size * 1.35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: core.withValues(alpha: outerRingAlpha),
                          width: 1.0,
                        ),
                      ),
                    ),

                    Container(
                      width: size * 1.15,
                      height: size * 1.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: glow,
                            blurRadius: glowRadius,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: size * 0.72,
                      height: size * 0.72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            core,
                            core.withValues(alpha: 0.5),
                            core.withValues(alpha: 0.12),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: core.withValues(alpha: 0.30),
                            blurRadius: glowRadius * 0.7,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: size * 0.22,
                      left: size * 0.30,
                      child: Transform.rotate(
                        angle: -math.pi / 6,
                        child: Container(
                          width: size * 0.16,
                          height: size * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(size * 0.04),
                            color: Colors.white.withValues(
                              alpha: 0.18 + 0.10 * breatheT,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ParticleRingPainter extends CustomPainter {
  final Color color;
  final int particleCount;

  _ParticleRingPainter({required this.color, this.particleCount = 3});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < particleCount; i++) {
      final angle = (2 * math.pi / particleCount) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      final particleRadius = 1.5 + (i % 2);

      canvas.drawCircle(
        Offset(x, y),
        particleRadius,
        Paint()
          ..color = color.withValues(alpha: 0.35 + (i % 3) * 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleRingPainter old) =>
      old.color != color || old.particleCount != particleCount;
}
