import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/wellness_score_provider.dart';

class WellnessScoreCard extends ConsumerStatefulWidget {
  final double height;
  final bool showDetails;

  const WellnessScoreCard(
      {super.key, this.height = 200, this.showDetails = true});

  @override
  ConsumerState<WellnessScoreCard> createState() => _WellnessScoreCardState();
}

class _WellnessScoreCardState extends ConsumerState<WellnessScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _scoreAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _animController.forward());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = ref.watch(wellnessScoreProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayScore = (_scoreAnim.value * score.overall).round();

    return AnimatedBuilder(
      animation: _scoreAnim,
      builder: (context, _) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppTheme.darkCard, AppTheme.darkSurface]
                  : [AppTheme.lightCard, AppTheme.lightBg],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildScoreRing(displayScore, score.overall),
              const SizedBox(width: 24),
              Expanded(child: _buildScoreDetails(score, isDark)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreRing(int displayScore, int targetScore) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(140, 140),
            painter: _ScoreRingPainter(
              progress: displayScore / 100.0,
              color: _scoreColor(targetScore),
              backgroundColor: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 10,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$displayScore',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: _scoreColor(targetScore),
                ),
              ),
              Text(
                _gradeLabel(targetScore),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetails(DailyWellnessScore score, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Daily Wellness',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        if (score.topAdvice != null)
          Text(
            score.topAdvice!,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        const SizedBox(height: 12),
        if (widget.showDetails) ...[
          _buildMiniBar('Mood', score.mood, isDark),
          const SizedBox(height: 4),
          _buildMiniBar('Sleep', score.sleep, isDark),
          const SizedBox(height: 4),
          _buildMiniBar('Mindfulness', score.mindfulness, isDark),
        ],
      ],
    );
  }

  Widget _buildMiniBar(String label, int value, bool isDark) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100.0,
              backgroundColor: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.06),
              color: _scoreColor(value),
              minHeight: 6,
            ),
          ),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Color _scoreColor(int value) {
    if (value >= 80) return AppTheme.successColor;
    if (value >= 60) return AppTheme.primaryColor;
    if (value >= 40) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _gradeLabel(int value) {
    if (value >= 80) return 'Great';
    if (value >= 60) return 'Good';
    if (value >= 40) return 'Fair';
    return 'Low';
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _ScoreRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    paint.color = backgroundColor;
    canvas.drawCircle(center, radius, paint);

    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
