import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../providers/dashboard_ui_provider.dart';

class SleepSoundsMixer extends ConsumerStatefulWidget {
  const SleepSoundsMixer({super.key});

  @override
  ConsumerState<SleepSoundsMixer> createState() => _SleepSoundsMixerState();
}

class _SleepSoundsMixerState extends ConsumerState<SleepSoundsMixer> {
  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(dashboardUiProvider);
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 1.0,
        ),
        boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sleep Soundscape',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nova suggests: "Rain sounds would help tonight"',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  final hapticsEnabled = ref.read(soundHapticProvider);
                  if (hapticsEnabled) {
                    HapticFeedback.lightImpact();
                  }
                  ref.read(dashboardUiProvider.notifier).toggleSoundPlaying();
                },
                child: CircleAvatar(
                  backgroundColor: uiState.isSoundPlaying
                      ? AppTheme.primaryColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  radius: 20,
                  child: Icon(
                    uiState.isSoundPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (uiState.isSoundPlaying) ...[
            SizedBox(
              height: 30,
              width: double.infinity,
              child: CustomPaint(
                painter: EqualizerWavePainter(
                  rain: uiState.rainVolume,
                  ocean: uiState.oceanVolume,
                  forest: uiState.forestVolume,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildSoundBubble(context, 'Gentle Rain', 'rain', Icons.water_drop,
                  Colors.blue, uiState.rainVolume),
              buildSoundBubble(context, 'Ocean Waves', 'ocean', Icons.waves,
                  Colors.teal, uiState.oceanVolume),
              buildSoundBubble(context, 'Forest Wind', 'forest',
                  Icons.nature_people, Colors.green, uiState.forestVolume),
            ],
          ),
          if (uiState.expandedSoundBubble != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    uiState.expandedSoundBubble == 'rain'
                        ? Icons.water_drop
                        : uiState.expandedSoundBubble == 'ocean'
                            ? Icons.waves
                            : Icons.nature_people,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: uiState.expandedSoundBubble == 'rain'
                          ? uiState.rainVolume
                          : uiState.expandedSoundBubble == 'ocean'
                              ? uiState.oceanVolume
                              : uiState.forestVolume,
                      onChanged: (val) {
                        ref.read(dashboardUiProvider.notifier).setSoundVolume(
                              rain: uiState.expandedSoundBubble == 'rain'
                                  ? val
                                  : null,
                              ocean: uiState.expandedSoundBubble == 'ocean'
                                  ? val
                                  : null,
                              forest: uiState.expandedSoundBubble == 'forest'
                                  ? val
                                  : null,
                            );
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      size: 16,
                    ),
                    onPressed: () {
                      ref
                          .read(dashboardUiProvider.notifier)
                          .setExpandedSoundBubble(null);
                    },
                  ),
                ],
              ),
            ).animate().fadeIn().scaleY(begin: 0.8, end: 1.0),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 180.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget buildSoundBubble(
    BuildContext context,
    String name,
    String key,
    IconData icon,
    Color baseColor,
    double vol,
  ) {
    final uiState = ref.watch(dashboardUiProvider);
    final theme = Theme.of(context);
    final isSelected = uiState.expandedSoundBubble == key;
    return GestureDetector(
      onTap: () {
        final hapticsEnabled = ref.read(soundHapticProvider);
        if (hapticsEnabled) {
          HapticFeedback.lightImpact();
        }
        ref.read(dashboardUiProvider.notifier).setExpandedSoundBubble(key);
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? baseColor.withValues(alpha: 0.3)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.05),
              border: Border.all(
                color: isSelected
                    ? baseColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: isSelected
                  ? baseColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.54),
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          Text(
            '${(vol * 100).round()}%',
            style: TextStyle(
                fontSize: 8,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}

// ── Visual sleep equalizer waveform painter ────────────────────────
class EqualizerWavePainter extends CustomPainter {
  final double rain;
  final double ocean;
  final double forest;

  EqualizerWavePainter(
      {required this.rain, required this.ocean, required this.forest});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.secondaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const barsCount = 20;
    final spacing = size.width / barsCount;

    final timeFactor = DateTime.now().millisecondsSinceEpoch / 100.0;

    for (var i = 0; i < barsCount; i++) {
      final x = i * spacing + spacing / 2;
      // Calculate dynamic wave amplitude
      final ampFactor = (sin(i * 0.5 + timeFactor) * 0.5 + 0.5);
      final mixFactor = (rain * 15.0) + (ocean * 12.0) + (forest * 8.0);
      final h = max(4.0, ampFactor * mixFactor);

      canvas.drawLine(
        Offset(x, size.height / 2 - h / 2),
        Offset(x, size.height / 2 + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
