import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/router/app_router.dart';

void main() {
  test('AppRouter matches all AppRoutes paths successfully', () {
    final container = ProviderContainer();
    final router = container.read(routerProvider);

    final paths = [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.forgotPassword,
      AppRoutes.otp,
      AppRoutes.onboarding,
      AppRoutes.dashboard,
      AppRoutes.journal,
      AppRoutes.journalNew,
      AppRoutes.journalDetail,
      AppRoutes.mood,
      AppRoutes.goals,
      AppRoutes.habits,
      AppRoutes.profile,
      AppRoutes.settings,
      AppRoutes.syncDashboard,
      AppRoutes.emergency,
      AppRoutes.meditation,
      AppRoutes.meditationPlayer,
      AppRoutes.meditationTimer,
      AppRoutes.breathing,
      AppRoutes.music,
      AppRoutes.musicPlayer,
      AppRoutes.musicFullPlayer,
      AppRoutes.yoga,
      AppRoutes.achievements,
      AppRoutes.sleep,
      AppRoutes.fitness,
      AppRoutes.aiChat,
      AppRoutes.videos,
      AppRoutes.recovery,
      AppRoutes.urgeLog,
      AppRoutes.detoxTimer,
      AppRoutes.recoveryGoals,
      AppRoutes.helpVideos,
      AppRoutes.discover,
      AppRoutes.spiritual,
      AppRoutes.nutrition,
      AppRoutes.games,
      AppRoutes.therapyHub,
      AppRoutes.ventingSpace,
      AppRoutes.analytics,
      AppRoutes.dailyTasks,
      AppRoutes.checkin,
      AppRoutes.moodTimeline,
      AppRoutes.moodReport,
      AppRoutes.unifiedRecovery,
      AppRoutes.cravingSos,
      AppRoutes.safetyPlan,
    ];

    for (final path in paths) {
      // Replace dynamic parameters (e.g. :id) with mock values for matching
      final normalizedPath = path.replaceAll(':id', 'mock-id-123');
      
      final matches = router.configuration.findMatch(Uri.parse(normalizedPath));
      expect(
        matches.matches,
        isNotEmpty,
        reason: 'Path $path was not matched by GoRouter configuration (returned 404)',
      );
    }
  });
}
