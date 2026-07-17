import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../providers/content_provider.dart';

final _categories = [
  'All',
  'Featured',
  'Educational',
  'Motivation',
  'Movement',
  'Sleep',
  'Wellness',
  'Recovery',
  'Meditation',
  'Games'
];

class ContentFeedPage extends ConsumerWidget {
  const ContentFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(contentProvider);
    final filtered = state.filteredItems;
    final featured = state.featuredItems;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.explore_outlined,
                            color: Colors.white, size: 32),
                        SizedBox(height: 6),
                        Text('Discover',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 44,
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  final isSelected = state.selectedCategory == cat;
                  return GestureDetector(
                    onTap: () =>
                        ref.read(contentProvider.notifier).selectCategory(cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.primaryGradient : null,
                        color: isSelected
                            ? null
                            : (isDark
                                ? AppTheme.darkCard
                                : AppTheme.lightSurface),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark
                                    ? AppTheme.darkBorder
                                    : AppTheme.lightBorder)),
                      ),
                      child: Center(
                          child: Text(cat,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black87),
                              ))),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  if (i == 0 && state.selectedCategory == 'All') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFeatured(context, featured, isDark),
                        const SizedBox(height: 8),
                      ],
                    );
                  }
                  final adjustedIndex =
                      state.selectedCategory == 'All' ? i - 1 : i;
                  if (adjustedIndex >= filtered.length) return null;
                  return _buildFeedCard(context, filtered[adjustedIndex],
                          isDark, adjustedIndex)
                      .animate()
                      .fadeIn(
                        duration: 300.ms,
                        delay: (adjustedIndex * 60).ms,
                      )
                      .slideX(begin: 0.05, end: 0);
                },
                childCount:
                    filtered.length + (state.selectedCategory == 'All' ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatured(
      BuildContext context, List<dynamic> featured, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('Featured',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87)),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final f = featured[i];
              return GestureDetector(
                onTap: () => _navigateToItem(context, f),
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [f.color, f.color.withValues(alpha: 0.4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(f.icon, color: Colors.white, size: 20)),
                        const Spacer(),
                        Text(f.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(f.subtitle,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12)),
                      ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedCard(
      BuildContext context, dynamic item, bool isDark, int index) {
    return GestureDetector(
      onTap: () => _navigateToItem(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isDark
                  ? AppTheme.darkBorder
                  : item.color.withValues(alpha: 0.12)),
        ),
        child: Row(children: [
          Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(item.icon, color: item.color, size: 24)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(item.category,
                          style: TextStyle(
                              fontSize: 10,
                              color: item.color,
                              fontWeight: FontWeight.w600))),
                  if (item.videoId != null) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.play_circle_outline,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    const Text('Video',
                        style: TextStyle(fontSize: 10, color: Colors.grey))
                  ],
                ]),
                const SizedBox(height: 6),
                Text(item.title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87)),
                Text(item.subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54)),
              ])),
          Icon(Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.black26),
        ]),
      ),
    );
  }

  void _navigateToItem(BuildContext context, dynamic item) {
    if (item.route != null) {
      context.push(item.route!);
    } else if (item.videoId != null) {
      context.push(AppRoutes.videos);
    }
  }
}
