import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_ui_provider.dart';

class BreathingOverlay extends ConsumerStatefulWidget {
  const BreathingOverlay({super.key});

  @override
  ConsumerState<BreathingOverlay> createState() => _BreathingOverlayState();
}

class _BreathingOverlayState extends ConsumerState<BreathingOverlay>
    with TickerProviderStateMixin {
  Timer? _breathingTimer;
  late AnimationController _breathingOrbController;
  late Animation<double> _breathingScaleAnimation;

  bool _wasActive = false;

  @override
  void initState() {
    super.initState();
    _breathingOrbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breathingScaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathingOrbController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _breathingTimer?.cancel();
    _breathingOrbController.dispose();
    super.dispose();
  }

  void _startBreathingSession({bool isEmergency = false}) {
    final hapticsEnabled = ref.read(soundHapticProvider);
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    ref
        .read(dashboardUiProvider.notifier)
        .setBreathingActive(true, isEmergency: isEmergency);

    _breathingOrbController.duration = Duration(seconds: isEmergency ? 5 : 4);
    _breathingOrbController.reset();
    _breathingOrbController.forward();

    _breathingTimer?.cancel();
    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final uiState = ref.read(dashboardUiProvider);
      final isEmergencyCalm = uiState.isEmergencyCalm;
      final cycleTime = isEmergencyCalm ? 5 : 4;

      if (uiState.breathingSecondsLeft > 1) {
        ref.read(dashboardUiProvider.notifier).updateBreathingPhase(
              phaseText: uiState.breathingPhaseText,
              secondsLeft: uiState.breathingSecondsLeft - 1,
              rounds: uiState.breathingRounds,
            );
      } else {
        String nextPhase;
        int newRounds = uiState.breathingRounds;

        if (uiState.breathingPhaseText == 'Prepare' ||
            uiState.breathingPhaseText == 'Exhale') {
          nextPhase = 'Inhale';
          _breathingOrbController.duration = Duration(seconds: cycleTime);
          _breathingOrbController.reset();
          _breathingOrbController.forward();
          final h = ref.read(soundHapticProvider);
          if (h) HapticFeedback.selectionClick();
        } else if (uiState.breathingPhaseText == 'Inhale') {
          nextPhase = 'Hold';
          final h = ref.read(soundHapticProvider);
          if (h) HapticFeedback.selectionClick();
        } else {
          nextPhase = 'Exhale';
          _breathingOrbController.duration = Duration(seconds: cycleTime);
          _breathingOrbController.reset();
          _breathingOrbController.reverse();
          newRounds++;
          final h = ref.read(soundHapticProvider);
          if (h) HapticFeedback.selectionClick();
        }

        if (newRounds >= 3) {
          _stopBreathingSession(completed: true);
          return;
        }

        ref.read(dashboardUiProvider.notifier).updateBreathingPhase(
              phaseText: nextPhase,
              secondsLeft: cycleTime,
              rounds: newRounds,
            );
      }
    });
  }

  void _stopBreathingSession({bool completed = false}) {
    _breathingTimer?.cancel();
    _breathingOrbController.reset();
    final uiState = ref.read(dashboardUiProvider);
    ref.read(dashboardUiProvider.notifier).stopBreathing();
    if (completed &&
        uiState.completedJourneySteps == 0 &&
        !uiState.isEmergencyCalm) {
      ref.read(dashboardUiProvider.notifier).setCompletedJourneySteps(1);
    }
    final hapticsEnabled = ref.read(soundHapticProvider);
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (completed && !uiState.isEmergencyCalm) {
      _triggerCelebration();
    }
  }

  void _triggerCelebration() {
    final hapticsEnabled = ref.read(soundHapticProvider);
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    ref.read(dashboardUiProvider.notifier).setShowConfetti(true);
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(dashboardUiProvider);

    if (uiState.isBreathingActive && !_wasActive) {
      _wasActive = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startBreathingSession(isEmergency: uiState.isEmergencyCalm);
        }
      });
    } else if (!uiState.isBreathingActive && _wasActive) {
      _wasActive = false;
      _breathingTimer?.cancel();
      _breathingOrbController.reset();
    }

    if (!uiState.isBreathingActive) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Colors.black.withValues(alpha: 0.95),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Semantics(
                  label: 'Close breathing exercise',
                  hint: 'Ends the breathing session',
                  child: IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white60, size: 28),
                    onPressed: () => _stopBreathingSession(),
                  ),
                ),
              ),
            ),
            const Spacer(),
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _breathingScaleAnimation,
                builder: (context, child) {
                  final scale = _breathingScaleAnimation.value;
                  return Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: uiState.isEmergencyCalm
                              ? [
                                  AppTheme.warningColor.withValues(alpha: 0.7),
                                  AppTheme.warningColor
                                ]
                              : [
                                  AppTheme.primaryColor.withValues(alpha: 0.7),
                                  AppTheme.primaryDark,
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (uiState.isEmergencyCalm
                                    ? AppTheme.warningColor
                                    : AppTheme.primaryColor)
                                .withValues(
                                    alpha: 0.35 +
                                        (_breathingOrbController.value * 0.15)),
                            blurRadius:
                                30 + (_breathingOrbController.value * 20),
                            spreadRadius:
                                4 + (_breathingOrbController.value * 6),
                          ),
                        ],
                      ),
                      transform: Matrix4.diagonal3Values(scale, scale, 1.0),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            uiState.breathingPhaseText,
                            style: TextStyle(
                              fontFamily: 'Playfair Display',
                              color:
                                  isDark ? Colors.white : AppTheme.primaryDark,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${uiState.breathingSecondsLeft}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            Text(
              uiState.isEmergencyCalm
                  ? 'Emergency Calm mode · Focus on the rhythm'
                  : 'Rounds: ${uiState.breathingRounds} / 3',
              style: TextStyle(
                color: isDark ? Colors.white30 : Colors.black26,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
