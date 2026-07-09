import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final soundHapticProvider = StateNotifierProvider<SoundHapticNotifier, bool>(
  (ref) => SoundHapticNotifier(),
);

class SoundHapticNotifier extends StateNotifier<bool> {
  SoundHapticNotifier() : super(true) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('sound_haptics_enabled') ?? true;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final current = state;
    state = !current;
    await prefs.setBool('sound_haptics_enabled', !current);
  }
}
