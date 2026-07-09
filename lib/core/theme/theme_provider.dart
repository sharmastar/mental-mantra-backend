// lib/core/theme/app_theme.dart - theme mode provider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool('isDarkMode', !isDark);
  }

  Future<void> setDark() async {
    final prefs = await SharedPreferences.getInstance();
    state = ThemeMode.dark;
    await prefs.setBool('isDarkMode', true);
  }

  Future<void> setLight() async {
    final prefs = await SharedPreferences.getInstance();
    state = ThemeMode.light;
    await prefs.setBool('isDarkMode', false);
  }
}
