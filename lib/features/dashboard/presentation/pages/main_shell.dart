import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../music/presentation/widgets/modern_mini_player.dart';
import '../../../music/providers/audio_player_provider.dart';
import '../../../wellness/providers/wellness_score_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _navItems = [
    _NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Home',
        route: AppRoutes.dashboard),
    _NavItem(
        icon: Icons.book_outlined,
        activeIcon: Icons.book,
        label: 'Journal',
        route: AppRoutes.journal),
    _NavItem(
        icon: Icons.psychology_outlined,
        activeIcon: Icons.psychology,
        label: 'Nova',
        route: AppRoutes.aiChat),
    _NavItem(
        icon: Icons.self_improvement_outlined,
        activeIcon: Icons.self_improvement,
        label: 'Meditate',
        route: AppRoutes.meditation),
    _NavItem(
        icon: Icons.healing_outlined,
        activeIcon: Icons.healing,
        label: 'Recovery',
        route: AppRoutes.recovery),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(wellnessScoreUpdaterProvider);
    final trackActive = ref.watch(hasActiveTrack);
    final location = GoRouterState.of(context).matchedLocation;
    final matchedIndex =
        _navItems.indexWhere((item) => location.startsWith(item.route));
    final currentIndex = matchedIndex != -1 ? matchedIndex : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: OfflineBanner(
        child: Column(
          children: [
            Expanded(child: child),
            if (trackActive) const ModernMiniPlayer(),
          ],
        ),
      ),
      bottomNavigationBar: Semantics(
        label: 'Main navigation',
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppDesign.darkSurface : AppDesign.lightSurface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppDesign.darkBorder : AppDesign.lightBorder,
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom > 0 ? 0 : AppDesign.space4,
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,
                elevation: 0,
                height: 64,
                onDestinationSelected: (index) {
                  HapticFeedback.lightImpact();
                  context.go(_navItems[index].route);
                },
                backgroundColor: Colors.transparent,
                destinations: _navItems.map((item) {
                  return NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.activeIcon),
                    label: item.label,
                  );
                }).toList(),
              ),
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
