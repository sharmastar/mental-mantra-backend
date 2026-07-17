import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLevelCard(theme),
          const SizedBox(height: 16),
          _buildStreakCard(theme),
          const SizedBox(height: 16),
          _buildCategorySection(context, theme, '🧘', 'Meditation', []),
          const SizedBox(height: 12),
          _buildCategorySection(context, theme, '📝', 'Journal', []),
          const SizedBox(height: 12),
          _buildCategorySection(context, theme, '🌟', 'Milestones', []),
        ],
      ),
    );
  }

  Widget _buildLevelCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🌟', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level 1: Beginner',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('0 XP',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                  value: 0.3, minHeight: 8, backgroundColor: Colors.grey[200]),
            ),
            const SizedBox(height: 8),
            Text('30 / 100 XP to Level 2', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(ThemeData theme) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.local_fire_department, color: Colors.orange),
        ),
        title: const Text('Current Streak'),
        subtitle: const Text('0 days'),
        trailing: Text('Best: 0 days', style: theme.textTheme.bodySmall),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, ThemeData theme,
      String emoji, String title, List list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('$emoji $title',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
        ...List.generate(4, (i) => _buildAchievementCard(context, theme, i)),
      ],
    );
  }

  Widget _buildAchievementCard(
      BuildContext context, ThemeData theme, int index) {
    final achievements = [
      {
        'title': 'First Meditation',
        'progress': 1.0,
        'icon': '🥇',
        'status': 'Completed'
      },
      {'title': '10 Sessions', 'progress': 0.3, 'icon': '🥈', 'status': '3/10'},
      {
        'title': '5 Hours Total',
        'progress': 0.15,
        'icon': '🥉',
        'status': '45min/5h'
      },
      {
        'title': '30 Day Streak',
        'progress': 0.0,
        'icon': '💎',
        'status': 'Locked'
      },
    ];
    final a = achievements[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading:
            Text(a['icon'] as String, style: const TextStyle(fontSize: 24)),
        title: Text(a['title'] as String, style: const TextStyle(fontSize: 14)),
        trailing: a['progress'] as double >= 1.0
            ? const Icon(Icons.check_circle, color: Colors.green)
            : Text(a['status'] as String, style: theme.textTheme.bodySmall),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('${a['icon']} ${a['title']}'),
              content: Text(a['progress'] as double >= 1.0
                  ? 'You completed this achievement!'
                  : 'Progress: ${a['status']}'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'))
              ],
            ),
          );
        },
      ),
    );
  }
}
