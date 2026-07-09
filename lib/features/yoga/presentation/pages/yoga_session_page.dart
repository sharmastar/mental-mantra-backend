import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

class YogaSessionPage extends ConsumerWidget {
  final String sessionId;
  const YogaSessionPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final poses = [
      {'name': 'Mountain Pose', 'sanskrit': 'Tadasana', 'duration': '30 sec', 'image': '🧘'},
      {'name': 'Forward Fold', 'sanskrit': 'Uttanasana', 'duration': '45 sec', 'image': '🧎'},
      {'name': 'Plank Pose', 'sanskrit': 'Phalakasana', 'duration': '30 sec', 'image': '🏋️'},
      {'name': 'Downward Dog', 'sanskrit': 'Adho Mukha Svanasana', 'duration': '45 sec', 'image': '🐕'},
      {'name': 'Warrior I', 'sanskrit': 'Virabhadrasana I', 'duration': '45 sec', 'image': '⚔️'},
      {'name': 'Warrior II', 'sanskrit': 'Virabhadrasana II', 'duration': '45 sec', 'image': '⚔️'},
      {'name': 'Triangle Pose', 'sanskrit': 'Trikonasana', 'duration': '30 sec', 'image': '🔺'},
      {'name': 'Child Pose', 'sanskrit': 'Balasana', 'duration': '60 sec', 'image': '🧒'},
      {'name': 'Corpse Pose', 'sanskrit': 'Savasana', 'duration': '120 sec', 'image': '😌'},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Yoga Session'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: AppTheme.calmGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.self_improvement, size: 52, color: Colors.white),
                  const SizedBox(height: 12),
                  Text('Sun Salutation Flow', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('15 min • Beginner', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Session'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(theme, '9', 'Poses'),
              _buildStat(theme, '15 min', 'Duration'),
              _buildStat(theme, 'Easy', 'Difficulty'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Poses', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...poses.asMap().entries.map((entry) {
            final pose = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              child: ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(pose['image'] as String, style: const TextStyle(fontSize: 22))),
                ),
                title: Text(pose['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(pose['sanskrit'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: Text(pose['duration'] as String, style: TextStyle(color: Colors.grey[600])),
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStat(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }
}
