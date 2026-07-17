import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/security/security_service.dart';
import '../../../../core/security/biometric_service.dart';

class SettingsState {
  final bool dailyReminders;
  final bool wellnessTips;
  final bool achievementAlerts;
  final bool biometricLogin;
  final bool aiInsights;
  final bool screenshotProtection;

  const SettingsState({
    this.dailyReminders = true,
    this.wellnessTips = true,
    this.achievementAlerts = true,
    this.biometricLogin = false,
    this.aiInsights = true,
    this.screenshotProtection = false,
  });

  SettingsState copyWith({
    bool? dailyReminders,
    bool? wellnessTips,
    bool? achievementAlerts,
    bool? biometricLogin,
    bool? aiInsights,
    bool? screenshotProtection,
  }) {
    return SettingsState(
      dailyReminders: dailyReminders ?? this.dailyReminders,
      wellnessTips: wellnessTips ?? this.wellnessTips,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      biometricLogin: biometricLogin ?? this.biometricLogin,
      aiInsights: aiInsights ?? this.aiInsights,
      screenshotProtection: screenshotProtection ?? this.screenshotProtection,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dailyReminders =
        HiveStorage.getSetting('dailyReminders', defaultValue: true) as bool;
    final wellnessTips =
        HiveStorage.getSetting('wellnessTips', defaultValue: true) as bool;
    final achievementAlerts =
        HiveStorage.getSetting('achievementAlerts', defaultValue: true) as bool;
    final biometricLogin = await SecureStorage.isBiometricEnabled();
    final aiInsights =
        HiveStorage.getSetting('aiInsights', defaultValue: true) as bool;
    final screenshotProtection =
        HiveStorage.getSetting('screenshotProtection', defaultValue: false)
            as bool;

    if (screenshotProtection) {
      SecurityService.instance.enableScreenshotProtection();
    }

    state = SettingsState(
      dailyReminders: dailyReminders,
      wellnessTips: wellnessTips,
      achievementAlerts: achievementAlerts,
      biometricLogin: biometricLogin,
      aiInsights: aiInsights,
      screenshotProtection: screenshotProtection,
    );
  }

  Future<void> toggleDailyReminders() async {
    final newValue = !state.dailyReminders;
    state = state.copyWith(dailyReminders: newValue);
    await HiveStorage.saveSetting('dailyReminders', newValue);
  }

  Future<void> toggleWellnessTips() async {
    final newValue = !state.wellnessTips;
    state = state.copyWith(wellnessTips: newValue);
    await HiveStorage.saveSetting('wellnessTips', newValue);
  }

  Future<void> toggleAchievementAlerts() async {
    final newValue = !state.achievementAlerts;
    state = state.copyWith(achievementAlerts: newValue);
    await HiveStorage.saveSetting('achievementAlerts', newValue);
  }

  Future<bool> toggleBiometricLogin() async {
    final newValue = !state.biometricLogin;
    if (newValue) {
      final isAvailable =
          await BiometricService.instance.isBiometricAvailable();
      if (!isAvailable) return false;
      final authenticated = await BiometricService.instance.authenticate(
        localizedReason: 'Authenticate to enable Biometric Security',
      );
      if (!authenticated) return false;
    }
    state = state.copyWith(biometricLogin: newValue);
    await SecureStorage.setBiometricEnabled(newValue);
    await HiveStorage.saveSetting('biometricLogin', newValue);
    return true;
  }

  Future<void> toggleScreenshotProtection() async {
    final newValue = !state.screenshotProtection;
    state = state.copyWith(screenshotProtection: newValue);
    await HiveStorage.saveSetting('screenshotProtection', newValue);
    if (newValue) {
      await SecurityService.instance.enableScreenshotProtection();
    } else {
      await SecurityService.instance.disableScreenshotProtection();
    }
  }

  Future<void> toggleAiInsights() async {
    final newValue = !state.aiInsights;
    state = state.copyWith(aiInsights: newValue);
    await HiveStorage.saveSetting('aiInsights', newValue);
  }
}

final appSettingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
