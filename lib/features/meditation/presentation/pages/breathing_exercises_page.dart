import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../../../core/utils/meditation_utils.dart';

enum BreathingPhase { inhale, holdInhale, exhale, holdExhale }

class BreathingPattern {
  final String name;
  final String description;
  final String icon;
  final int inhale;
  final int holdInhale;
  final int exhale;
  final int holdExhale;
  final Color color;

  const BreathingPattern({
    required this.name,
    required this.description,
    required this.icon,
    required this.inhale,
    required this.holdInhale,
    required this.exhale,
    required this.holdExhale,
    required this.color,
  });

  int get cycleDuration => inhale + holdInhale + exhale + holdExhale;

  String get phaseLabel {
    if (holdInhale == 0 && holdExhale == 0) return '$inhale:$exhale';
    return '$inhale-$holdInhale-$exhale-$holdExhale';
  }
}

const breathingPatterns = [
  BreathingPattern(
    name: 'Box Breathing',
    description: 'Equal parts — calm the nervous system',
    icon: '⬜',
    inhale: 4, holdInhale: 4, exhale: 4, holdExhale: 4,
    color: Color(0xFF42C8B7), // Brand Teal
  ),
  BreathingPattern(
    name: '4-7-8 Breathing',
    description: 'Deep relaxation, fall asleep faster',
    icon: '🌙',
    inhale: 4, holdInhale: 7, exhale: 8, holdExhale: 0,
    color: Color(0xFF1E6C64), // Dark Teal
  ),
  BreathingPattern(
    name: 'Deep Breathing',
    description: 'Full lung capacity, reduce stress',
    icon: '🌊',
    inhale: 4, holdInhale: 0, exhale: 6, holdExhale: 0,
    color: Color(0xFF00BFA5), // Mint
  ),
  BreathingPattern(
    name: 'Calm Breathing',
    description: 'Gentle rhythm for everyday calm',
    icon: '🍃',
    inhale: 4, holdInhale: 0, exhale: 4, holdExhale: 0,
    color: Color(0xFF4CAF50), // Soft Green
  ),
  BreathingPattern(
    name: 'Alternate Nostril',
    description: 'Nadi Shodhana for balance & focus',
    icon: '🧘',
    inhale: 4, holdInhale: 4, exhale: 4, holdExhale: 4,
    color: Color(0xFF8E24AA), // Deep Purple
  ),
  BreathingPattern(
    name: 'Anxiety Relief',
    description: 'Extended exhale to activate parasympathetic system',
    icon: '⚡',
    inhale: 4, holdInhale: 2, exhale: 6, holdExhale: 2,
    color: Color(0xFFE53935), // Soft Red
  ),
  BreathingPattern(
    name: 'Energizing',
    description: 'Quick inhale, long exhale for energy',
    icon: '☀️',
    inhale: 4, holdInhale: 1, exhale: 2, holdExhale: 0,
    color: Color(0xFFFF9800), // Calm Orange
  ),
];

class BreathingExercisesPage extends ConsumerStatefulWidget {
  const BreathingExercisesPage({super.key});

  @override
  ConsumerState<BreathingExercisesPage> createState() => _BreathingExercisesPageState();
}

