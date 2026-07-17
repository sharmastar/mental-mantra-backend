import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mental_mantra/core/theme/app_theme.dart';

class FireParticlesWidget extends StatefulWidget {
  final bool isBurning;
  final VoidCallback? onBurnComplete;

  const FireParticlesWidget({
    super.key,
    required this.isBurning,
    this.onBurnComplete,
  });

  @override
  State<FireParticlesWidget> createState() => _FireParticlesWidgetState();
}

class _FireParticlesWidgetState extends State<FireParticlesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  bool _notifiedComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _controller.addListener(() {
      _updateParticles();

      // Stop condition
      if (_controller.value > 0.95 && !_notifiedComplete && widget.isBurning) {
        _notifiedComplete = true;
        widget.onBurnComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(FireParticlesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBurning && !oldWidget.isBurning) {
      _startBurning();
    } else if (!widget.isBurning && oldWidget.isBurning) {
      _controller.stop();
      _particles.clear();
      _notifiedComplete = false;
      setState(() {});
    }
  }

  void _startBurning() {
    _notifiedComplete = false;
    _particles.clear();

    // Generate initial burst of particles
    for (int i = 0; i < 150; i++) {
      _particles.add(_createParticle(initial: true));
    }

    _controller.forward(from: 0.0);
  }

  _Particle _createParticle({bool initial = false}) {
    return _Particle(
      x: _random.nextDouble(),
      y: initial ? _random.nextDouble() : 1.0,
      size: _random.nextDouble() * 6 + 2,
      speed: _random.nextDouble() * 1.5 + 0.5,
      horizontalSpeed: (_random.nextDouble() - 0.5) * 0.5,
      life: 1.0,
      decay: _random.nextDouble() * 0.02 + 0.01,
      color: _getRandomFireColor(),
    );
  }

  Color _getRandomFireColor() {
    final colors = [
      AppTheme.warningColor, // Deep Orange
      AppTheme.warningColor, // Orange
      AppTheme.warningColor, // Amber
      AppTheme.warningColor, // Yellow
      AppTheme.errorColor, // Darker Orange
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _updateParticles() {
    if (!widget.isBurning) return;

    final currentVal = _controller.value;

    // Add new particles continuously until near the end
    if (currentVal < 0.8 && _random.nextDouble() > 0.5) {
      for (int i = 0; i < 5; i++) {
        _particles.add(_createParticle());
      }
    }

    // Update existing particles
    for (var p in _particles) {
      p.y -= p.speed * 0.01;
      p.x += p.horizontalSpeed * 0.01;
      p.life -= p.decay;
    }

    _particles.removeWhere((p) => p.life <= 0);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isBurning) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        painter: _FirePainter(_particles, _controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double horizontalSpeed;
  double life;
  double decay;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.horizontalSpeed,
    required this.life,
    required this.decay,
    required this.color,
  });
}

class _FirePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _FirePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw an encroaching dark overlay to simulate the paper burning away
    if (progress > 0) {
      final paint = Paint()
        ..color = AppTheme.primaryDark
            .withValues(alpha: (progress * 1.5).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawRect(Offset.zero & size, paint);
    }

    for (var p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size * p.life,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_FirePainter oldDelegate) => true;
}
