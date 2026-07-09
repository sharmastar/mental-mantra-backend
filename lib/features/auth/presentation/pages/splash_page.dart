import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton_loader.dart';
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    // Minimum splash duration for animation to play
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    // Wait for auth to finish loading with timeout
    await _waitForAuth();
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
    ref.listen(authStateProvider, (prev, next) {
      if (!next.isLoading && !completer.isCompleted) {
        completer.complete();
      }
    });
    await completer.future.timeout(const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.nightGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo.hero(),
                  const SizedBox(height: 16),
                  Text(
                    'Your AI Wellness Companion',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: SkeletonLoader(height: 14, borderRadius: 4),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 80),
                    child: SkeletonLoader(height: 10, borderRadius: 4),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(3, (i) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                    child: Row(
                      children: [
                        SkeletonLoader(width: 48, height: 48, borderRadius: 12),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLoader(width: double.infinity, height: 14),
                              SizedBox(height: 6),
                              SkeletonLoader(width: 100, height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
