import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../providers/tasks_provider.dart';

class DailyTasksPage extends ConsumerStatefulWidget {
  const DailyTasksPage({super.key});

  @override
  ConsumerState<DailyTasksPage> createState() => _DailyTasksPageState();
}

class _DailyTasksPageState extends ConsumerState<DailyTasksPage>
    with TickerProviderStateMixin {
  late AnimationController _xpAnimController;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _xpAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _dataLoaded = true);
        _xpAnimController.forward();
      }
    });
  }

  @override
  void dispose() {
    _xpAnimController.dispose();
    super.dispose();
  }

  void _showLevelUp(int level) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0, end: 1),
              curve: Curves.easeOutBack,
              builder: (_, scale, __) => Transform.scale(scale: scale, child: const Text('🎉', style: TextStyle(fontSize: 56))),
            ),
            const SizedBox(height: 16),
            Text('Level Up!', style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            Text('You reached Level $level',
              style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text('Keep Going!', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Daily Tasks', style: GoogleFonts.playfairDisplay(fontSize: 20))),
      body: !_dataLoaded
          ? ListView(padding: const EdgeInsets.all(20), children: List.generate(4, (_) => const Padding(
              padding: EdgeInsets.only(bottom: 16), child: SkeletonCardLoader(),
            )))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                _buildLevelHeader(state, isDark),
                const SizedBox(height: 20),
                _buildProgressSection(state, isDark),
                const SizedBox(height: 20),
                _buildStatGrid(state, isDark),
                const SizedBox(height: 24),
                _buildSectionTitle('Today\'s Tasks', Icons.checklist_rounded, isDark),
                const SizedBox(height: 12),
                ...List.generate(state.tasks.length, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildTaskCard(state, i, isDark),
                )),
                const SizedBox(height: 24),
                _buildSectionTitle('Badges', Icons.emoji_events_rounded, isDark),
                const SizedBox(height: 12),
                _buildBadgeGrid(state, isDark),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildLevelHeader(TasksState state, bool isDark) {
    final xpPct = state.xpForNextLevel > 0 ? state.xpInLevel / state.xpForNextLevel : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2D2852), AppTheme.primaryDark]
              : [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${state.currentLevel}', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level ${state.currentLevel}', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('${state.xpInLevel} / ${state.xpForNextLevel} XP to next level',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AnimatedBuilder(
              animation: _xpAnimController,
              builder: (_, __) => LinearProgressIndicator(
                value: xpPct * _xpAnimController.value,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(TasksState state, bool isDark) {
    final pct = state.tasksTotal > 0 ? state.tasksDone / state.tasksTotal : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today\'s Progress', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.primaryDark)),
              Text('${state.tasksDone} / ${state.tasksTotal} done',
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 10,
            ),
          ),
          if (state.tasksDone == state.tasksTotal) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration_rounded, color: AppTheme.warningColor, size: 18),
                const SizedBox(width: 6),
                Text('All tasks complete! Great work today 🎉', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.warningColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatGrid(TasksState state, bool isDark) {
    final stats = [
      {'icon': Icons.bolt_rounded, 'label': 'Total XP', 'value': '${state.totalXp}', 'color': AppTheme.warningColor},
      {'icon': Icons.local_fire_department_rounded, 'label': 'Streak', 'value': '${state.streak} days', 'color': Colors.orangeAccent},
      {'icon': Icons.task_alt_rounded, 'label': 'Tasks', 'value': '${state.tasksDone} / ${state.tasksTotal}', 'color': AppTheme.successColor},
      {'icon': Icons.emoji_events_rounded, 'label': 'Level', 'value': '${state.currentLevel}', 'color': AppTheme.primaryColor},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) {
        final stat = stats[i];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 500 + (i * 100)),
          tween: Tween(begin: 0, end: 1),
          curve: Curves.easeOutBack,
          builder: (_, scale, __) => Transform.scale(scale: scale, child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 22),
                const SizedBox(height: 6),
                Text(stat['value'] as String, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.primaryDark),
                  textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(stat['label'] as String, style: GoogleFonts.outfit(fontSize: 9, color: Colors.grey),
                  textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          )),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppTheme.primaryDark)),
      ],
    );
  }

  void _onCompleteTask(TasksState state, int index) {
    HapticFeedback.mediumImpact();
    final prevLevel = state.currentLevel;
    ref.read(tasksProvider.notifier).completeTask(index);
    final newLevel = ref.read(tasksProvider).currentLevel;
    if (newLevel > prevLevel) {
      _showLevelUp(newLevel);
    }
  }

  Widget _buildTaskCard(TasksState state, int index, bool isDark) {
    final task = state.tasks[index];

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 80)),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (_, opacity, __) => Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - opacity)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: task.done
                  ? (AppTheme.successColor.withValues(alpha: 0.1))
                  : (isDark ? AppTheme.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: task.done
                    ? AppTheme.successColor.withValues(alpha: 0.3)
                    : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: task.done
                        ? AppTheme.successColor.withValues(alpha: 0.15)
                        : AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(task.emoji, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.label,
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600,
                          color: task.done ? Colors.grey : (isDark ? Colors.white : AppTheme.primaryDark)),
                      ),
                      Text('+${task.xp} XP', style: GoogleFonts.outfit(fontSize: 11, color: task.done ? Colors.grey : AppTheme.primaryColor)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: task.done ? null : () => _onCompleteTask(state, index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: task.done ? AppTheme.successColor : AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: task.done
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        : const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeGrid(TasksState state, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: state.badges.length,
      itemBuilder: (_, i) {
        final badge = state.badges[i];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: badge.earned
                ? (isDark ? AppTheme.darkCard : Colors.white)
                : (isDark ? AppTheme.darkSurface : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: badge.earned
                  ? AppTheme.primaryColor.withValues(alpha: 0.3)
                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(badge.emoji, style: TextStyle(fontSize: badge.earned ? 28 : 24)),
              const SizedBox(height: 6),
              Text(badge.label,
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600,
                  color: badge.earned ? (isDark ? Colors.white : AppTheme.primaryDark) : Colors.grey),
                textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(badge.description,
                style: GoogleFonts.outfit(fontSize: 9, color: Colors.grey.shade500),
                textAlign: TextAlign.center, maxLines: 1),
            ],
          ),
        );
      },
    );
  }
}
