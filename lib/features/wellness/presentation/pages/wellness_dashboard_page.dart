import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../services/wellness/providers/wellness_provider.dart';

class WellnessDashboardPage extends ConsumerStatefulWidget {
  const WellnessDashboardPage({super.key});

  @override
  ConsumerState<WellnessDashboardPage> createState() => _WellnessDashboardPageState();
}

class _WellnessDashboardPageState extends ConsumerState<WellnessDashboardPage> {
  bool _loadAttempted = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.user != null;
    final wellnessState = ref.watch(wellnessPlanProvider);
    final plan = wellnessState.plan;
    final score = plan?.wellnessScore.overall ?? (isLoggedIn ? 84 : 76);

    if (isLoggedIn && !_loadAttempted && plan == null && !wellnessState.isLoading) {
      _loadAttempted = true;
      final uid = authState.user!.uid;
      ref.read(wellnessPlanLoaderProvider(uid));
    }

    final emotionalSummary = plan?.briefing.summary ??
        (isLoggedIn
            ? 'Your mood logs show positive patterns after your daily meditation sessions. Keep up the morning routine!'
            : 'You seem to benefit most from slower mornings, shorter resets, and evening wind-down support.');

    final nextStep = plan?.focus.description ??
        (isLoggedIn
            ? 'Schedule a 10-minute deep breathing session this afternoon and log your gratitude journal entry tonight.'
            : 'Try one breath session, one short journal reflection, and an earlier screen cutoff tonight.');

    final scoreLabel = plan?.briefing.greeting ??
        (isLoggedIn
            ? '$score / 100 \u2022 feeling strong and balanced'
            : '$score / 100 \u2022 steady but room to recover');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
          onPressed: () => context.go(AppRoutes.landing),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.nightGradient,
        ),
        child: wellnessState.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Wellness Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            isLoggedIn: isLoggedIn,
                            icon: Icons.assignment_turned_in_outlined,
                            title: 'Start onboarding',
                            subtitle: 'Answer 10 adaptive questions to shape your wellness plan.',
                            route: AppRoutes.onboarding,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            isLoggedIn: isLoggedIn,
                            icon: Icons.person_outline,
                            title: 'Open profile',
                            subtitle: 'Review your preferences, routines, and personal details.',
                            route: AppRoutes.profile,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            isLoggedIn: isLoggedIn,
                            icon: Icons.settings_outlined,
                            title: 'Adjust settings',
                            subtitle: 'Manage reminders, privacy expectations, and app preferences.',
                            route: AppRoutes.settings,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status Panels
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Score and Status
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.primaryColor, width: 4),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$score',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Wellness Score',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      scoreLabel,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, color: Colors.white10),

                          // Today's Emotional Summary
                          const Text(
                            "Today's Emotional Summary",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            emotionalSummary,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Recommended Next Step
                          const Text(
                            "Recommended Next Step",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            nextStep,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Explore Support Tools Grid
                    const Text(
                      'Explore Support Tools',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildToolCard(context, isLoggedIn: isLoggedIn, icon: Icons.mood, title: 'Mood tracker', description: 'Log how you feel and review patterns over time.', route: AppRoutes.mood, color: AppTheme.warningColor),
                        _buildToolCard(context, isLoggedIn: isLoggedIn, icon: Icons.book, title: 'Journal', description: 'Capture thoughts, gratitude, and grounded next steps.', route: AppRoutes.journal, color: AppTheme.accentColor),
                        _buildToolCard(context, isLoggedIn: isLoggedIn, icon: Icons.self_improvement, title: 'Meditation', description: 'Guided sessions for stress, sleep, and focus.', route: AppRoutes.meditation, color: AppTheme.secondaryColor),
                        _buildToolCard(context, isLoggedIn: isLoggedIn, icon: Icons.music_note, title: 'Music therapy', description: 'Play calming soundscapes for rest or focus.', route: AppRoutes.music, color: AppTheme.primaryColor),
                        _buildToolCard(context, isLoggedIn: isLoggedIn, icon: Icons.check_circle_outline, title: 'Habit tracker', description: 'Stay consistent with daily healthy habits.', route: AppRoutes.habits, color: AppTheme.successColor),
                        _buildToolCard(context, isLoggedIn: isLoggedIn, icon: Icons.track_changes, title: 'Goals', description: 'Measure daily and weekly wellness goals.', route: AppRoutes.goals, color: Colors.orangeAccent),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  void _navigateToGated(BuildContext context, bool isLoggedIn, String route) {
    if (isLoggedIn) {
      context.go(route);
    } else {
      context.go('${AppRoutes.login}?redirect=${Uri.encodeComponent(route)}');
    }
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required bool isLoggedIn,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return InkWell(
      onTap: () => _navigateToGated(context, isLoggedIn, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Expanded(child: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4), height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required bool isLoggedIn,
    required IconData icon,
    required String title,
    required String description,
    required String route,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _navigateToGated(context, isLoggedIn, route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.2), size: 14),
            ]),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Expanded(child: Text(description, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5), height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
