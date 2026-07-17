import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../data/models/recovery_models.dart';
import '../providers/recovery_provider.dart';

class UnifiedRecoveryPage extends ConsumerStatefulWidget {
  const UnifiedRecoveryPage({super.key});

  @override
  ConsumerState<UnifiedRecoveryPage> createState() =>
      _UnifiedRecoveryPageState();
}

class _UnifiedRecoveryPageState extends ConsumerState<UnifiedRecoveryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(recoveryProvider.notifier).loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recoveryProvider);
    final stats = state.stats;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Safety Plan',
            onPressed: () => context.push(AppRoutes.safetyPlan),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(recoveryProvider.notifier).loadStats(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(recoveryProvider.notifier).loadStats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StreakHero(streak: stats.currentStreak, isDark: isDark),
                    const SizedBox(height: 20),
                    _QuickActions(isDark: isDark),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: "Today's Progress"),
                    const SizedBox(height: 12),
                    _TodayProgress(stats: stats, isDark: isDark),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'Your Stats'),
                    const SizedBox(height: 12),
                    _StatsGrid(stats: stats, isDark: isDark),
                    const SizedBox(height: 24),
                    if (stats.activeGoal != null) ...[
                      const _SectionTitle(title: 'Active Goal'),
                      const SizedBox(height: 12),
                      _GoalProgress(
                          goal: stats.activeGoal!,
                          isDark: isDark,
                          onTap: () =>
                              context.push(AppRoutes.recoveryGoals)),
                      const SizedBox(height: 24),
                    ],
                    const _SectionTitle(title: 'Recent Activity'),
                    const SizedBox(height: 12),
                    if (stats.recentUrges.isEmpty)
                      const _EmptyState(
                        icon: Icons.check_circle_outline,
                        title: 'No urges logged',
                        subtitle: 'You are doing great. Keep it up!',
                      )
                    else
                      ...stats.recentUrges
                          .take(5)
                          .map((urge) => _UrgeHistoryCard(urge: urge)),
                    const SizedBox(height: 24),
                    _SafetyPlanShortcut(isDark: isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StreakHero extends StatelessWidget {
  final int streak;
  final bool isDark;
  const _StreakHero({required this.streak, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department,
              color: Colors.white, size: 36),
          const SizedBox(height: 8),
          Text(
            '$streak',
            style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1),
          ),
          const SizedBox(height: 4),
          const Text(
            'days showing up',
            style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(
            streak == 0
                ? 'Start your recovery journey today'
                : streak < 7
                    ? 'Great start! Keep building momentum.'
                    : streak < 30
                        ? 'Impressive! You are building real strength.'
                        : 'Exceptional dedication. You are unstoppable.',
            style: const TextStyle(fontSize: 13, color: Colors.white60),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final bool isDark;
  const _QuickActions({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.warning_amber_rounded,
            label: 'Log Urge',
            color: const Color(0xFFFF6B9D),
            onTap: () => context.push(AppRoutes.urgeLog),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionCard(
            icon: Icons.timer_outlined,
            label: 'Detox Timer',
            color: AppTheme.primaryColor,
            onTap: () => context.push(AppRoutes.detoxTimer),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionCard(
            icon: Icons.flag_outlined,
            label: 'Set Goal',
            color: AppTheme.successColor,
            onTap: () => context.push(AppRoutes.recoveryGoals),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold));
  }
}

class _TodayProgress extends StatelessWidget {
  final RecoveryStats stats;
  final bool isDark;
  const _TodayProgress({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final urgesToday =
        stats.recentUrges.where((u) {
          final diff = DateTime.now().difference(u.createdAt);
          return diff.inHours < 24;
        }).length;
    final resistedToday =
        stats.recentUrges.where((u) {
          final diff = DateTime.now().difference(u.createdAt);
          return diff.inHours < 24 && u.resisted;
        }).length;

    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            value: '$urgesToday',
            label: 'Urges Today',
            color: urgesToday == 0
                ? AppTheme.successColor
                : AppTheme.warningColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            value: '$resistedToday',
            label: 'Resisted',
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            value: '${stats.totalDetoxSessions}',
            label: 'Detox Sessions',
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MiniStat(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final RecoveryStats stats;
  final bool isDark;
  const _StatsGrid({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.check_circle,
                label: 'Urges Resisted',
                value: '${stats.urgesResisted}/${stats.totalUrgesLogged}',
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.access_time,
                label: 'Detox Minutes',
                value: '${stats.totalDetoxMinutes}',
                color: const Color(0xFF6C63FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.trending_up,
                label: 'Resistance Rate',
                value:
                    '${(stats.resistanceRate * 100).round()}%',
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.emoji_events,
                label: 'Best Streak',
                value: '${stats.bestStreak} days',
                color: AppTheme.warningColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkCard
            : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color)),
                const SizedBox(height: 2),
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalProgress extends StatelessWidget {
  final RecoveryGoal goal;
  final bool isDark;
  final VoidCallback onTap;
  const _GoalProgress(
      {required this.goal, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag,
                      color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(_goalLabel(goal.targetType),
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${goal.progressPercent}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      size: 18, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progressPercent / 100,
                  backgroundColor:
                      isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  color: AppTheme.primaryColor,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                  '${goal.currentValue} / ${goal.targetValue} ${_goalUnit(goal.targetType)}',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  String _goalLabel(RecoveryTargetType t) => switch (t) {
        RecoveryTargetType.screenTime => 'Daily Screen Time Limit',
        RecoveryTargetType.gamingHours => 'Daily Gaming Limit',
        RecoveryTargetType.appUsage => 'App Usage Reduction',
        RecoveryTargetType.abstinenceDays => 'Abstinence Days',
        RecoveryTargetType.detoxSessions => 'Detox Sessions',
      };

  String _goalUnit(RecoveryTargetType t) => switch (t) {
        RecoveryTargetType.screenTime => 'min',
        RecoveryTargetType.gamingHours => 'hrs',
        RecoveryTargetType.appUsage => 'min',
        RecoveryTargetType.abstinenceDays => 'days',
        RecoveryTargetType.detoxSessions => 'sessions',
      };
}

class _UrgeHistoryCard extends StatelessWidget {
  final UrgeLog urge;
  const _UrgeHistoryCard({required this.urge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkCard
            : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: urge.resisted
                  ? AppTheme.successColor.withValues(alpha: 0.12)
                  : AppTheme.errorColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
                urge.resisted ? Icons.check : Icons.close,
                color: urge.resisted
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
                size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(urge.trigger,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                    '${urge.urgeType.name} · Intensity ${urge.intensity}/10 · ${_timeAgo(urge.createdAt)}',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          if (urge.resisted)
            const Icon(Icons.star,
                color: AppTheme.warningColor, size: 18),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.successColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppTheme.successColor),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _SafetyPlanShortcut extends StatelessWidget {
  final bool isDark;
  const _SafetyPlanShortcut({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryColor.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.safetyPlan),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Safety Plan',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    SizedBox(height: 2),
                    Text(
                        'Set up warning signs, coping strategies, and contacts',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
