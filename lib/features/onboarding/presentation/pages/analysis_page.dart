import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/app_logo.dart';

class AnalysisPage extends StatefulWidget {
  final VoidCallback onComplete;
  final Future<void>? analysisFuture;
  const AnalysisPage({super.key, required this.onComplete, this.analysisFuture});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  String _statusText = 'Analyzing your responses...';
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _animController.forward();
    _simulateAnalysis();
  }

  void _simulateAnalysis() async {
    // Phase 1: Start
    if (!mounted) return;
    setState(() {
      _statusText = 'Analyzing your responses...';
      _progress = 0.20;
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Phase 2: Middle - AI/Prediction step
    if (!mounted) return;
    setState(() {
      _statusText = 'Predicting your wellness profile...';
      _progress = 0.45;
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Phase 3: Recommendations
    if (!mounted) return;
    setState(() {
      _statusText = 'Generating personalized recommendations...';
      _progress = 0.70;
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Phase 4: Wait for the actual AI analysis to complete if present
    if (widget.analysisFuture != null) {
      if (mounted) {
        setState(() {
          _statusText = 'Customizing your wellness plan...';
          _progress = 0.85;
        });
      }
      try {
        await widget.analysisFuture;
      } catch (_) {
        // If there's an error, we still proceed to let the user use the app
      }
    }

    // Phase 5: Ready!
    if (!mounted) return;
    setState(() {
      _statusText = 'Your plan is ready!';
      _progress = 1.0;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0C2425) : const Color(0xFFF9F8FD);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 220,
                  child: Center(
                    child: const AppLogo(
                      width: 160,
                      height: 160,
                    )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          end: const Offset(1.08, 1.08),
                          duration: 1200.ms,
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .shimmer(duration: 1800.ms, color: isDark ? Colors.white12 : Colors.white54),
                  ),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: isDark ? const Color(0xFF1F585B) : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _statusText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF2B2062),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Predicting and preparing your personalized plan may take a moment. Thank you for your patience.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : const Color(0xFF6B6196),
                    fontSize: 14.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
