import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_logo.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    // 2500ms animation duration for calming entrance
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.85, curve: Curves.easeIn),
    );
    
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 3200)),
      _waitForAuth(),
    ]);
    if (!mounted) return;

    final state = ref.read(authStateProvider);

    final destination = switch ((state.user, state.isOnboarded)) {
      (null, _) => AppRoutes.landing,
      (_, false) => AppRoutes.onboarding,
      (_, true) => AppRoutes.dashboard,
    };

    context.go(destination);
  }

  Future<void> _waitForAuth() async {
    if (!ref.read(authStateProvider).isLoading) return;
    final completer = Completer<void>();
    final sub = ref.listenManual(authStateProvider, (prev, next) {
      if (!next.isLoading && !completer.isCompleted) {
        completer.complete();
      }
    });
    try {
      await completer.future.timeout(const Duration(milliseconds: 1500));
    } catch (e) {
      debugPrint('[SplashPage] Auth wait timed out: $e');
      if (!completer.isCompleted) completer.complete();
    } finally {
      sub.close();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const splashGradient = LinearGradient(
      colors: [
        Color(0xFF071415), // Deep dark teal
        Color(0xFF176E65), // Mid teal
        Color(0xFF1E9B8E), // Vibrant therapeutic teal
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    const brandingColor = Color(0xFFE2F3F2); // Soft mint/white typography
    final subtitleColor = Colors.white.withValues(alpha: 0.7);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: splashGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo.hero(
                    color: brandingColor,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Your Mindful Wellness Companion',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: subtitleColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
