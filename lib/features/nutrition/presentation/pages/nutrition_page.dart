import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/nutrition_data.dart';
import '../providers/nutrition_provider.dart';

class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tips = allWellnessTips[state.selectedCategory] ?? [];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.restaurant_outlined, color: Colors.white, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Nutrition & Wellness',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        Text(
                          'Mindfulness-oriented habits for body and mind',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(isDark),
                  const SizedBox(height: 24),
                  _buildHydrationTracker(state, ref, isDark),
                  const SizedBox(height: 24),
                  _buildCategoryTabs(state, ref, isDark),
                  const SizedBox(height: 16),
                  _buildTipsList(tips, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: AppTheme.secondaryColor, size: 16),
            ),
            const SizedBox(width: 8),
            Text('Quick Actions', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            )),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: nutritionQuickActions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final action = nutritionQuickActions[i];
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('${action.title}: ${action.tip ?? action.body}'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ));
                },
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.secondaryColor.withValues(alpha: 0.1), AppTheme.secondaryColor.withValues(alpha: 0.02)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(action.title, style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.secondaryColor,
                      )),
                      const SizedBox(height: 4),
                      Text(action.body, style: TextStyle(
                        fontSize: 11, color: isDark ? Colors.white60 : Colors.black54,
                      ), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHydrationTracker(NutritionState state, WidgetRef ref, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00BCD4).withValues(alpha: 0.1), const Color(0xFF00BCD4).withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00BCD4).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_outlined, color: Color(0xFF00BCD4), size: 24),
              const SizedBox(width: 8),
              const Text('Water Intake', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF00BCD4),
              )),
              const Spacer(),
              Text('${state.waterGlasses} / 8 glasses', style: TextStyle(
                fontSize: 13, color: isDark ? Colors.white60 : Colors.black54,
              )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(8, (i) {
              final filled = i < state.waterGlasses;
              return GestureDetector(
                onTap: () => ref.read(nutritionProvider.notifier).setWaterGlasses(filled ? i : i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36, height: 48,
                  decoration: BoxDecoration(
                    color: filled ? const Color(0xFF00BCD4) : const Color(0xFF00BCD4).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: filled ? const Color(0xFF00BCD4) : const Color(0xFF00BCD4).withValues(alpha: 0.3),
                    ),
                  ),
                  child: filled
                      ? const Icon(Icons.water_drop, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            state.waterGlasses >= 8 ? 'Great job! You\'ve met your hydration goal 🎉' : 'Tip: Keep a water bottle nearby as a gentle reminder',
            style: TextStyle(
              fontSize: 12, fontStyle: FontStyle.italic,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(NutritionState state, WidgetRef ref, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wellness Tips', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        )),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: WellnessCategory.values.where((c) => c != WellnessCategory.energyFoods).map((cat) {
              final isSelected = state.selectedCategory == cat;
              return GestureDetector(
                onTap: () => ref.read(nutritionProvider.notifier).selectCategory(cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [cat.color, cat.color.withValues(alpha: 0.6)])
                        : null,
                    color: isSelected ? null : (isDark ? AppTheme.darkCard : AppTheme.lightSurface),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, color: isSelected ? Colors.white : cat.color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsList(List<WellnessTip> tips, bool isDark) {
    if (tips.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Tips coming soon for this category',
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          ),
        ),
      );
    }

    return Column(
      children: tips.map((tip) {
        final index = tips.indexOf(tip);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : tip.category.color.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tip.category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tip.icon, color: tip.category.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.emoji != null ? '${tip.emoji} ${tip.title}' : tip.title,
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip.description,
                      style: TextStyle(
                        fontSize: 13, color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (index * 80).ms).slideX(begin: 0.05, end: 0);
      }).toList(),
    );
  }
}
