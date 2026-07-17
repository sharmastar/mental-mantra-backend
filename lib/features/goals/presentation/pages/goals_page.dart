import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/goals_provider.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  static void _showAddGoalDialog(BuildContext context, WidgetRef ref) {
    final titleCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtl,
                decoration: const InputDecoration(
                    hintText: 'What do you want to achieve?',
                    labelText: 'Goal')),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                'Mindfulness',
                'Journaling',
                'Learning',
                'Sleep',
                'Fitness',
                'Social'
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleCtl.text.trim();
              if (title.isNotEmpty) {
                ref
                    .read(goalsProvider.notifier)
                    .addGoal(title: title, category: 'General');
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Goal created!'),
                  behavior: SnackBarBehavior.floating));
            },
            child: const Text('Create Goal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddGoalDialog(context, ref))
        ],
      ),
      body: state.goals.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.track_changes,
                      size: 72,
                      color: isDark ? Colors.white24 : Colors.black12),
                  const SizedBox(height: 16),
                  Text('No goals yet',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white60 : Colors.black54)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.goals.length,
              itemBuilder: (ctx, i) {
                final goal = state.goals[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isDark
                            ? AppTheme.darkBorder
                            : AppTheme.lightBorder),
                  ),
                  child: Row(
                    children: [
                      CircularPercentIndicator(
                        radius: 36,
                        lineWidth: 6,
                        percent: goal.progress,
                        progressColor: goal.color,
                        backgroundColor: goal.color.withValues(alpha: 0.15),
                        center: Icon(goal.icon, color: goal.color, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(goal.category,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: goal.progress,
                                backgroundColor:
                                    goal.color.withValues(alpha: 0.15),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(goal.color),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${goal.current} / ${goal.target}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text('${(goal.progress * 100).round()}%',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: goal.color,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
