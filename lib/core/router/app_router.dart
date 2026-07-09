import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/fitness/presentation/pages/fitness_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/main_shell.dart';
import '../../features/journal/presentation/pages/journal_list_page.dart';
import '../../features/journal/presentation/pages/journal_entry_page.dart';
import '../../features/journal/presentation/pages/journal_detail_page.dart';
import '../../features/mood/presentation/pages/mood_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/habits/presentation/pages/habits_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/sync_dashboard_page.dart';
import '../../features/emergency/presentation/pages/emergency_page.dart';
import '../../features/meditation/presentation/pages/meditation_page.dart';
import '../../features/meditation/presentation/pages/meditation_player_page.dart';
import '../../features/meditation/presentation/pages/meditation_timer_page.dart';
import '../../features/meditation/presentation/pages/breathing_exercises_page.dart';
import '../../features/music/presentation/pages/music_page.dart';
import '../../features/music/presentation/pages/music_player_page.dart';
import '../../features/music/presentation/pages/full_screen_player.dart';
import '../../features/yoga/presentation/pages/yoga_list_page.dart';
import '../../features/yoga/presentation/pages/yoga_session_page.dart';
import '../../features/achievements/presentation/pages/achievements_page.dart';
import '../../features/sleep/presentation/pages/sleep_page.dart';
import '../../features/ai/presentation/pages/ai_chat_page.dart';
import '../../features/video/presentation/pages/meditation_videos_page.dart';
import '../../features/video/presentation/pages/help_video_page.dart';
import '../../features/wellness/presentation/pages/wellness_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/content_management_page.dart';
import '../../features/admin/presentation/pages/user_management_page.dart';
import '../../features/admin/presentation/pages/analytics_page.dart';
import '../../features/admin/presentation/providers/admin_provider.dart';
import '../../features/dashboard/presentation/pages/landing_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/analytics/presentation/pages/analytics_dashboard_page.dart';
import '../../features/tasks/presentation/pages/daily_tasks_page.dart';
import '../../features/recovery/presentation/pages/recovery_page.dart';
import '../../features/recovery/presentation/pages/urge_logger_page.dart';
import '../../features/recovery/presentation/pages/detox_timer_page.dart';
import '../../features/recovery/presentation/pages/recovery_goals_page.dart';
import '../../features/spiritual/presentation/pages/spiritual_page.dart';
import '../../features/nutrition/presentation/pages/nutrition_page.dart';
import '../../features/games/presentation/pages/brain_games_page.dart';
import '../../features/therapy/presentation/pages/therapy_tools_hub.dart';
import '../../features/therapy/presentation/pages/venting_space_page.dart';
import '../../features/content/presentation/pages/content_feed_page.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const onboarding = '/onboarding';
  static const shell = '/home';
  static const dashboard = '/home/dashboard';
  static const journal = '/home/journal';
  static const journalNew = '/home/journal/new';
  static const journalDetail = '/home/journal/:id';
  static const mood = '/home/mood';
  static const goals = '/home/goals';
  static const habits = '/home/habits';
  static const profile = '/home/profile';
  static const settings = '/home/settings';
  static const syncDashboard = '/home/settings/sync';
  static const emergency = '/emergency';
  static const meditation = '/home/meditation';
  static const meditationPlayer = '/home/meditation/player';
  static const meditationTimer = '/home/meditation/timer';
  static const breathing = '/home/meditation/breathing';
  static const music = '/home/music';
  static const musicPlayer = '/home/music/player';
  static const musicFullPlayer = '/home/music/full-player';
  static const yoga = '/home/yoga';
  static const yogaSession = '/home/yoga/:id';
  static const achievements = '/home/achievements';
  static const sleep = '/home/sleep';
  static const fitness = '/home/fitness';
  static const aiChat = '/home/ai-chat';
  static const videos = '/home/videos';
  static const wellnessDashboard = '/wellness-dashboard';
  static const landing = '/landing';
  static const admin = '/admin';
  static const adminContent = '/admin/content';
  static const adminUsers = '/admin/users';
  static const adminAnalytics = '/admin/analytics';
  static const recovery = '/home/recovery';
  static const urgeLog = '/home/recovery/urge-log';
  static const detoxTimer = '/home/recovery/detox-timer';
  static const recoveryGoals = '/home/recovery/goals';
  static const spiritual = '/home/spiritual';
  static const nutrition = '/home/nutrition';
  static const games = '/home/games';
  static const therapyHub = '/home/therapy';
  static const ventingSpace = '/home/therapy/venting-space';
  static const helpVideos = '/home/help-videos';
  static const discover = '/home/discover';
  static const analytics = '/home/analytics';
  static const dailyTasks = '/home/daily-tasks';
  static const checkin = '/home/checkin';
}

