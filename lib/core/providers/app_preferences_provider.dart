import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final Locale? locale;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool backgroundMusicEnabled;
  final int themeMode; // 0=system, 1=light, 2=dark
  final bool dataSaverMode;
  final bool autoDownloadMeditations;
  final bool analyticsEnabled;

  const AppPreferences({
    this.locale,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.backgroundMusicEnabled = false,
    this.themeMode = 2,
    this.dataSaverMode = false,
    this.autoDownloadMeditations = false,
    this.analyticsEnabled = true,
  });

  AppPreferences copyWith({
    Locale? locale,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? backgroundMusicEnabled,
    int? themeMode,
    bool? dataSaverMode,
    bool? autoDownloadMeditations,
    bool? analyticsEnabled,
    bool clearLocale = false,
  }) {
    return AppPreferences(
      locale: clearLocale ? null : (locale ?? this.locale),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      backgroundMusicEnabled: backgroundMusicEnabled ?? this.backgroundMusicEnabled,
      themeMode: themeMode ?? this.themeMode,
      dataSaverMode: dataSaverMode ?? this.dataSaverMode,
      autoDownloadMeditations: autoDownloadMeditations ?? this.autoDownloadMeditations,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }
}

class AppPreferencesNotifier extends StateNotifier<AppPreferences> {
  AppPreferencesNotifier() : super(const AppPreferences()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = AppPreferences(
        notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
        soundEnabled: prefs.getBool('sound_enabled') ?? true,
        hapticsEnabled: prefs.getBool('haptics_enabled') ?? true,
        backgroundMusicEnabled: prefs.getBool('background_music') ?? false,
        themeMode: prefs.getInt('theme_mode') ?? 2,
        dataSaverMode: prefs.getBool('data_saver') ?? false,
        autoDownloadMeditations: prefs.getBool('auto_download') ?? false,
        analyticsEnabled: prefs.getBool('analytics_enabled') ?? true,
      );
    } catch (_) {}
  }

  Future<void> update(AppPreferences Function(AppPreferences) updater) async {
    final newState = updater(state);
    state = newState;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', newState.notificationsEnabled);
    await prefs.setBool('sound_enabled', newState.soundEnabled);
    await prefs.setBool('haptics_enabled', newState.hapticsEnabled);
    await prefs.setBool('background_music', newState.backgroundMusicEnabled);
    await prefs.setInt('theme_mode', newState.themeMode);
    await prefs.setBool('data_saver', newState.dataSaverMode);
    await prefs.setBool('auto_download', newState.autoDownloadMeditations);
    await prefs.setBool('analytics_enabled', newState.analyticsEnabled);
  }

  Future<void> toggleNotifications() async => update((p) => p.copyWith(notificationsEnabled: !p.notificationsEnabled));
  Future<void> toggleSound() async => update((p) => p.copyWith(soundEnabled: !p.soundEnabled));
  Future<void> toggleHaptics() async => update((p) => p.copyWith(hapticsEnabled: !p.hapticsEnabled));
  Future<void> toggleBackgroundMusic() async => update((p) => p.copyWith(backgroundMusicEnabled: !p.backgroundMusicEnabled));
  Future<void> setThemeMode(int mode) async => update((p) => p.copyWith(themeMode: mode));
  Future<void> toggleDataSaver() async => update((p) => p.copyWith(dataSaverMode: !p.dataSaverMode));
}

final appPreferencesProvider = StateNotifierProvider<AppPreferencesNotifier, AppPreferences>((ref) {
  return AppPreferencesNotifier();
});
