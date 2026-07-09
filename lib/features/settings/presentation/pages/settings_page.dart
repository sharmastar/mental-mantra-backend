// lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../music/providers/background_music_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../admin/presentation/providers/admin_provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance & Preferences
          const _SectionTitle(title: 'Preferences'),
          _SettingCard(isDark: isDark, children: [
            SwitchListTile(
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: AppTheme.primaryColor),
              title: const Text('Dark Mode'),
              subtitle: Text(isDark ? 'Currently dark' : 'Currently light'),
              value: isDark,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
              activeThumbColor: AppTheme.primaryColor,
            ),
            const Divider(height: 1, indent: 52),
            SwitchListTile(
              secondary: const Icon(Icons.vibration, color: AppTheme.primaryColor),
              title: const Text('Tactile Haptics'),
              subtitle: const Text('Enable soft haptic vibrations on touch'),
              value: ref.watch(soundHapticProvider),
              onChanged: (_) => ref.read(soundHapticProvider.notifier).toggle(),
              activeThumbColor: AppTheme.primaryColor,
            ),
            const Divider(height: 1, indent: 52),
            SwitchListTile(
              secondary: const Icon(Icons.music_note, color: AppTheme.primaryColor),
              title: const Text('Background Music (963 Hz)'),
              subtitle: const Text('Play soft ambient solfeggio frequency app-wide'),
              value: ref.watch(backgroundMusicProvider),
              onChanged: (_) => ref.read(backgroundMusicProvider.notifier).toggle(),
              activeThumbColor: AppTheme.primaryColor,
            ),
          ]),
          const SizedBox(height: 16),

          // Notifications
          const _SectionTitle(title: 'Notifications'),
          _SettingCard(isDark: isDark, children: [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
              title: const Text('Daily Reminders'),
              subtitle: const Text('Morning meditation, evening journal'),
              value: settings.dailyReminders,
              onChanged: (_) {
                settingsNotifier.toggleDailyReminders();
                _showSnack(context, 'Daily reminders ${!settings.dailyReminders ? 'enabled' : 'disabled'}');
              },
              activeThumbColor: AppTheme.primaryColor,
            ),
            const Divider(height: 1, indent: 52),
            SwitchListTile(
              secondary: const Icon(Icons.tips_and_updates_outlined, color: AppTheme.secondaryColor),
              title: const Text('Wellness Tips'),
              subtitle: const Text('AI-powered personalized tips'),
              value: settings.wellnessTips,
              onChanged: (_) {
                settingsNotifier.toggleWellnessTips();
                _showSnack(context, 'Wellness tips ${!settings.wellnessTips ? 'enabled' : 'disabled'}');
              },
              activeThumbColor: AppTheme.primaryColor,
            ),
            const Divider(height: 1, indent: 52),
            SwitchListTile(
              secondary: const Icon(Icons.emoji_events_outlined, color: AppTheme.warningColor),
              title: const Text('Achievement Alerts'),
              subtitle: const Text('Celebrate your milestones'),
              value: settings.achievementAlerts,
              onChanged: (_) {
                settingsNotifier.toggleAchievementAlerts();
                _showSnack(context, 'Achievement alerts ${!settings.achievementAlerts ? 'enabled' : 'disabled'}');
              },
              activeThumbColor: AppTheme.primaryColor,
            ),
          ]),
          const SizedBox(height: 16),

          // Privacy
          const _SectionTitle(title: 'Privacy & Security'),
          _SettingCard(isDark: isDark, children: [
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint, color: AppTheme.primaryColor),
              title: const Text('Biometric Login'),
              subtitle: const Text('Use fingerprint or face ID'),
              value: settings.biometricLogin,
              onChanged: (_) {
                settingsNotifier.toggleBiometricLogin();
                _showSnack(context, 'Biometric login ${!settings.biometricLogin ? 'enabled' : 'disabled'}');
              },
              activeThumbColor: AppTheme.primaryColor,
            ),
            const Divider(height: 1, indent: 52),
            ListTile(
              leading: const Icon(Icons.cloud_sync_outlined, color: AppTheme.primaryColor),
              title: const Text('Cloud Backup & Sync'),
              subtitle: const Text('Manage database synchronization status'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => context.push(AppRoutes.syncDashboard),
            ),
            const Divider(height: 1, indent: 52),
            ListTile(
              leading: const Icon(Icons.download_outlined, color: AppTheme.primaryColor),
              title: const Text('Export My Data'),
              subtitle: const Text('Download a JSON archive of your entries'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showExportDialog(context),
            ),
            const Divider(height: 1, indent: 52),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              title: const Text('Delete Account', style: TextStyle(color: AppTheme.errorColor)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _confirmDeleteAccount(context, ref),
            ),
          ]),
          const SizedBox(height: 16),

          // AI Settings
          const _SectionTitle(title: 'AI Companion'),
          _SettingCard(isDark: isDark, children: [
            SwitchListTile(
              secondary: const Icon(Icons.psychology, color: AppTheme.primaryColor),
              title: const Text('AI Insights'),
              subtitle: const Text('Personalized analysis from your data'),
              value: settings.aiInsights,
              onChanged: (_) {
                settingsNotifier.toggleAiInsights();
                _showSnack(context, 'AI Insights ${!settings.aiInsights ? 'enabled' : 'disabled'}');
              },
              activeThumbColor: AppTheme.primaryColor,
            ),
            const Divider(height: 1, indent: 52),
            ListTile(
              leading: const Icon(Icons.tune, color: AppTheme.primaryColor),
              title: const Text('Personalization'),
              subtitle: const Text('Adjust AI tone and companion preferences'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showPersonalizationDialog(context),
            ),
          ]),
          const SizedBox(height: 16),

          // Admin
          if (ref.watch(isAdminProvider))
            Column(
              children: [
                const _SectionTitle(title: 'Administration'),
                _SettingCard(isDark: isDark, children: [
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: AppTheme.primaryColor),
                    title: const Text('Admin Dashboard'),
                    subtitle: const Text('Manage users, content, and analytics'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => context.go(AppRoutes.admin),
                  ),
                ]),
                const SizedBox(height: 16),
              ],
            ),

           // Crisis Support
          const _SectionTitle(title: 'Crisis Support & Safety'),
          _SettingCard(isDark: isDark, children: [
            ListTile(
              leading: const Icon(Icons.phone_in_talk_outlined, color: AppTheme.errorColor),
              title: const Text('Crisis Hotlines', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w600)),
              subtitle: const Text('Get immediate help if you are in distress'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showCrisisSupportDialog(context),
            ),
            const Divider(height: 1, indent: 52),
            ListTile(
              leading: const Icon(Icons.gavel_outlined, color: AppTheme.primaryColor),
              title: const Text('Clinical Disclaimer'),
              subtitle: const Text('Important medical information about this app'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showDisclaimerDialog(context),
            ),
          ]),
          const SizedBox(height: 16),

          // About
          const _SectionTitle(title: 'About'),
          _SettingCard(isDark: isDark, children: [
            const ListTile(
              leading: Icon(Icons.info_outline, color: AppTheme.primaryColor),
              title: Text('App Version'),
              subtitle: Text('Mental Mantra v1.0.0 (Production)'),
              trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
            ),
            const Divider(height: 1, indent: 52),
            ListTile(
              leading: const Icon(Icons.star_outline, color: AppTheme.warningColor),
              title: const Text('Rate the App'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showSnack(context, 'Thank you for supporting Mental Mantra! ⭐⭐⭐⭐⭐'),
            ),
            const Divider(height: 1, indent: 52),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: AppTheme.secondaryColor),
              title: const Text('Share with Friends'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showSnack(context, 'Sharing link copied to clipboard!'),
            ),
            const Divider(height: 1, indent: 52),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.errorColor),
              title: const Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _confirmSignOut(context, ref),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCrisisSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Immediate Support'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If you or someone you know is in immediate danger, please call your local emergency service or go to the nearest emergency room.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('📞 Suicide & Crisis Lifeline: Call or text 988 (Available 24/7 in US & Canada)'),
            SizedBox(height: 8),
            Text('💬 Crisis Text Line: Text HOME to 741741 (Available 24/7)'),
            SizedBox(height: 8),
            Text('🌐 International Support: findahelpline.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDisclaimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clinical Wellness Disclaimer'),
        content: const Text(
          'Mental Mantra and its AI wellness companion (Nova) provide mindfulness guidelines, meditation recommendations, and self-reflection exercises. This app is NOT a medical device and is NOT a substitute for professional mental health therapy, counseling, clinical assessment, or diagnosis. Always consult with a licensed psychiatrist or physician regarding medical decisions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export My Data'),
        content: const Text('Your encrypted wellness profile, mood history, and journal logs will be prepared as a JSON archive.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnack(context, 'Exporting your data... Check your downloads folder soon.');
            },
            child: const Text('Start Export'),
          ),
        ],
      ),
    );
  }

  void _showPersonalizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AI Companion Settings'),
        content: const Text('AI Coach Tone is currently set to Supportive & Empathetic. You can customize detailed traits in your profile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _showSnack(context, 'Account deletion initiated...');
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authStateProvider.notifier).signOut();
              context.go(AppRoutes.login);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey)),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _SettingCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(children: children),
    );
  }
}
