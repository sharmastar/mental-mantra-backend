// lib/features/meditation/presentation/pages/meditation_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';

class MeditationPage extends StatelessWidget {
  const MeditationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightBg,
            elevation: 0,
            leading: Center(
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  color: Colors.white,
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient:
                      isDark ? AppTheme.nightGradient : AppTheme.calmGradient,
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.self_improvement,
                            color: Colors.white, size: 36), // fallback or white
                        SizedBox(height: 8),
                        Text(
                          'Meditate',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Find your inner calm and comfort',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildQuickTools(context, isDark, theme),
                const SizedBox(height: 32),
                _buildCategorySection(context, isDark, theme),
                const SizedBox(height: 32),
                _buildFeaturedSection(context, isDark, theme),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTools(BuildContext context, bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tools for Presence',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PremiumBounceInteraction(
                onTap: () => context.push('${AppRoutes.meditation}/timer'),
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    ),
                    boxShadow:
                        isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_bottom_rounded,
                            size: 32, color: AppTheme.primaryColor),
                        SizedBox(height: 12),
                        Text(
                          'Silent Timer',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Self-guided practice',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PremiumBounceInteraction(
                onTap: () => context.push('${AppRoutes.meditation}/breathing'),
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    ),
                    boxShadow:
                        isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.air, size: 32, color: AppTheme.primaryLight),
                        SizedBox(height: 12),
                        Text(
                          'Breathing',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Guided rhythms',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection(
      BuildContext context, bool isDark, ThemeData theme) {
    final categories = [
      {
        'icon': Icons.wind_power,
        'label': 'Stress',
        'color': const Color(0xFF6C63FF)
      },
      {
        'icon': Icons.bedtime,
        'label': 'Sleep',
        'color': const Color(0xFF9C27B0)
      },
      {
        'icon': Icons.psychology,
        'label': 'Focus',
        'color': const Color(0xFF00BCD4)
      },
      {
        'icon': Icons.favorite_border,
        'label': 'Anxiety',
        'color': const Color(0xFFFF6B9D)
      },
      {
        'icon': Icons.whatshot,
        'label': 'Anger',
        'color': const Color(0xFFFF5722)
      },
      {
        'icon': Icons.volunteer_activism,
        'label': 'Self Love',
        'color': const Color(0xFFE91E63)
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.35,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: categories.length,
          itemBuilder: (ctx, i) {
            final cat = categories[i];
            final color = cat['color'] as Color;
            return PremiumBounceInteraction(
              onTap: () {
                context.push('${AppRoutes.meditation}/player',
                    extra: {'category': cat['label']});
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                  boxShadow:
                      isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat['icon'] as IconData,
                            color: color, size: 22),
                      ),
                      Text(
                        cat['label'] as String,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(
      BuildContext context, bool isDark, ThemeData theme) {
    final sessions = [
      {
        'title': 'Morning Calm',
        'duration': '10 min',
        'level': 'Beginner',
        'gradient': AppTheme.sunriseGradient,
        'icon': Icons.wb_sunny_rounded
      },
      {
        'title': 'Deep Sleep Journey',
        'duration': '20 min',
        'level': 'All levels',
        'gradient': AppTheme.nightGradient,
        'icon': Icons.dark_mode_rounded
      },
      {
        'title': 'Focus Flow',
        'duration': '15 min',
        'level': 'Intermediate',
        'gradient': AppTheme.primaryGradient,
        'icon': Icons.bubble_chart_rounded
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Sessions',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ...sessions.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: PremiumBounceInteraction(
                onTap: () =>
                    context.push('${AppRoutes.meditation}/player', extra: s),
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: s['gradient'] as LinearGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow:
                        isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                s['title'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Playfair Display',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${s['duration']} • ${s['level']}',
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          s['icon'] as IconData,
                          color: Colors.white30,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
