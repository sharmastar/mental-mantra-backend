import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../onboarding/data/classification_engine.dart';
import '../../../spiritual/presentation/pages/spiritual_page.dart';
import '../../data/intervention_data.dart';

final classificationResultProvider = StateProvider<ClassificationResult?>((ref) => null);

class TherapyToolsHub extends ConsumerWidget {
  const TherapyToolsHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    colors: [Color(0xFF6C63FF), Color(0xFF00BFA5)],
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
                        const Icon(Icons.healing_outlined, color: Colors.white, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Therapy Tools',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        Text(
                          'Mindfulness practices to support your journey',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                        ),
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
                _buildDomainBanner(context, ref, isDark),
                const SizedBox(height: 20),
                _buildToolGrid(context, isDark),
                const SizedBox(height: 24),
                _buildMusicTherapySection(context, isDark),
                const SizedBox(height: 24),
                _buildMeditationSection(context, isDark),
                const SizedBox(height: 24),
                _buildYogaSection(context, isDark),
                const SizedBox(height: 24),
                _buildWisdomSection(context, isDark),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainBanner(BuildContext context, WidgetRef ref, bool isDark) {
    final result = ref.watch(classificationResultProvider);
    if (result == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withValues(alpha: 0.1), AppTheme.primaryColor.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(result.primaryDomain.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Focus: ${result.primaryDomain.label}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                if (result.secondaryDomain != null)
                  Text(
                    'Supporting: ${result.secondaryDomain!.label}',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolGrid(BuildContext context, bool isDark) {
    final tools = [
      const _ToolItem('Venting Space', Icons.local_fire_department, Color(0xFFE53935), 'Burn away your frustrations', AppRoutes.ventingSpace),
      const _ToolItem('Music Therapy', Icons.music_note_outlined, AppTheme.primaryColor, 'Binaural beats, nature sounds, solfeggio', AppRoutes.music),
      const _ToolItem('Guided Meditation', Icons.self_improvement, AppTheme.secondaryColor, 'Target-specific sessions', AppRoutes.meditation),
      const _ToolItem('Yoga & Movement', Icons.accessibility_new, AppTheme.accentColor, 'Office stress, flexibility, energy', AppRoutes.yoga),
      const _ToolItem('Brain Games', Icons.psychology_outlined, Color(0xFF00BCD4), 'Focus, memory, pattern games', AppRoutes.games),
      const _ToolItem('Breathing Exercises', Icons.air_outlined, Color(0xFF00BFA5), 'Calm your nervous system', '\${AppRoutes.meditation}/timer'),
      const _ToolItem('Sleep Sounds', Icons.bedtime_outlined, Color(0xFF9C27B0), 'Rain, ocean, 432 Hz', AppRoutes.sleep),
      const _ToolItem('Meditation Videos', Icons.smart_display_outlined, Color(0xFFE91E63), 'Video tutorials & guides', AppRoutes.videos),
      const _ToolItem('Spiritual & Calm', Icons.wb_sunny_outlined, Color(0xFFFF9800), 'Calming spiritual insights', AppRoutes.spiritual),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Tools', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        )),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 1.4, mainAxisSpacing: 12, crossAxisSpacing: 12,
          ),
          itemCount: tools.length,
          itemBuilder: (ctx, i) {
            final t = tools[i];
            return GestureDetector(
              onTap: () => context.push(t.route),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [t.color.withValues(alpha: 0.1), t.color.withValues(alpha: 0.02)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(t.icon, color: t.color, size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text(t.title, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: t.color,
                    )),
                    Text(t.subtitle, style: TextStyle(
                      fontSize: 11, color: isDark ? Colors.white60 : Colors.black54,
                    ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMusicTherapySection(BuildContext context, bool isDark) {
    return _buildSection(
      context, isDark,
      icon: Icons.music_note_outlined,
      title: 'Music Therapy',
      color: AppTheme.primaryColor,
      items: musicInterventions,
      onTap: () => context.push(AppRoutes.music),
    );
  }

  Widget _buildMeditationSection(BuildContext context, bool isDark) {
    return _buildSection(
      context, isDark,
      icon: Icons.self_improvement,
      title: 'Target-Specific Meditations',
      color: AppTheme.secondaryColor,
      items: meditationInterventions,
      onTap: () => context.push(AppRoutes.meditation),
    );
  }

  Widget _buildYogaSection(BuildContext context, bool isDark) {
    return _buildSection(
      context, isDark,
      icon: Icons.accessibility_new,
      title: 'Yoga Routines',
      color: AppTheme.accentColor,
      items: yogaInterventions,
      onTap: () => context.push(AppRoutes.yoga),
    );
  }

  Widget _buildWisdomSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB547).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.self_improvement, color: Color(0xFFFFB547), size: 20),
            ),
            const SizedBox(width: 10),
            Text('Wisdom & Reflection', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            )),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpiritualPage())),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFFB547).withValues(alpha: 0.1), const Color(0xFFFFB547).withValues(alpha: 0.02)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB547).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB547).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('🕉️', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bhagavad Gita Wisdom', style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFFFB547),
                      )),
                      const SizedBox(height: 4),
                      Text(
                        'Ancient verses for modern challenges — slokas matched to how you feel',
                        style: TextStyle(
                          fontSize: 12, color: isDark ? Colors.white60 : Colors.black54, height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: const Color(0xFFFFB547).withValues(alpha: 0.5), size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpiritualPage())),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.secondaryColor.withValues(alpha: 0.1), AppTheme.secondaryColor.withValues(alpha: 0.02)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.spa, color: Color(0xFF00BFA5), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Secular Mindfulness', style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00BFA5),
                      )),
                      const SizedBox(height: 4),
                      Text(
                        'Non-religious reflection and grounding practices',
                        style: TextStyle(
                          fontSize: 12, color: isDark ? Colors.white60 : Colors.black54, height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryColor.withValues(alpha: 0.5), size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, bool isDark, {
    required IconData icon,
    required String title,
    required Color color,
    required List<String> items,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ))),
            GestureDetector(
              onTap: onTap,
              child: Text('View all →', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.take(3).map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppTheme.darkBorder : color.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.play_circle_outline, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(item, style: TextStyle(
                  fontSize: 13, color: isDark ? Colors.white70 : Colors.black87,
                ))),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ToolItem {
  final String title;
  final IconData icon;
  final Color color;
  final String subtitle;
  final String route;
  const _ToolItem(this.title, this.icon, this.color, this.subtitle, this.route);
}
