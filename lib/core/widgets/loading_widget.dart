import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A calm, breathing logo loader — replaces all CircularProgressIndicators.
/// 6-second breathing cycle with calm fade. No spinning.
class BreathingLogoLoader extends StatefulWidget {
  final String? message;
  final double size;

  const BreathingLogoLoader({super.key, this.message, this.size = 48});

  @override
  State<BreathingLogoLoader> createState() => _BreathingLogoLoaderState();
}

class _BreathingLogoLoaderState extends State<BreathingLogoLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Semantics(
        label: widget.message ?? 'Loading',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = Curves.easeInOut.transform(_controller.value);
                return Opacity(
                  opacity: 0.4 + 0.6 * t,
                  child: Transform.scale(
                    scale: 0.92 + 0.08 * t,
                    child: _buildLogoIcon(widget.size),
                  ),
                );
              },
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 16),
              Text(
                widget.message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogoIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.4),
            AppTheme.primaryColor.withValues(alpha: 0.08),
          ],
          stops: const [0.3, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          color: Colors.white.withValues(alpha: 0.9),
          size: size * 0.45,
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingWidget({super.key, this.message, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return BreathingLogoLoader(message: message, size: size);
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: BreathingLogoLoader(message: message),
            ),
          ),
      ],
    );
  }
}
