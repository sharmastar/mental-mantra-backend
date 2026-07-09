import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/debounce_button.dart';
import '../../data/models/recovery_models.dart';
import '../providers/recovery_provider.dart';

class RecoveryPage extends ConsumerStatefulWidget {
  const RecoveryPage({super.key});

  @override
  ConsumerState<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends ConsumerState<RecoveryPage> {
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
        title: const Text('Recovery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(recoveryProvider.notifier).loadStats(),
          ),
        ],
      ),
      body: state.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor.withValues(alpha: 0.7)),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load recovery data',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => ref.read(recoveryProvider.notifier).loadStats(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
        onRefresh: () => ref.read(recoveryProvider.notifier).loadStats(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StreakCard(streak: stats.currentStreak, isDark: isDark),
                    const SizedBox(height: 16),
                    _QuickActionsRow(
                      onUrgeLog: () => context.push(AppRoutes.urgeLog),
                      onStartDetox: () => context.push(AppRoutes.detoxTimer),
                      onSetGoal: () => context.push(AppRoutes.recoveryGoals),
                    ),
                    const SizedBox(height: 20),
                    Text('Your Progress', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _StatsGrid(stats: stats, isDark: isDark),
                    const SizedBox(height: 20),
                    if (stats.activeGoal != null) ...[
                      Text('Active Goal', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _GoalCard(goal: stats.activeGoal!, isDark: isDark, onTap: () => context.push(AppRoutes.recoveryGoals)),
                      const SizedBox(height: 20),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Urges', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.urgeLog),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (stats.recentUrges.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline, size: 48, color: AppTheme.successColor.withValues(alpha: 0.5)),
                              const SizedBox(height: 8),
                              Text('No urges logged yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                              const SizedBox(height: 4),
                              const Text('Tap the button below to log your first urge', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...stats.recentUrges.take(3).map((urge) => _UrgeCard(urge: urge)),
                    const SizedBox(height: 24),
                    Text('Account Tools', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _AccountRecoveryCard(state: state),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

class _AccountRecoveryCard extends ConsumerWidget {
  final RecoveryState state;

  const _AccountRecoveryCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Sync offline data & restore from backup', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            DebounceButton(
              onTap: state.isRecoveryLoading
                  ? null
                  : () => ref.read(recoveryProvider.notifier).performRecovery(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                decoration: BoxDecoration(
                  color: state.isRecoveryLoading
                      ? AppTheme.primaryColor.withValues(alpha: 0.7)
                      : AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    state.isRecoveryLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.sync_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Account Recovery',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  final bool isDark;
  const _StreakCard({required this.streak, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
              const SizedBox(width: 8),
              Text(
                '$streak',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'day streak',
            style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            streak == 0
                ? 'Start your recovery journey today'
                : 'Keep going! Every day matters',
            style: const TextStyle(fontSize: 13, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onUrgeLog;
  final VoidCallback onStartDetox;
  final VoidCallback onSetGoal;
  const _QuickActionsRow({required this.onUrgeLog, required this.onStartDetox, required this.onSetGoal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.warning_amber_rounded,
            label: 'Log Urge',
            color: const Color(0xFFFF6B9D),
            onTap: onUrgeLog,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.timer_outlined,
            label: 'Detox Timer',
            color: AppTheme.primaryColor,
            onTap: onStartDetox,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.flag_outlined,
            label: 'Set Goal',
            color: AppTheme.successColor,
            onTap: onSetGoal,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
            ],
          ),
        ),
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
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Urges Resisted', value: '${stats.urgesResisted}/${stats.totalUrgesLogged}', icon: Icons.check_circle, color: AppTheme.successColor, isDark: isDark)),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(label: 'Detox Sessions', value: '${stats.totalDetoxSessions}', icon: Icons.timer, color: AppTheme.primaryColor, isDark: isDark)),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(label: 'Detox Minutes', value: '${stats.totalDetoxMinutes}', icon: Icons.access_time, color: const Color(0xFFFF6B9D), isDark: isDark)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final RecoveryGoal goal;
  final bool isDark;
  final VoidCallback onTap;
  const _GoalCard({required this.goal, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(_goalLabel(goal.targetType), style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${goal.progressPercent}%', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progressPercent / 100,
                  backgroundColor: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  color: AppTheme.primaryColor,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text('${goal.currentValue} / ${goal.targetValue} ${_goalUnit(goal.targetType)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

class _UrgeCard extends StatelessWidget {
  final UrgeLog urge;
  const _UrgeCard({required this.urge});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: urge.resisted ? AppTheme.successColor.withValues(alpha: 0.15) : AppTheme.errorColor.withValues(alpha: 0.15),
          child: Icon(urge.resisted ? Icons.check : Icons.close, color: urge.resisted ? AppTheme.successColor : AppTheme.errorColor, size: 20),
        ),
        title: Text(urge.trigger, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${urge.urgeType.name} · Intensity: ${urge.intensity}/10 · ${_timeAgo(urge.createdAt)}'),
        trailing: urge.copingStrategy != null
            ? Icon(Icons.self_improvement, size: 18, color: AppTheme.primaryColor.withValues(alpha: 0.6))
            : null,
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
