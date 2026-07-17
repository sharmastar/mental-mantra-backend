import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../../../core/utils/meditation_utils.dart';

enum BreathPhase { inhale, hold, exhale, rest }

class BreathPattern {
  final String name;
  final String description;
  final String icon;
  final int inhale;
  final int hold;
  final int exhale;
  final int rest;
  final Color color;
  final bool isPanicMode;

  const BreathPattern({
    required this.name,
    required this.description,
    required this.icon,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.rest,
    required this.color,
    this.isPanicMode = false,
  });

  int get cycleDuration => inhale + hold + exhale + rest;

  String get phaseLabel {
    if (hold == 0 && rest == 0) return '$inhale:$exhale';
    return '$inhale-$hold-$exhale-$rest';
  }
}

List<BreathPattern> get defaultBreathingModes => [
      const BreathPattern(
        name: 'Box Breathing',
        description: 'Equal parts — calm the nervous system',
        icon: '⬜',
        inhale: 4,
        hold: 4,
        exhale: 4,
        rest: 4,
        color: Color(0xFF42C8B7),
      ),
      const BreathPattern(
        name: 'Panic Recovery',
        description: 'Quick relief during anxiety or panic',
        icon: '🆘',
        inhale: 4,
        hold: 4,
        exhale: 4,
        rest: 4,
        color: Color(0xFFE06B7A),
        isPanicMode: true,
      ),
      const BreathPattern(
        name: 'Triangle Breathing',
        description: 'Three-phase cycle for balance',
        icon: '🔺',
        inhale: 4,
        hold: 0,
        exhale: 4,
        rest: 0,
        color: Color(0xFF8E24AA),
      ),
      const BreathPattern(
        name: 'Focus Breathing',
        description: 'Steady rhythm for concentration',
        icon: '🎯',
        inhale: 4,
        hold: 2,
        exhale: 4,
        rest: 2,
        color: Color(0xFFFF9800),
      ),
      const BreathPattern(
        name: '4-7-8 Breathing',
        description: 'Deep relaxation, fall asleep faster',
        icon: '🌙',
        inhale: 4,
        hold: 7,
        exhale: 8,
        rest: 0,
        color: Color(0xFF1E6C64),
      ),
      const BreathPattern(
        name: 'Deep Breathing',
        description: 'Full lung capacity, reduce stress',
        icon: '🌊',
        inhale: 4,
        hold: 0,
        exhale: 6,
        rest: 0,
        color: Color(0xFF00BFA5),
      ),
      const BreathPattern(
        name: 'Calm Breathing',
        description: 'Gentle rhythm for everyday calm',
        icon: '🍃',
        inhale: 4,
        hold: 0,
        exhale: 4,
        rest: 0,
        color: Color(0xFF4CAF50),
      ),
      const BreathPattern(
        name: 'Energizing',
        description: 'Quick breathing for energy boost',
        icon: '☀️',
        inhale: 4,
        hold: 1,
        exhale: 2,
        rest: 0,
        color: Color(0xFF42C8B7),
      ),
    ];

List<BreathPattern> breathingModes = [...defaultBreathingModes];

class BreathingSheet extends ConsumerStatefulWidget {
  final int initialPattern;

  const BreathingSheet({super.key, this.initialPattern = 0});

  static Future<void> show(BuildContext context, {int pattern = 0}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BreathingSheet(initialPattern: pattern),
    );
  }

  @override
  ConsumerState<BreathingSheet> createState() => _BreathingSheetState();
}