class _BreathingExercisesPageState extends ConsumerState<BreathingExercisesPage>
    with SingleTickerProviderStateMixin {
  int _selectedPattern = 0;
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _phaseSecondsRemaining = 0;
  int _totalRounds = 0;
  bool _isRunning = false;
  bool _showPatternPicker = true;

  Timer? _phaseTimer;
  Timer? _countdownTimer;

  late AnimationController _breathController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _glowAnim = Tween(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _scaleAnim = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _breathController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  BreathingPattern get pattern => breathingPatterns[_selectedPattern];

  bool get _hapticsEnabled => ref.read(soundHapticProvider);

  void _startSession() {
    setState(() {
      _isRunning = true;
      _showPatternPicker = false;
      _totalRounds = 0;
    });
    _startPhase(BreathingPhase.inhale);
    triggerHaptic(HapticType.light, enabled: _hapticsEnabled);
  }

  void _startPhase(BreathingPhase phase) {
    final p = pattern;
    int duration;

    switch (phase) {
      case BreathingPhase.inhale:
        duration = p.inhale;
        break;
      case BreathingPhase.holdInhale:
        duration = p.holdInhale;
        break;
      case BreathingPhase.exhale:
        duration = p.exhale;
        break;
      case BreathingPhase.holdExhale:
        duration = p.holdExhale;
        break;
    }

    if (duration <= 0) {
      _nextPhase(phase);
      return;
    }

    setState(() {
      _currentPhase = phase;
      _phaseSecondsRemaining = duration;
    });

    _animateBreath(phase, duration);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_phaseSecondsRemaining > 1) {
          _phaseSecondsRemaining--;
        }
      });
    });

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(seconds: duration), () {
      if (!mounted) return;
      _nextPhase(phase);
    });
  }

  void _animateBreath(BreathingPhase phase, int duration) {
    _breathController.duration = Duration(seconds: duration);
    _breathController.reset();

    switch (phase) {
      case BreathingPhase.inhale:
      case BreathingPhase.holdInhale:
        _breathController.forward();
        break;
      case BreathingPhase.exhale:
      case BreathingPhase.holdExhale:
        _breathController.reverse();
        break;
    }
  }

  void _nextPhase(BreathingPhase current) {
    triggerHaptic(HapticType.selection, enabled: _hapticsEnabled);

    switch (current) {
      case BreathingPhase.inhale:
        if (pattern.holdInhale > 0) {
          _startPhase(BreathingPhase.holdInhale);
        } else {
          _startPhase(BreathingPhase.exhale);
        }
        break;
      case BreathingPhase.holdInhale:
        _startPhase(BreathingPhase.exhale);
        break;
      case BreathingPhase.exhale:
        if (pattern.holdExhale > 0) {
          _startPhase(BreathingPhase.holdExhale);
        } else {
          _completeCycle();
        }
        break;
      case BreathingPhase.holdExhale:
        _completeCycle();
        break;
    }
  }

  void _completeCycle() {
    setState(() {
      _totalRounds++;
    });
    _startPhase(BreathingPhase.inhale);
  }

  void _stopSession() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _breathController.reset();
    setState(() {
      _isRunning = false;
      _showPatternPicker = true;
    });
    triggerHaptic(HapticType.medium, enabled: _hapticsEnabled);
  }

  String _phaseLabel(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return 'Inhale';
      case BreathingPhase.holdInhale:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Exhale';
      case BreathingPhase.holdExhale:
        return 'Hold';
    }
  }

  IconData _phaseIcon(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return Icons.air;
      case BreathingPhase.holdInhale:
        return Icons.pause_circle_outline;
      case BreathingPhase.exhale:
        return Icons.air_outlined;
      case BreathingPhase.holdExhale:
        return Icons.pause_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = pattern;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: const Text(
          'Breathing Exercises',
          style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          if (_isRunning)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton.icon(
                onPressed: _stopSession,
                icon: const Icon(Icons.stop_rounded, size: 18, color: AppTheme.errorColor),
                label: const Text(
                  'End',
                  style: TextStyle(fontFamily: 'Outfit', color: AppTheme.errorColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _showPatternPicker ? _buildPatternPicker(isDark) : _buildSession(isDark, p),
      ),
    );
  }

  Widget _buildPatternPicker(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose your pattern',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Each pattern guides your breath in a unique rhythm',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: breathingPatterns.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final p = breathingPatterns[i];
                final isSelected = _selectedPattern == i;
                return PremiumBounceInteraction(
                  onTap: () => setState(() => _selectedPattern = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? p.color.withValues(alpha: 0.12)
                          : (isDark ? AppTheme.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isSelected ? p.color : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: p.color.withValues(alpha: 0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: p.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(p.icon, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.description,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  color: isDark ? Colors.white60 : Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            p.phaseLabel,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: p.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          PremiumBounceInteraction(
            onTap: _startSession,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: pattern.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: pattern.color.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 28, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Begin Session',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSession(bool isDark, BreathingPattern p) {
    return Column(
      children: [
        const Spacer(flex: 1),
        AnimatedBuilder(
          animation: Listenable.merge([_breathController, _glowController]),
          builder: (context, _) {
            return _buildBreathCircle(isDark, p);
          },
        ),
        const Spacer(flex: 1),
        _buildControls(isDark, p),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBreathCircle(bool isDark, BreathingPattern p) {
    final isInhaling = _currentPhase == BreathingPhase.inhale || _currentPhase == BreathingPhase.holdInhale;
    final scale = 0.5 + (isInhaling ? _scaleAnim.value * 0.5 : (1.0 - _scaleAnim.value) * 0.5);
    final glowOpacity = _glowAnim.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, _) {
                  return Container(
                    width: 280 + _glowAnim.value * 60,
                    height: 280 + _glowAnim.value * 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          p.color.withValues(alpha: glowOpacity * 0.25),
                          p.color.withValues(alpha: glowOpacity * 0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _breathController,
                builder: (context, _) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            p.color.withValues(alpha: 0.6),
                            p.color.withValues(alpha: 0.9),
                            p.color.withValues(alpha: 0.6),
                            p.color.withValues(alpha: 0.2),
                            p.color.withValues(alpha: 0.6),
                          ],
                          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                          transform: GradientRotation(_breathController.value * 2 * pi),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: p.color.withValues(alpha: glowOpacity * 0.35),
                            blurRadius: 40 + glowOpacity * 20,
                            spreadRadius: 5 + glowOpacity * 10,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF16132A) : const Color(0xFFF8F7FC),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _phaseIcon(_currentPhase),
                              size: 36,
                              color: p.color,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _phaseLabel(_currentPhase),
                              style: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: p.color,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_phaseSecondsRemaining}s',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 48,
                                fontWeight: FontWeight.w200,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPhaseDot(BreathingPhase.inhale, p),
            if (pattern.holdInhale > 0) _buildPhaseDot(BreathingPhase.holdInhale, p),
            _buildPhaseDot(BreathingPhase.exhale, p),
            if (pattern.holdExhale > 0) _buildPhaseDot(BreathingPhase.holdExhale, p),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Round $_totalRounds completed',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseDot(BreathingPhase phase, BreathingPattern p) {
    final isActive = _currentPhase == phase;
    final label = _phaseLabel(phase);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? p.color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? p.color : (Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            color: isActive ? p.color : (Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black38),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildControls(bool isDark, BreathingPattern p) {
    final isActive = _phaseTimer?.isActive ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                p.name,
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '$_totalRounds cycles completed',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.stop_rounded,
                label: 'Stop',
                onTap: _stopSession,
                color: AppTheme.errorColor,
              ),
              _buildControlButton(
                icon: isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                label: isActive ? 'Pause' : 'Resume',
                onTap: () {
                  if (isActive) {
                    _phaseTimer?.cancel();
                    _countdownTimer?.cancel();
                    _breathController.stop();
                    setState(() {});
                  } else {
                    final elapsed = p.inhale + p.holdInhale + p.exhale + p.holdExhale - _phaseSecondsRemaining;
                    final remaining = Duration(seconds: _phaseSecondsRemaining);
                    _breathController.duration = remaining;
                    _breathController.value = _phaseSecondsRemaining > 0
                        ? (elapsed / (elapsed + _phaseSecondsRemaining)).clamp(0.0, 1.0)
                        : 0.0;
                    if (_currentPhase == BreathingPhase.exhale || _currentPhase == BreathingPhase.holdExhale) {
                      _breathController.reverse(from: _breathController.value);
                    } else {
                      _breathController.forward(from: _breathController.value);
                    }
                    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
                      if (!mounted) return;
                      setState(() {
                        if (_phaseSecondsRemaining > 1) {
                          _phaseSecondsRemaining--;
                        }
                      });
                    });
                    _phaseTimer = Timer(Duration(seconds: _phaseSecondsRemaining), () {
                      if (!mounted) return;
                      _nextPhase(_currentPhase);
                    });
                    setState(() {});
                  }
                },
                color: p.color,
                isPrimary: true,
              ),
              _buildControlButton(
                icon: Icons.skip_next_rounded,
                label: 'Skip',
                onTap: () {
                  _phaseTimer?.cancel();
                  _countdownTimer?.cancel();
                  _nextPhase(_currentPhase);
                },
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool isPrimary = false,
  }) {
    return PremiumBounceInteraction(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isPrimary ? 64 : 52,
            height: isPrimary ? 64 : 52,
            decoration: BoxDecoration(
              color: isPrimary ? color.withValues(alpha: 0.12) : Colors.transparent,
              shape: BoxShape.circle,
              border: isPrimary ? null : Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: isPrimary ? 32 : 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
              color: isPrimary ? color : Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

enum HapticFeedbackType { light, medium, selection }