Page<void> _buildPageWithTransition(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
        child: child,
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.user != null;
      final isOnboarded = authState.isOnboarded;

      final isSplash = state.matchedLocation == AppRoutes.splash;
      if (isSplash || authState.isLoading) return null;

      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.otp;

      final isPublicRoute = state.matchedLocation == AppRoutes.landing ||
          state.matchedLocation == AppRoutes.wellnessDashboard;

      final isOnboardingRoute = state.matchedLocation == AppRoutes.onboarding;
      final isEmergency = state.matchedLocation == AppRoutes.emergency;
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isAdmin = ref.read(isAdminProvider);

      if (isEmergency) return null;
      if (isAdminRoute && !isLoggedIn) return AppRoutes.login;
      if (isAdminRoute && isLoggedIn && !isAdmin) return AppRoutes.dashboard;

      if (isPublicRoute) return null;

      if (!isLoggedIn && !isAuthRoute && !isSplash) {
        final target = state.uri.toString();
        if (target.isNotEmpty && target != '/' && target != AppRoutes.landing) {
          return '${AppRoutes.login}?redirect=${Uri.encodeComponent(target)}';
        }
        return AppRoutes.landing;
      }

      if (isLoggedIn && isAuthRoute) {
        return isOnboarded ? AppRoutes.dashboard : AppRoutes.onboarding;
      }

      if (isLoggedIn && !isOnboarded && !isOnboardingRoute) {
        return AppRoutes.onboarding;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _buildPageWithTransition(context, state, const SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.landing,
        pageBuilder: (context, state) => _buildPageWithTransition(context, state, const LandingPage()),
      ),
      GoRoute(
        path: AppRoutes.wellnessDashboard,
        pageBuilder: (context, state) => _buildPageWithTransition(context, state, const WellnessDashboardPage()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return _buildPageWithTransition(context, state, LoginPage(returnRoute: redirect));
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => _buildPageWithTransition(context, state, const SignupPage()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => _buildPageWithTransition(context, state, const ForgotPasswordPage()),
      ),
      GoRoute(
        path: AppRoutes.otp,
        pageBuilder: (context, state) {
          final email = state.extra as String? ?? '';
          return _buildPageWithTransition(context, state, OtpPage(email: email));
        },
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _buildPageWithTransition(context, state, const OnboardingPage()),
      ),
      GoRoute(
        path: AppRoutes.emergency,
        pageBuilder: (context, state) => _buildPageWithTransition(context, state, const EmergencyPage()),
      ),
      GoRoute(
        path: AppRoutes.admin,
        pageBuilder: (context, state) => _buildPageWithTransition(context, state, const AdminDashboardPage()),
        routes: [
          GoRoute(path: 'content', pageBuilder: (context, state) => _buildPageWithTransition(context, state, const ContentManagementPage())),
          GoRoute(path: 'users', pageBuilder: (context, state) => _buildPageWithTransition(context, state, const UserManagementPage())),
          GoRoute(path: 'analytics', pageBuilder: (context, state) => _buildPageWithTransition(context, state, const AnalyticsPage())),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const DashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.journal,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const JournalListPage()),
          ),
          GoRoute(
            path: 'journal/new',
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const JournalEntryPage()),
          ),
          GoRoute(
            path: 'journal/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return _buildPageWithTransition(context, state, JournalDetailPage(entryId: id));
            },
          ),
          GoRoute(
            path: AppRoutes.mood,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const MoodPage()),
          ),
          GoRoute(
            path: AppRoutes.goals,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const GoalsPage()),
          ),
          GoRoute(
            path: AppRoutes.habits,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const HabitsPage()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const ProfilePage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const SettingsPage()),
            routes: [
              GoRoute(
                path: 'sync',
                pageBuilder: (context, state) => _buildPageWithTransition(context, state, const SyncDashboardPage()),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.meditation,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const MeditationPage()),
            routes: [
              GoRoute(
                path: 'player',
                pageBuilder: (context, state) {
                  final args = state.extra as Map<String, dynamic>?;
                  return _buildPageWithTransition(context, state, MeditationPlayerPage(args: args ?? {}));
                },
              ),
              GoRoute(
                path: 'timer',
                pageBuilder: (context, state) => _buildPageWithTransition(context, state, const MeditationTimerPage()),
              ),
              GoRoute(
                path: 'breathing',
                pageBuilder: (context, state) => _buildPageWithTransition(context, state, const BreathingExercisesPage()),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.music,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const MusicPage()),
            routes: [
              GoRoute(
                path: 'player',
                pageBuilder: (context, state) => _buildPageWithTransition(context, state, const MusicPlayerPage(args: {})),
              ),
              GoRoute(
                path: 'full-player',
                pageBuilder: (context, state) => _buildPageWithTransition(context, state, const FullScreenPlayer()),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.yoga,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const YogaListPage()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return _buildPageWithTransition(context, state, YogaSessionPage(sessionId: id));
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.achievements,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const AchievementsPage()),
          ),
          GoRoute(
            path: AppRoutes.sleep,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const SleepPage()),
          ),
          GoRoute(
            path: AppRoutes.fitness,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const FitnessPage()),
          ),
          GoRoute(
            path: AppRoutes.aiChat,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const AiChatPage()),
          ),
          GoRoute(
            path: AppRoutes.videos,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const MeditationVideosPage()),
          ),
          GoRoute(
            path: AppRoutes.recovery,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const RecoveryPage()),
          ),
          GoRoute(
            path: AppRoutes.urgeLog,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const UrgeLoggerPage()),
          ),
          GoRoute(
            path: AppRoutes.detoxTimer,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const DetoxTimerPage()),
          ),
          GoRoute(
            path: AppRoutes.recoveryGoals,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const RecoveryGoalsPage()),
          ),
          GoRoute(
            path: AppRoutes.helpVideos,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const HelpVideoPage()),
          ),
          GoRoute(
            path: AppRoutes.discover,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const ContentFeedPage()),
          ),
          GoRoute(
            path: AppRoutes.spiritual,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const SpiritualPage()),
          ),
          GoRoute(
            path: AppRoutes.nutrition,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const NutritionPage()),
          ),
          GoRoute(
            path: AppRoutes.games,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const BrainGamesPage()),
          ),
          GoRoute(
            path: AppRoutes.therapyHub,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const TherapyToolsHub()),
          ),
          GoRoute(
            path: AppRoutes.ventingSpace,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const VentingSpacePage()),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const AnalyticsDashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.dailyTasks,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const DailyTasksPage()),
          ),
          GoRoute(
            path: AppRoutes.checkin,
            pageBuilder: (context, state) => _buildPageWithTransition(context, state, const OnboardingPage(isRecheckin: true)),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${state.uri}', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.dashboard),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
