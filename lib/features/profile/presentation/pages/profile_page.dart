// lib/features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.white24,
                            backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                            child: user?.photoUrl == null
                                ? Text(
                                    user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : 'U',
                                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 32, height: 32,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, size: 18, color: AppTheme.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(user?.displayName ?? 'User', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(user?.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 16),
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatChip(icon: Icons.bolt, value: '${user?.streakDays ?? 0}', label: 'Streak'),
                          const SizedBox(width: 24),
                          _StatChip(icon: Icons.star, value: '${user?.totalPoints ?? 0}', label: 'Points'),
                          const SizedBox(width: 24),
                          _StatChip(icon: Icons.emoji_events, value: 'Lv ${user?.level ?? 1}', label: 'Level'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Wellness Stats
                _buildStatsCard(isDark),
                const SizedBox(height: 20),

                // Menu Items
                _buildMenuSection('Account', [
                  _MenuItem(icon: Icons.person_outline, label: 'Edit Profile', onTap: () => _showComingSoon(context)),
                  _MenuItem(icon: Icons.lock_outline, label: 'Change Password', onTap: () => _showComingSoon(context)),
                  _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => context.push(AppRoutes.settings)),
                ], isDark),
                const SizedBox(height: 16),

                _buildMenuSection('Wellness', [
                  _MenuItem(icon: Icons.track_changes, label: 'My Goals', onTap: () => context.push(AppRoutes.goals)),
                  _MenuItem(icon: Icons.insights, label: 'Mood History', onTap: () => context.push(AppRoutes.mood)),
                  _MenuItem(icon: Icons.book_outlined, label: 'Journal Archive', onTap: () => context.push(AppRoutes.journal)),
                  _MenuItem(icon: Icons.star_outline, label: 'Achievements', onTap: () => context.push(AppRoutes.achievements)),
                ], isDark),
                const SizedBox(height: 16),

                _buildMenuSection('Support', [
                  _MenuItem(icon: Icons.help_outline, label: 'Help & FAQ', onTap: () => _showComingSoon(context)),
                  _MenuItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () => _showComingSoon(context)),
                  _MenuItem(icon: Icons.description_outlined, label: 'Terms of Service', onTap: () => _showComingSoon(context)),
                  _MenuItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () => context.push(AppRoutes.settings)),
                ], isDark),
                const SizedBox(height: 16),

                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, ref),
                    icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                    label: const Text('Sign Out', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w600, fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.errorColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Month', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MonthStat(emoji: '🧘', value: '18', label: 'Meditations'),
              _MonthStat(emoji: '📝', value: '12', label: 'Journals'),
              _MonthStat(emoji: '😊', value: '24', label: 'Mood Logs'),
              _MonthStat(emoji: '🎯', value: '3', label: 'Goals'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(e.value.icon, size: 22, color: AppTheme.primaryColor),
                    title: Text(e.value.label, style: const TextStyle(fontSize: 15)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    onTap: e.value.onTap,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  ),
                  if (!isLast) Divider(height: 1, indent: 52, color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authStateProvider.notifier).signOut();
      if (context.mounted) context.go(AppRoutes.login);
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!'), behavior: SnackBarBehavior.floating),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatChip({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}

class _MonthStat extends StatelessWidget {
  final String emoji, value, label;
  const _MonthStat({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
}
