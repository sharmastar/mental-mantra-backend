import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

class ContentManagementPage extends ConsumerWidget {
  const ContentManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(adminProvider);
    final stats = state.stats;

    return Scaffold(
      appBar: AppBar(title: const Text('Content Management')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Meditation & Exercise Curation',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildContentCategoryTile(
              context,
              'Guided Meditations',
              '${stats.totalMeditations} sessions active',
              Icons.self_improvement),
          const SizedBox(height: 12),
          _buildContentCategoryTile(context, 'Breathing Exercises',
              '${stats.totalBreathingPatterns} patterns configured', Icons.air),
          const SizedBox(height: 12),
          _buildContentCategoryTile(
              context,
              'Yoga Flows',
              '${stats.totalYogaFlows} routines mapped',
              Icons.accessibility_new),
          const SizedBox(height: 12),
          _buildContentCategoryTile(
              context,
              'Music Tracks',
              '${stats.totalMusicTracks} high-fidelity tracks',
              Icons.music_note),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContentDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Content'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Content'),
        content: const Text(
            'Content creation UI will be available in a future update.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _buildContentCategoryTile(
      BuildContext context, String name, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey)),
              ])),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => _showEditDialog(context, name),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $category'),
        content: const Text(
            'Editing functionality will be available in a future update.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}
