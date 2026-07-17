import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

class YogaListPage extends ConsumerWidget {
  const YogaListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      {
        'title': 'Morning Yoga',
        'icon': Icons.wb_sunny,
        'color': AppTheme.warningColor,
        'count': 8
      },
      {
        'title': 'Stress Relief',
        'icon': Icons.spa,
        'color': AppTheme.primaryColor,
        'count': 6
      },
      {
        'title': 'Flexibility',
        'icon': Icons.accessibility_new,
        'color': AppTheme.secondaryColor,
        'count': 5
      },
      {
        'title': 'Bedtime Yoga',
        'icon': Icons.bedtime,
        'color': AppTheme.primaryLight,
        'count': 4
      },
      {
        'title': 'Back & Neck',
        'icon': Icons.fitness_center,
        'color': AppTheme.errorColor,
        'count': 7
      },
      {
        'title': 'Energy Boost',
        'icon': Icons.bolt,
        'color': AppTheme.successColor,
        'count': 5
      },
    ];

    final featured = [
      {
        'title': 'Sun Salutation Flow',
        'duration': '15 min',
        'level': 'Beginner',
        'difficulty': 1
      },
      {
        'title': 'Stress Relief Sequence',
        'duration': '20 min',
        'level': 'All Levels',
        'difficulty': 2
      },
      {
        'title': 'Deep Stretch & Restore',
        'duration': '25 min',
        'level': 'Intermediate',
        'difficulty': 3
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppTheme.primaryGradient),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.self_improvement,
                            color: Colors.white54, size: 36),
                        SizedBox(height: 8),
                        Text('Yoga',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('Balance body and mind',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('Categories',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (ctx, i) {
                    final cat = categories[i];
                    final color = cat['color'] as Color;
                    return GestureDetector(
                      onTap: () => context.push('${AppRoutes.yoga}/$i'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(cat['icon'] as IconData,
                                  color: color, size: 28),
                              const SizedBox(height: 8),
                              Text(cat['title'] as String,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87)),
                              Text('${cat['count']} sessions',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text('Featured Sessions',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                ...featured.map((s) => GestureDetector(
                      onTap: () => context.push('${AppRoutes.yoga}/featured'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.self_improvement,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['title'] as String,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('${s['duration']} • ${s['level']}',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            ),
                            const Icon(Icons.play_circle_fill,
                                color: AppTheme.primaryColor),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
