class AppConstants {
  AppConstants._();
  static const String appName = 'Mental Mantra';
  static const String appTagline = 'Your Personal Wellness Companion';
  static const String packageName = 'com.mentalmantra.mental_mantra';

  static const int splashDurationMs = 2000;
  static const int maxLoginAttempts = 5;
  static const int loginLockoutMinutes = 15;
  static const int otpResendCooldown = 30;
  static const int autoSaveIntervalMs = 30000;
  static const int debounceDelayMs = 300;
  static const int maxRetries = 3;
  static const int retryBaseDelayMs = 2000;
  static const int cacheDurationHours = 24;
  static const int dailyPlanGenerationHour = 6;
  static const int maxJournalEntriesPerPage = 20;
  static const int maxFirestoreLimit = 50;
  static const int meditationCategoriesCount = 12;
  static const int musicCategoriesCount = 10;
  static const int minPasswordLength = 6;
  static const double minTextScale = 0.8;
  static const double maxTextScale = 1.3;
}
