import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/wellness/models/wellness_plan.dart';

class WellnessScoreRing extends StatelessWidget {
  final WellnessScore score;
  final VoidCallback? onTap;

  const WellnessScoreRing({
    super.key,
    required this.score,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratingColor = _ratingColor;
    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final mainTextColor = isDark ? Colors.white : AppTheme.primaryDark;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 146,
                    height: 146,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ratingColor.withValues(
                              alpha: isDark ? 0.12 : 0.08),
                          blurRadius: 32,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
                        begin: 0.96,
                        end: 1.04,
                        duration: 2500.ms,
                        curve: Curves.easeInOut,
                      ),
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CustomPaint(
                      painter: ScoreRingPainter(
                        score: score.overall.toDouble(),
                        color: ratingColor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${score.overall}',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: mainTextColor,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Wellness Score',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.primaryLight
                              : AppTheme.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricPill(
                    context,
                    'Sleep',
                    score.sleep >= 7 ? 'Optimal' : 'Low',
                    score.sleep >= 7
                        ? AppTheme.successColor
                        : AppTheme.warningColor,
                  ),
                  _buildMetricPill(
                    context,
                    'Stress',
                    score.overall >= 70 ? 'Low' : 'High',
                    score.overall >= 70
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                  _buildMetricPill(
                    context,
                    'Mood',
                    score.mood >= 3.5 ? 'Good' : 'Muted',
                    score.mood >= 3.5
                        ? AppTheme.successColor
                        : AppTheme.warningColor,
                  ),
                  _buildMetricPill(
                    context,
                    'Energy',
                    score.activity >= 50 ? 'High' : 'Low',
                    score.activity >= 50
                        ? AppTheme.successColor
                        : AppTheme.warningColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Tap to explore full breakdown',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0);
  }

  Color get _ratingColor => score.overall >= 75
      ? AppTheme.successColor
      : score.overall >= 50
          ? AppTheme.warningColor
          : AppTheme.errorColor;

  Widget _buildMetricPill(
      BuildContext context, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white60 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.15),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class ScoreRingPainter extends CustomPainter {
  final double score;
  final Color color;

  ScoreRingPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.3), color],
        stops: const [0.0, 1.0],
        transform: const GradientRotation(-pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = (score / 100.0) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ScoreRingPainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}
