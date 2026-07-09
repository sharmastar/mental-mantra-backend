import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../music/presentation/widgets/modern_mini_player.dart';
import '../../../music/providers/audio_player_provider.dart';
import '../../../music/providers/background_music_provider.dart';
import '../../../ai/presentation/widgets/chat_floating_widget.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Home', route: AppRoutes.dashboard),
    _NavItem(icon: Icons.book_outlined, activeIcon: Icons.book, label: 'Journal', route: AppRoutes.journal),
    _NavItem(icon: Icons.psychology_outlined, activeIcon: Icons.psychology, label: 'Nova', route: AppRoutes.aiChat),
    _NavItem(icon: Icons.self_improvement_outlined, activeIcon: Icons.self_improvement, label: 'Meditate', route: AppRoutes.meditation),
    _NavItem(icon: Icons.healing_outlined, activeIcon: Icons.healing, label: 'Recovery', route: AppRoutes.recovery),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackActive = ref.watch(hasActiveTrack);
    final location = GoRouterState.of(context).matchedLocation;
    final matchedIndex = _navItems.indexWhere((item) => location.startsWith(item.route));
    final currentIndex = matchedIndex != -1 ? matchedIndex : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: ChatFloatingWidget(
        child: OfflineBanner(
          child: Column(
            children: [
              Expanded(child: child),
              if (trackActive) const ModernMiniPlayer(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => ref.read(backgroundMusicProvider.notifier).toggle(),
        backgroundColor: ref.watch(backgroundMusicProvider) ? AppTheme.primaryColor : (isDark ? AppTheme.darkCard : AppTheme.lightSurface),
        tooltip: ref.watch(backgroundMusicProvider) ? 'Stop 963Hz Background Music' : 'Play 963Hz Background Music',
        child: Icon(
          ref.watch(backgroundMusicProvider) ? Icons.music_note : Icons.music_note_outlined,
          color: ref.watch(backgroundMusicProvider) ? Colors.white : Colors.grey,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = currentIndex == index;
                return _NavBarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    context.go(item.route);
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                item.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
