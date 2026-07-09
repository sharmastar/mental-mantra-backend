import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/meditation_utils.dart';

import '../../data/models/journal_entry.dart';
import '../providers/journal_provider.dart';

class JournalDetailPage extends ConsumerWidget {
  final String entryId;
  const JournalDetailPage({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(journalEntryProvider(entryId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/home/journal/new', extra: {'entryId': entryId}),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Entry'),
                  content: const Text('Are you sure you want to delete this entry? This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirmed == true) {
                try {
                  // ignore: use_build_context_synchronously
                  await ref.read(journalEntryProvider(entryId).notifier).deleteEntry(entryId);
                  if (context.mounted) {
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
                  }
                }
              }
            },
          ),
        ],
      ),
      body: entryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('Could not load entry', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(e.toString(), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: () => ref.invalidate(journalEntryProvider(entryId)),
                ),
              ],
            ),
          ),
        ),
        data: (JournalEntry? entry) {
          if (entry == null) return const Center(child: Text('Entry not found'));
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Text(moodEmoji(entry.mood), style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(DateFormatUtils.formatTimestamp(entry.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Mood: ${moodLabel(entry.mood)}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
              const SizedBox(height: 20),
              if (entry.emotions.isNotEmpty) ...[
                Wrap(spacing: 6, runSpacing: 4, children: entry.emotions.map((e) => Chip(label: Text(e, style: const TextStyle(fontSize: 12)), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact)).toList()),
                const SizedBox(height: 20),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.content, style: theme.textTheme.bodyLarge?.copyWith(height: 1.7)),
                    if (entry.aiInsight != null && entry.aiInsight!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 6),
                          Text('AI Insight', style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(entry.aiInsight!, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600], height: 1.5)),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }


}
