import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/habits_provider.dart';

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Daily Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHabit(context, ref),
          ),
        ],
      ),
      body: state.habits.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.checklist_rounded, size: 72, color: isDark ? Colors.white24 : Colors.black12),
                    const SizedBox(height: 16),
                    Text('No habits yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white60 : Colors.black54)),
                    const SizedBox(height: 8),
                    Text('Tap + to add your first habit', style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.black38)),
                  ],
                ),
              ),
            )
          : Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today's Progress", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text('${state.completedCount} / ${state.totalCount} habits', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: state.completionRatio,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                CircularPercentIndicator(
                  radius: 44,
                  lineWidth: 8,
                  percent: state.completionRatio,
                  progressColor: Colors.white,
                  backgroundColor: Colors.white24,
                  center: Text('${(state.completionRatio * 100).round()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.habits.length,
              itemBuilder: (ctx, i) {
                final habit = state.habits[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: habit.done ? habit.color.withValues(alpha: 0.4) : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => ref.read(habitsProvider.notifier).toggleHabit(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: habit.done ? habit.color.withValues(alpha: 0.15) : habit.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: habit.done ? Border.all(color: habit.color, width: 2) : null,
                          ),
                          child: habit.done
                              ? Icon(Icons.check, color: habit.color, size: 28)
                              : Icon(habit.icon, color: habit.color, size: 26),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                decoration: habit.done ? TextDecoration.lineThrough : null,
                                color: habit.done ? Colors.grey : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.bolt, size: 14, color: AppTheme.warningColor),
                                Text(' ${habit.streak} day streak', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (habit.done)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: habit.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('Done ✓', style: TextStyle(color: habit.color, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddHabit(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final colors = [
      AppTheme.primaryColor,
      const Color(0xFF00BCD4),
      const Color(0xFF4CAF50),
      const Color(0xFFFF6B9D),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
    ];
    Color selectedColor = colors[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Habit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Habit name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Text('Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Row(
                children: colors.map((c) => GestureDetector(
                  onTap: () => setSheetState(() => selectedColor = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: selectedColor == c ? 1.0 : 0.3),
                      shape: BoxShape.circle,
                      border: selectedColor == c ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a habit name')),
                      );
                      return;
                    }
                    ref.read(habitsProvider.notifier).addHabit(title: name, color: selectedColor);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  child: const Text('Add Habit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
