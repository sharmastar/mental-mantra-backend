import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../data/music_catalog.dart';
import '../../providers/audio_player_provider.dart';

class MusicPage extends ConsumerWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final categories = MusicCatalog.categories;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightBg,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.black26 : Colors.white70,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  color: isDark ? Colors.white : Colors.black87,
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.85),
                      isDark ? AppTheme.darkBg : AppTheme.lightBg,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.music_note_rounded,
                            color: Colors.white70, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Music Therapy',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${MusicCatalog.allTracks.length} healing frequencies & nature soundscapes',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.white70,
                            fontSize: 13,
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                categories
                    .map((cat) =>
                        _buildCategorySection(cat, context, ref, isDark, theme))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    MusicCategory cat,
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Icon(cat.icon, color: cat.color, size: 20),
              const SizedBox(width: 8),
              Text(
                cat.name,
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => ref
                    .read(audioPlayerProvider.notifier)
                    .playCategory(cat.name),
                child: Text(
                  'Play All',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: cat.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: cat.tracks.length,
            itemBuilder: (ctx, i) {
              final track = cat.tracks[i];
              return _MusicTrackCard(
                track: track,
                isDark: isDark,
                index: i,
              );
            },
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _MusicTrackCard extends ConsumerWidget {
  final MusicTrack track;
  final bool isDark;
  final int index;

  const _MusicTrackCard({
    required this.track,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrack = ref.watch(currentTrackProvider);
    final isActive =
        currentTrack?.id == track.id && ref.watch(isPlayingProvider);

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      child: PremiumBounceInteraction(
        onTap: () {
          final category = MusicCatalog.categories
              .firstWhere((c) => c.name == track.category);
          ref
              .read(audioPlayerProvider.notifier)
              .playTrack(track, queue: category.tracks);
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                track.color.withValues(alpha: isActive ? 0.25 : 0.12),
                track.color.withValues(alpha: 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28), // V4 28 border radius
            border: Border.all(
              color: isActive
                  ? track.color.withValues(alpha: 0.6)
                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: track.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isActive ? Icons.headphones_rounded : track.icon,
                    color: track.color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  track.title,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      track.formattedDuration,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isActive
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: track.color,
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: (index * 50).ms)
        .slideX(begin: 0.1, end: 0);
  }
}
