import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../../../../core/widgets/premium_empty_state.dart';
import '../../../../core/utils/meditation_utils.dart';

class JournalListPage extends ConsumerWidget {
  const JournalListPage({super.key});

  static void _showSearchDialog(BuildContext context, String userId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search Journal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'Search entries...', prefixIcon: Icon(Icons.search)),
        ),
        actions: [
          TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.pop(ctx);
              },
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final query = controller.text.trim();
              controller.dispose();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Searching for "$query"...'),
                  behavior: SnackBarBehavior.floating));
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider.select((u) => u?.uid ?? ''));
    final entriesAsync = ref.watch(journalListProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('My Journal'), actions: [
        IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, userId)),
      ]),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildErrorState(context, ref, e, userId),
        data: (entries) {
          if (entries.isEmpty) return _buildEmptyState(context);
          return RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(journalListProvider(userId).future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildHeader(context, entries);
                final entry = entries[index - 1];
                return _buildEntryCard(context, entry);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () => context.push(AppRoutes.journalNew),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<JournalEntry> entries) {
    final recent = entries.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStat(context, '${entries.length}', 'Entries'),
            _buildStat(context, _avgMood(entries), 'Avg Mood'),
            _buildStat(context, _streak(entries), 'Showing Up'),
          ],
        ),
        const SizedBox(height: 16),
        if (recent.isNotEmpty) ...[
          Text('Recent', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: Theme.of(context).textTheme.bodySmall)
          ]),
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, JournalEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/home/journal/${entry.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(moodEmoji(entry.mood),
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(entry.title,
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  Text(DateFormatUtils.formatTimestamp(entry.createdAt),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              if (entry.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(entry.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600])),
              ],
              if (entry.emotions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                    spacing: 4,
                    children: entry.emotions
                        .take(3)
                        .map((e) => Chip(
                            label:
                                Text(e, style: const TextStyle(fontSize: 10)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact))
                        .toList()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, WidgetRef ref, Object error, String userId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Could not load entries',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(error.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () => ref.invalidate(journalListProvider(userId)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return PremiumEmptyState(
      icon: Icons.book_outlined,
      title: 'Your Thoughts Await',
      description:
          'Start writing to document your moments and allow Nova to help you reflect on your patterns.',
      actionLabel: 'Write First Entry',
      onAction: () => context.push(AppRoutes.journalNew),
    );
  }

  String _avgMood(List<JournalEntry> entries) {
    if (entries.isEmpty) return '-';
    return (entries.fold(0.0, (s, e) => s + e.mood) / entries.length)
        .toStringAsFixed(1);
  }

  String _streak(List<JournalEntry> entries) {
    if (entries.isEmpty) return '0';
    final sorted = List<JournalEntry>.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < sorted.length; i++) {
      final expected = now.subtract(Duration(days: i));
      if (DateFormatUtils.isSameDay(sorted[i].createdAt, expected)) {
        streak++;
      } else if (sorted[i].createdAt.isBefore(expected)) {
        break;
      }
    }
    return streak.toString();
  }
}
