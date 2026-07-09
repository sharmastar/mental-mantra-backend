import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum OrbState { idle, thinking, typing, error }

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

class _NovaOrbState extends State<NovaOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _updateAnimations();
  }

  @override
  void didUpdateWidget(covariant NovaOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    _controller.stop();
    switch (widget.state) {
      case OrbState.idle:
        _controller.duration = const Duration(seconds: 4);
        _scaleAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _glowAnim = Tween<double>(begin: 10.0, end: 20.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _controller.repeat(reverse: true);
        break;
      case OrbState.thinking:
      case OrbState.typing:
        _controller.duration = const Duration(seconds: 2);
        _scaleAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
        );
        _glowAnim = Tween<double>(begin: 15.0, end: 35.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
        );
        _controller.repeat(reverse: true);
        break;
      case OrbState.error:
        _controller.duration = const Duration(milliseconds: 800);
        _scaleAnim = Tween<double>(begin: 0.98, end: 1.02).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        );
        _glowAnim = Tween<double>(begin: 5.0, end: 15.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        );
        _controller.repeat(reverse: true);
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Gradient gradient;
    Color glowColor;

    switch (widget.state) {
      case OrbState.idle:
        gradient = RadialGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.9),
            AppTheme.primaryColor.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        );
        glowColor = AppTheme.primaryColor.withValues(alpha: 0.35);
        break;
      case OrbState.thinking:
      case OrbState.typing:
        gradient = RadialGradient(
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.9),
            AppTheme.primaryColor.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        );
        glowColor = AppTheme.accentColor.withValues(alpha: 0.4);
        break;
      case OrbState.error:
        gradient = RadialGradient(
          colors: [
            AppTheme.errorColor.withValues(alpha: 0.9),
            AppTheme.errorColor.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        );
        glowColor = AppTheme.errorColor.withValues(alpha: 0.4);
        break;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size * _scaleAnim.value,
          height: widget.size * _scaleAnim.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: _glowAnim.value,
                spreadRadius: 2,
              )
            ],
          ),
          child: Center(
            child: Text(
              '🌿',
              style: TextStyle(fontSize: widget.size * 0.3),
            ),
          ),
        );
      },
    );
  }
}
