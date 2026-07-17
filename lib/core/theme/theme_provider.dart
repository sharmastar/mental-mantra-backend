// lib/core/theme/app_theme.dart - theme mode provider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/config/app_config.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = AppConfig.prefs.getBool('isDarkMode') ?? true;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    await AppConfig.prefs.setBool('isDarkMode', !isDark);
  }

  Future<void> setDark() async {
    state = ThemeMode.dark;
    await AppConfig.prefs.setBool('isDarkMode', true);
  }

  Future<void> setLight() async {
    state = ThemeMode.light;
    await AppConfig.prefs.setBool('isDarkMode', false);
  }
}
