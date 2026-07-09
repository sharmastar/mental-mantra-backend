import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/music_catalog.dart';
import '../../providers/audio_player_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';

class FullScreenPlayer extends ConsumerStatefulWidget {
  const FullScreenPlayer({super.key});

  @override
  ConsumerState<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends ConsumerState<FullScreenPlayer>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _triggerHaptic(HapticFeedbackType type) {
    final hapticsEnabled = ref.read(soundHapticProvider);
    if (!hapticsEnabled) return;
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(audioPlayerProvider);
    final track = state.currentTrack;
    final isPlaying = state.isPlaying;

    if (track == null) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: Text(
            'No track selected',
            style: TextStyle(fontFamily: 'Outfit', color: Colors.white54),
          ),
        ),
      );
    }

    if (isPlaying && !_rotateController.isAnimating) {
      _rotateController.repeat();
    } else if (!isPlaying && _rotateController.isAnimating) {
      _rotateController.stop();
    }

    final progress = state.duration.inMilliseconds > 0
        ? state.position.inMilliseconds / state.duration.inMilliseconds
        : 0.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    track.color.withValues(alpha: 0.7),
                    AppTheme.darkBg,
                    AppTheme.darkBg,
                  ]
                : [
                    track.color.withValues(alpha: 0.2),
                    AppTheme.lightBg,
                    AppTheme.lightBg,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(isDark),
              const Spacer(flex: 1),
              _buildAlbumArt(track, isPlaying, isDark),
              const Spacer(flex: 1),
              _buildTrackInfo(track, isDark),
              const SizedBox(height: 16),
              // Dynamic waves visualizer behind the scenes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: EqualizerVisualizer(
                  isPlaying: isPlaying,
                  color: track.color,
                ),
              ),
              const SizedBox(height: 16),
              _buildProgress(progress, state, isDark),
              const SizedBox(height: 16),
              _buildControls(state, isPlaying),
              const SizedBox(height: 24),
              _buildVolumeControl(state, isDark),
              const SizedBox(height: 28),
              _buildCategoryList(isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PremiumBounceInteraction(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: isDark ? Colors.black26 : Colors.white60,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white70 : Colors.black87,
                size: 28,
              ),
            ),
          ),
          Text(
            'Now Playing',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          PremiumBounceInteraction(
            onTap: () {
              _triggerHaptic(HapticFeedbackType.selection);
              _showQueue(context, isDark);
            },
            child: CircleAvatar(
              backgroundColor: isDark ? Colors.black26 : Colors.white60,
              child: Icon(
                Icons.queue_music_rounded,
                color: isDark ? Colors.white70 : Colors.black87,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(MusicTrack track, bool isPlaying, bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotateController, _glowController]),
      builder: (context, _) {
        return Container(
          width: isPlaying ? 240 : 220,
          height: isPlaying ? 240 : 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                track.color,
                track.color.withValues(alpha: 0.6),
                AppTheme.primaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: track.color.withValues(alpha: _glowAnimation.value),
                blurRadius: 60,
                spreadRadius: 15,
              ),
            ],
          ),
          child: Transform.rotate(
            angle: isPlaying ? _rotateController.value * 2 * pi : 0,
            child: Icon(track.icon, color: Colors.white, size: 80),
          ),
        ).animate(target: isPlaying ? 1.0 : 0.0).scaleXY(
              begin: 0.92,
              end: 1.0,
              duration: 400.ms,
              curve: Curves.easeOutBack,
            );
      },
    );
  }

  Widget _buildTrackInfo(MusicTrack track, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            track.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Playfair Display',
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 6),
          Text(
            track.artist,
            style: TextStyle(
              fontFamily: 'Outfit',
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 15,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildProgress(double progress, AudioPlayerState state, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              activeTrackColor: isDark ? Colors.white : AppTheme.primaryColor,
              inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
              thumbColor: isDark ? Colors.white : AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) {
                final pos = Duration(milliseconds: (state.duration.inMilliseconds * v).round());
                ref.read(audioPlayerProvider.notifier).seek(pos);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(state.position),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(state.duration),
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
    );
  }

  Widget _buildControls(AudioPlayerState state, bool isPlaying) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          PremiumBounceInteraction(
            onTap: () {
              ref.read(audioPlayerProvider.notifier).toggleShuffle();
              _triggerHaptic(HapticFeedbackType.selection);
            },
            child: Icon(
              state.isShuffled ? Icons.shuffle_on_rounded : Icons.shuffle_rounded,
              color: state.isShuffled ? AppTheme.primaryColor : Colors.grey,
              size: 24,
            ),
          ),
          PremiumBounceInteraction(
            onTap: () {
              ref.read(audioPlayerProvider.notifier).previous();
              _triggerHaptic(HapticFeedbackType.selection);
            },
            child: const Icon(
              Icons.skip_previous_rounded,
              color: Colors.grey,
              size: 40,
            ),
          ),
          PremiumBounceInteraction(
            onTap: () {
              ref.read(audioPlayerProvider.notifier).togglePlayPause();
              _triggerHaptic(isPlaying ? HapticFeedbackType.medium : HapticFeedbackType.light);
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
          PremiumBounceInteraction(
            onTap: () {
              ref.read(audioPlayerProvider.notifier).next();
              _triggerHaptic(HapticFeedbackType.selection);
            },
            child: const Icon(
              Icons.skip_next_rounded,
              color: Colors.grey,
              size: 40,
            ),
          ),
          PremiumBounceInteraction(
            onTap: () {
              ref.read(audioPlayerProvider.notifier).toggleLoop();
              _triggerHaptic(HapticFeedbackType.selection);
            },
            child: Icon(
              state.isLooping ? Icons.repeat_one_on_rounded : Icons.repeat_rounded,
              color: state.isLooping ? AppTheme.primaryColor : Colors.grey,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControl(AudioPlayerState state, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Icon(
            Icons.volume_down_rounded,
            color: isDark ? Colors.white38 : Colors.black38,
            size: 18,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                activeTrackColor: isDark ? Colors.white54 : AppTheme.primaryColor.withValues(alpha: 0.6),
                inactiveTrackColor: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                thumbColor: isDark ? Colors.white70 : AppTheme.primaryColor,
              ),
              child: Slider(
                value: state.volume,
                onChanged: (v) => ref.read(audioPlayerProvider.notifier).setVolume(v),
              ),
            ),
          ),
          Icon(
            Icons.volume_up_rounded,
            color: isDark ? Colors.white54 : Colors.black54,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(bool isDark) {
    final categories = MusicCatalog.categories;
    final playerState = ref.read(audioPlayerProvider);
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final isSelected = cat.name == playerState.currentTrack?.category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PremiumBounceInteraction(
              onTap: () {
                _triggerHaptic(HapticFeedbackType.selection);
                ref.read(audioPlayerProvider.notifier).playCategory(cat.name);
              },
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: [cat.color, cat.color.withValues(alpha: 0.6)])
                      : null,
                  color: isSelected ? null : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : Colors.black12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, color: isSelected ? Colors.white : cat.color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showQueue(BuildContext context, bool isDark) {
    final playerState = ref.read(audioPlayerProvider);
    final queue = playerState.queue;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)), // V4 organic curves
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Up Next',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${queue.length} tracks',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (queue.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Queue is empty',
                    style: TextStyle(fontFamily: 'Outfit', color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: queue.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final t = queue[i];
                    final isCurrent = i == playerState.queueIndex;
                    return PremiumBounceInteraction(
                      onTap: () {
                        ref.read(audioPlayerProvider.notifier).playIndex(i);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? t.color.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: t.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(t.icon, color: t.color, size: 18),
                          ),
                          title: Text(
                            t.title,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: isCurrent ? AppTheme.primaryColor : (isDark ? Colors.white : Colors.black87),
                              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            t.artist,
                            style: const TextStyle(fontFamily: 'Outfit', color: Colors.grey, fontSize: 11),
                          ),
                          trailing: Text(
                            t.formattedDuration,
                            style: const TextStyle(fontFamily: 'Outfit', color: Colors.grey, fontSize: 11),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }
}

class EqualizerVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  const EqualizerVisualizer({super.key, required this.isPlaying, required this.color});

  @override
  State<EqualizerVisualizer> createState() => _EqualizerVisualizerState();
}

class _EqualizerVisualizerState extends State<EqualizerVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
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

  WavePainter({required this.animationValue, required this.isPlaying, required this.color});

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
      final phase = animationValue * 2 * pi + (wave * pi / 3.5);
      final amplitude = isPlaying ? (6.0 + (wave * 4.5)) : 1.5;
      final frequency = 0.015 - (wave * 0.003);

      path.reset();
      for (double x = 0; x <= width; x += 3) {
        final y = midY + sin(x * frequency + phase) * amplitude * sin(x * pi / width);
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
    return oldDelegate.animationValue != animationValue || oldDelegate.isPlaying != isPlaying;
  }
}

enum HapticFeedbackType { light, medium, selection }
