import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../data/models/fitness_record.dart';
import '../providers/fitness_provider.dart';
import '../widgets/log_workout_sheet.dart';

class FitnessPage extends ConsumerWidget {
  const FitnessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fitnessProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(fitnessProvider, (prev, next) {
      if (next.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.error!), backgroundColor: AppTheme.errorColor),
        );
        ref.read(fitnessProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightBg,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient:
                      isDark ? AppTheme.nightGradient : AppTheme.calmGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.fitness_center,
                            color: Colors.white, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Fitness Tracker',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (state.todayRecord != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${state.todayRecord!.steps} steps today',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: state.isLoading
                  ? const LinearProgressIndicator(color: AppTheme.primaryColor)
                  : const SizedBox(height: 4),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepsCard(context, state),
                  const SizedBox(height: 24),
                  _buildStatsRow(state),
                  const SizedBox(height: 28),
                  _buildWeeklyChart(context, state, isDark),
                  const SizedBox(height: 28),
                  _buildWorkoutHistory(context, state, isDark),
                  const SizedBox(height: 20),
                  Semantics(
                    label: 'Log a new workout',
                    hint: 'Opens a form to record your exercise',
                    child: PremiumBounceInteraction(
                      onTap: () => _showLogWorkoutSheet(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Log Workout',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(BuildContext context, FitnessState state) {
    final steps = state.todayRecord?.steps ?? 0;
    final goal = state.stats.dailyStepGoal;
    final progress = goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0;
    final semanticLabel =
        'Today\'s steps: $steps out of $goal goal, ${(progress * 100).toInt()} percent complete';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: progress >= 1.0
              ? const LinearGradient(
                  colors: [AppTheme.successColor, AppTheme.primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.primaryColor.withValues(alpha: isDark ? 0.3 : 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today\'s Steps',
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('$steps',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1.1)),
                  const SizedBox(height: 4),
                  Text('Goal: $goal',
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Text('${(progress * 100).toInt()}%',
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(FitnessState state) {
    final stats = state.stats;
    return Row(
      children: [
        _StatCard(
            label: 'Avg Steps',
            value: _formatNumber(stats.averageSteps),
            icon: Icons.directions_walk,
            color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        _StatCard(
            label: 'Active Min',
            value: '${stats.totalActiveMinutes}',
            icon: Icons.timer,
            color: AppTheme.warningColor),
        const SizedBox(width: 12),
        _StatCard(
            label: 'Streak',
            value: '${stats.streakDays}d',
            icon: Icons.local_fire_department_outlined,
            color: AppTheme.successColor),
      ],
    );
  }

  Widget _buildWeeklyChart(
      BuildContext context, FitnessState state, bool isDark) {
    final weekData = state.stats.weeklyHistory.reversed.toList();
    final maxSteps =
        weekData.fold<int>(0, (max, r) => r.steps > max ? r.steps : max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Weekly Steps Trend',
            style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 220,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
            boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
          ),
          child: weekData.isEmpty
              ? const Center(
                  child: Text('No data yet',
                      style:
                          TextStyle(fontFamily: 'Outfit', color: Colors.grey)),
                )
              : BarChart(
                  BarChartData(
                    maxY: (maxSteps * 1.2).ceilToDouble(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxSteps * 1.2 / 4)
                          .ceilToDouble()
                          .clamp(1000, double.infinity),
                      getDrawingHorizontalLine: (v) => FlLine(
                          color: isDark ? Colors.white10 : Colors.black12,
                          strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            final i = v.toInt();
                            return i >= 0 && i < days.length
                                ? Text(days[i],
                                    style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 11,
                                        color: Colors.grey))
                                : const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final val = v.toInt();
                            return Text(
                                val >= 1000 ? '${val ~/ 1000}k' : '$val',
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 10,
                                    color: Colors.grey));
                          },
                          reservedSize: 36,
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: weekData
                        .asMap()
                        .entries
                        .map((e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.steps.toDouble(),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.primaryDark
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  width: 24,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                )
                              ],
                            ))
                        .toList(),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: state.stats.dailyStepGoal.toDouble(),
                          color: AppTheme.warningColor,
                          strokeWidth: 1.5,
                          dashArray: [5, 5],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildWorkoutHistory(
      BuildContext context, FitnessState state, bool isDark) {
    final workoutRecords = state.history
        .expand((r) => r.workouts.map((w) => (date: r.date, workout: w)))
        .toList()
      ..sort((a, b) => b.workout.startedAt.compareTo(a.workout.startedAt));

    if (workoutRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Recent Workouts',
            style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        ...workoutRecords.take(5).map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
                boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconForType(entry.workout.type),
                        color: AppTheme.primaryColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.workout.typeLabel,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppTheme.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${entry.workout.durationMinutes} min',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.workout.caloriesBurned > 0)
                    Text(
                      '${entry.workout.caloriesBurned.toInt()} cal',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        color: AppTheme.warningColor,
                      ),
                    ),
                ],
              ),
            )),
      ],
    );
  }

  void _showLogWorkoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const LogWorkoutSheet(),
    );
  }

  IconData _iconForType(WorkoutType type) {
    switch (type) {
      case WorkoutType.walking:
        return Icons.directions_walk;
      case WorkoutType.running:
        return Icons.directions_run;
      case WorkoutType.cycling:
        return Icons.directions_bike;
      case WorkoutType.yoga:
        return Icons.self_improvement;
      case WorkoutType.strength:
        return Icons.fitness_center;
      case WorkoutType.meditation:
        return Icons.spa;
      case WorkoutType.stretching:
        return Icons.straighten;
      case WorkoutType.other:
        return Icons.sports;
    }
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  fontFamily: 'Outfit', fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