class _BreathingSheetState extends ConsumerState<BreathingSheet>
    with SingleTickerProviderStateMixin {
  late int _selectedPattern;
  BreathPhase _currentPhase = BreathPhase.inhale;
  int _phaseSecondsRemaining = 0;
  int _totalRounds = 0;
  bool _showPatternPicker = true;

  Timer? _phaseTimer;
  Timer? _countdownTimer;

  late AnimationController _breathController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  final List<String> _panicMessages = [
    'You are safe',
    'This will pass',
    'Breathe with me',
    'You are in control',
    'Just this breath',
    'Let it go',
    'You are strong',
    'Peace is here',
  ];

  @override
  void initState() {
    super.initState();
    _breathController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _scaleAnim = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _initDynamicAiPacing();

    if (pattern.isPanicMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
    }
  }

  void _initDynamicAiPacing() {
    breathingModes = [...defaultBreathingModes];
    const aiMode = BreathPattern(
      name: 'AI Paced (Personalized)',
      description: 'Dynamically adjusts to your current state',
      icon: '🧠',
      inhale: 4,
      hold: 2,
      exhale: 6,
      rest: 2,
      color: AppTheme.primaryColor,
    );
    breathingModes.insert(0, aiMode);

    if (widget.initialPattern == 0) {
      _selectedPattern = 0; // AI paced
    } else {
      _selectedPattern = widget.initialPattern + 1; // offset by 1
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _breathController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  BreathPattern get pattern => breathingModes[_selectedPattern];
  bool get _hapticsEnabled => ref.read(soundHapticProvider);

  void _startSession() {
    setState(() {
      _showPatternPicker = false;
      _totalRounds = 0;
    });
    _startPhase(BreathPhase.inhale);
    triggerHaptic(HapticType.light, enabled: _hapticsEnabled);
  }

  void _startPhase(BreathPhase phase) {
    final p = pattern;
    int duration;

    switch (phase) {
      case BreathPhase.inhale:
        duration = p.inhale;
      case BreathPhase.hold:
        duration = p.hold;
      case BreathPhase.exhale:
        duration = p.exhale;
      case BreathPhase.rest:
        duration = p.rest;
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
        if (_phaseSecondsRemaining > 1) _phaseSecondsRemaining--;
      });
    });

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(seconds: duration), () {
      if (!mounted) return;
      _nextPhase(phase);
    });
  }

  void _animateBreath(BreathPhase phase, int duration) {
    _breathController.duration = Duration(seconds: duration);
    _breathController.reset();

    switch (phase) {
      case BreathPhase.inhale:
      case BreathPhase.hold:
        _breathController.forward();
      case BreathPhase.exhale:
      case BreathPhase.rest:
        _breathController.reverse();
    }
  }

  void _nextPhase(BreathPhase current) {
    triggerHaptic(HapticType.selection, enabled: _hapticsEnabled);

    switch (current) {
      case BreathPhase.inhale:
        pattern.hold > 0
            ? _startPhase(BreathPhase.hold)
            : _startPhase(BreathPhase.exhale);
      case BreathPhase.hold:
        _startPhase(BreathPhase.exhale);
      case BreathPhase.exhale:
        pattern.rest > 0 ? _startPhase(BreathPhase.rest) : _completeCycle();
      case BreathPhase.rest:
        _completeCycle();
    }
  }

  void _completeCycle() {
    setState(() => _totalRounds++);
    _startPhase(BreathPhase.inhale);
  }

  void _stopSession() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _breathController.reset();
    setState(() {
      _showPatternPicker = true;
    });
    triggerHaptic(HapticType.medium, enabled: _hapticsEnabled);
  }

  String _phaseLabel(BreathPhase phase) {
    switch (phase) {
      case BreathPhase.inhale:
        return 'Inhale';
      case BreathPhase.hold:
        return 'Hold';
      case BreathPhase.exhale:
        return 'Exhale';
      case BreathPhase.rest:
        return 'Rest';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBg : const Color(0xFFF8F7FC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            children: [
              _buildHandle(isDark),
              Expanded(
                child: _showPatternPicker
                    ? _buildPatternPicker(isDark)
                    : _buildSession(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: isDark ? Colors.white30 : Colors.black26,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildPatternPicker(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Breathe',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close,
                    color: isDark ? Colors.white60 : Colors.black54),
                onPressed: () => Navigator.maybePop(context),
              ),
            ],
          ),
          Text(
            'Choose a breathing pattern',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: breathingModes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = breathingModes[i];
                final isSelected = _selectedPattern == i;
                return PremiumBounceInteraction(
                  onTap: () => setState(() => _selectedPattern = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? p.color.withValues(alpha: 0.12)
                          : (isDark ? AppTheme.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? p.color
                            : (isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: p.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                              child: Text(p.icon,
                                  style: const TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.description,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            p.phaseLabel,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
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
          const SizedBox(height: 12),
          PremiumBounceInteraction(
            onTap: _startSession,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: pattern.isPanicMode
                    ? const LinearGradient(
                        colors: [Color(0xFFE06B7A), Color(0xFFD45C6B)])
                    : AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: pattern.color.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    pattern.isPanicMode
                        ? Icons.healing_rounded
                        : Icons.play_arrow_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pattern.isPanicMode ? 'Start Panic Recovery' : 'Begin',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
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

  Widget _buildSession(bool isDark) {
    return Column(
      children: [
        const Spacer(flex: 1),
        _buildBreathCircle(isDark),
        const Spacer(flex: 1),
        _buildControls(isDark),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBreathCircle(bool isDark) {
    final isInhaling = _currentPhase == BreathPhase.inhale ||
        _currentPhase == BreathPhase.hold;
    final scale = 0.5 +
        (isInhaling ? _scaleAnim.value * 0.5 : (1.0 - _scaleAnim.value) * 0.5);
    final glowOpacity = _glowAnim.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pattern.isPanicMode)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              _panicMessages[_totalRounds % _panicMessages.length],
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: pattern.color,
              ),
            ),
          ),
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, _) {
                  return Container(
                    width: 260 + glowOpacity * 60,
                    height: 260 + glowOpacity * 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          pattern.color.withValues(alpha: glowOpacity * 0.25),
                          pattern.color.withValues(alpha: glowOpacity * 0.08),
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
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            pattern.color.withValues(alpha: 0.6),
                            pattern.color.withValues(alpha: 0.9),
                            pattern.color.withValues(alpha: 0.6),
                            pattern.color.withValues(alpha: 0.2),
                            pattern.color.withValues(alpha: 0.6),
                          ],
                          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                          transform: GradientRotation(
                              _breathController.value * 2 * pi),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: pattern.color
                                .withValues(alpha: glowOpacity * 0.35),
                            blurRadius: 40 + glowOpacity * 20,
                            spreadRadius: 5 + glowOpacity * 10,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF16132A)
                              : const Color(0xFFF8F7FC),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _currentPhase == BreathPhase.inhale
                                  ? Icons.air
                                  : _currentPhase == BreathPhase.exhale
                                      ? Icons.air_outlined
                                      : Icons.pause_circle_outline,
                              size: 32,
                              color: pattern.color,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _phaseLabel(_currentPhase),
                              style: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: pattern.color,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_phaseSecondsRemaining}s',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 44,
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
        const SizedBox(height: 20),
        Text(
          'Round $_totalRounds',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildControls(bool isDark) {
    final isActive = _phaseTimer?.isActive ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
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
                _breathController.duration =
                    Duration(seconds: _phaseSecondsRemaining);
                if (_currentPhase == BreathPhase.exhale ||
                    _currentPhase == BreathPhase.rest) {
                  _breathController.reverse(from: _breathController.value);
                } else {
                  _breathController.forward(from: _breathController.value);
                }
                _countdownTimer =
                    Timer.periodic(const Duration(seconds: 1), (_) {
                  if (!mounted) return;
                  setState(() {
                    if (_phaseSecondsRemaining > 1) _phaseSecondsRemaining--;
                  });
                });
                _phaseTimer =
                    Timer(Duration(seconds: _phaseSecondsRemaining), () {
                  if (!mounted) return;
                  _nextPhase(_currentPhase);
                });
                setState(() {});
              }
            },
            color: pattern.color,
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
          _buildControlButton(
            icon: Icons.close,
            label: 'Close',
            onTap: () {
              _phaseTimer?.cancel();
              _countdownTimer?.cancel();
              Navigator.maybePop(context);
            },
            color: isDark ? Colors.white60 : Colors.black54,
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
  }) {
    return PremiumBounceInteraction(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
