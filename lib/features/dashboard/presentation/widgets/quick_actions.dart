import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../../../services/wellness/models/wellness_plan.dart';

class QuickActions extends ConsumerWidget {
  final WellnessPlan plan;
  final bool isMorningMode;
  final VoidCallback onJournalTap;
  final VoidCallback onMeditationTap;
  final VoidCallback onEmergencyTap;

  const QuickActions({
    super.key,
    required this.plan,
    required this.isMorningMode,
    required this.onJournalTap,
    required this.onMeditationTap,
    required this.onEmergencyTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark ? Colors.white : AppTheme.primaryDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Explore Tools',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: buildActionItem(
                context,
                'Analytics',
                Icons.insights_rounded,
                isMorningMode,
                () => context.push(AppRoutes.analytics),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: buildActionItem(
                context,
                'Daily Tasks',
                Icons.checklist_rounded,
                isMorningMode,
                () => context.push(AppRoutes.dailyTasks),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: buildActionItem(
                context,
                'Therapy Hub',
                Icons.healing_outlined,
                isMorningMode,
                () => context.push(AppRoutes.therapyHub),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: buildActionItem(
                context,
                'Check-in',
                Icons.assignment_rounded,
                isMorningMode,
                () => context.push(AppRoutes.checkin),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: buildActionItem(
                context,
                'Journal',
                Icons.book_outlined,
                isMorningMode,
                onJournalTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: buildActionItem(
                context,
                'Meditate',
                Icons.self_improvement_outlined,
                isMorningMode,
                onMeditationTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: buildActionItem(
                context,
                'Emergency',
                Icons.emergency_outlined,
                isMorningMode,
                onEmergencyTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: buildActionItem(
                context,
                'Nova Chat',
                Icons.chat_bubble_outline,
                isMorningMode,
                () => context.push(AppRoutes.aiChat),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildActionItem(
    BuildContext context,
    String label,
    IconData icon,
    bool isMorning,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white70 : AppTheme.primaryDark;

    return PremiumBounceInteraction(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.0),
          boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
