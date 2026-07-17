// lib/features/meditation/presentation/pages/meditation_player_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../../core/utils/meditation_utils.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';

class MeditationPlayerPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;
  const MeditationPlayerPage({super.key, required this.args});

  @override
  ConsumerState<MeditationPlayerPage> createState() =>
      _MeditationPlayerPageState();
}

class _MeditationPlayerPageState extends ConsumerState<MeditationPlayerPage>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _pulseController;

  bool _isPlaying = false;
  double _progress = 0.0;
  int _elapsed = 0;
  late int _total; // in seconds
  Timer? _playbackTimer;

  String get _title => widget.args['title'] as String? ?? 'Meditation Session';
  String get _durationStr => widget.args['duration'] as String? ?? '10 min';

  @override
  void initState() {
    super.initState();
    // Parse duration from string (e.g. "10 min" -> 600s)
    final durStr = _durationStr.replaceAll(RegExp(r'[^0-9]'), '');
    final minutes = int.tryParse(durStr) ?? 10;
    _total = minutes * 60;

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _breathController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _hapticsEnabled => ref.read(soundHapticProvider);

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startPlaybackTimer();
        triggerHaptic(HapticType.light, enabled: _hapticsEnabled);
      } else {
        _playbackTimer?.cancel();
        triggerHaptic(HapticType.medium, enabled: _hapticsEnabled);
      }
    });
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_elapsed >= _total) {
        timer.cancel();
        setState(() {
          _isPlaying = false;
          _elapsed = 0;
          _progress = 0.0;
        });
        triggerHaptic(HapticType.medium, enabled: _hapticsEnabled);
      } else {
        setState(() {
          _elapsed++;
          _progress = _elapsed / _total;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF12101E),
                    const Color(0xFF1A1530),
                    const Color(0xFF1C1930)
                  ]
                : [
                    const Color(0xFFF8F7FC),
                    const Color(0xFFF5F2FF),
                    const Color(0xFFE0DBF0)
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Custom Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white70 : Colors.black87,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Guided Meditation',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.favorite_border_rounded,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      onPressed: () {
                        triggerHaptic(HapticType.selection,
                            enabled: _hapticsEnabled);
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Breathing Orb / Center Visual
              AnimatedBuilder(
                animation: _breathController,
                builder: (ctx, child) {
                  final scale = 0.75 + (_breathController.value * 0.25);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient Glow Rings
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) => Opacity(
                          opacity: (1 - _pulseController.value) * 0.4,
                          child: Container(
                            width: 280 * scale,
                            height: 280 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white30
                                    : AppTheme.primaryColor
                                        .withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Secondary Ring
                      Container(
                        width: 220 * scale,
                        height: 220 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : AppTheme.primaryColor.withValues(alpha: 0.06),
                        ),
                      ),
                      // Inner breathing circle
                      Container(
                        width: 160 * scale,
                        height: 160 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isDark
                              ? AppTheme.nightGradient
                              : AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: isDark ? 0.3 : 0.2),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.self_improvement,
                                color: Colors.white, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              _breathController.value > 0.5
                                  ? 'Breathe In'
                                  : 'Breathe Out',
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const Spacer(flex: 1),

              // Title and Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _durationStr,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Custom Painter Equalizer/Visualizer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: EqualizerVisualizer(
                  isPlaying: _isPlaying,
                  color: isDark ? AppTheme.primaryColor : AppTheme.primaryColor,
                ),
              ),

              const SizedBox(height: 16),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3.5,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        activeTrackColor:
                            isDark ? Colors.white : AppTheme.primaryColor,
                        inactiveTrackColor:
                            isDark ? Colors.white24 : Colors.black12,
                        thumbColor:
                            isDark ? Colors.white : AppTheme.primaryColor,
                        overlayColor:
                            AppTheme.primaryColor.withValues(alpha: 0.12),
                      ),
                      child: Slider(
                        value: _progress.clamp(0.0, 1.0),
                        onChanged: (v) {
                          setState(() {
                            _progress = v;
                            _elapsed = (v * _total).round();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDuration(_elapsed),
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            formatDuration(_total),
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.replay_10_rounded,
                        color: isDark ? Colors.white70 : Colors.black87,
                        size: 32),
                    onPressed: () {
                      setState(() {
                        _elapsed = max(0, _elapsed - 10);
                        _progress = _elapsed / _total;
                      });
                      triggerHaptic(HapticType.selection,
                          enabled: _hapticsEnabled);
                    },
                  ),
                  const SizedBox(width: 32),
                  PremiumBounceInteraction(
                    onTap: _togglePlay,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white12
                            : AppTheme.primaryColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.white24
                              : AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: isDark ? Colors.white : AppTheme.primaryColor,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    icon: Icon(Icons.forward_10_rounded,
                        color: isDark ? Colors.white70 : Colors.black87,
                        size: 32),
                    onPressed: () {
                      setState(() {
                        _elapsed = min(_total, _elapsed + 10);
                        _progress = _elapsed / _total;
                      });
                      triggerHaptic(HapticType.selection,
                          enabled: _hapticsEnabled);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ControlChip(
                      icon: Icons.notifications_none_rounded,
                      label: 'Reminder',
                      onTap: () => triggerHaptic(HapticType.selection),
                    ),
                    _ControlChip(
                      icon: Icons.timer_outlined,
                      label: 'Sleep Timer',
                      onTap: () => triggerHaptic(HapticType.selection),
                    ),
                    _ControlChip(
                      icon: Icons.volume_up_outlined,
                      label: 'Sounds',
                      onTap: () => triggerHaptic(HapticType.selection),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumBounceInteraction(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isDark ? Colors.white70 : Colors.black87, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class EqualizerVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  const EqualizerVisualizer(
      {super.key, required this.isPlaying, required this.color});

  @override
  State<EqualizerVisualizer> createState() => _EqualizerVisualizerState();
}

class _EqualizerVisualizerState extends State<EqualizerVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(EqualizerVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 50),
          painter: WavePainter(
            animationValue: _controller.value,
            isPlaying: widget.isPlaying,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final bool isPlaying;
  final Color color;

  WavePainter(
      {required this.animationValue,
      required this.isPlaying,
      required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final midY = size.height / 2;
    final width = size.width;

    for (int wave = 0; wave < 3; wave++) {
      final phase = animationValue * 2 * pi + (wave * pi / 3);
      final amplitude = isPlaying ? (6.0 + (wave * 4.0)) : 1.5;
      final frequency = 0.015 - (wave * 0.003);

      path.reset();
      for (double x = 0; x <= width; x += 3) {
        final y =
            midY + sin(x * frequency + phase) * amplitude * sin(x * pi / width);
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      paint.color = color.withValues(alpha: 0.18 + (wave * 0.15));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isPlaying != isPlaying;
  }
}
