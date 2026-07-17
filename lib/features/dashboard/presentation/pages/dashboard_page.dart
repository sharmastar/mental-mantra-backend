// lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../../core/widgets/debounce_button.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../services/wellness/models/wellness_plan.dart';
import '../../../../services/wellness/models/habit_recommendation.dart';
import '../../../../services/wellness/providers/wellness_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/dashboard_ui_provider.dart';
import '../../../journal/data/models/journal_entry.dart';
import '../../../journal/presentation/providers/journal_provider.dart';
import '../widgets/wellness_score_ring.dart';
import '../widgets/focus_card.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/greeting_header.dart';
import '../widgets/quick_actions.dart';
import '../widgets/sleep_sounds_mixer.dart';
import '../widgets/gamification_hub.dart';
import '../widgets/weekly_trend_chart.dart';
import '../widgets/breathing_overlay.dart';
import '../widgets/daily_routine_cards.dart';
import '../../../wellness/presentation/widgets/wellness_score_card.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final int _activeHabitIndex = 0;

  // Inline Journal Controller & Debounce for Autosave
  final TextEditingController _reflectionController = TextEditingController();
  Timer? _autosaveTimer;
  bool _isAutosaving = false;
  bool _journalSaved = false;

  // Scroll controller to auto-scroll to journey
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      Future.microtask(() {
        ref.read(dashboardProvider.notifier).load(user.uid);
        ref
            .read(wellnessPlanProvider.notifier)
            .load(user.uid, userName: user.nickname ?? user.displayName);
      });
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _reflectionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Time detection for layouts
  bool _isMorningMode(WellnessPlan? plan) {
    if (plan == null) return true;
    return plan.currentPeriod == TimeOfDayPeriod.morning ||
        plan.currentPeriod == TimeOfDayPeriod.afternoon;
  }

  // Trigger celebration confetti
  void _triggerCelebration() {
    final hapticsEnabled = ref.read(soundHapticProvider);
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    ref.read(dashboardUiProvider.notifier).setShowConfetti(true);
  }

  void _onJournalChanged(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _isAutosaving = true;
      _journalSaved = false;
    });

    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 1500), () async {
      final user = ref.read(currentUserProvider);
      final uiState = ref.read(dashboardUiProvider);
      if (user != null && mounted) {
        final entry = JournalEntry(
          title: 'Evening Reflection',
          content: text,
          mood: uiState.eveningMoodDragValue.round() + 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref.read(journalRepositoryProvider).createEntry(entry);
        if (mounted) {
          setState(() {
            _isAutosaving = false;
            _journalSaved = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final planState = ref.watch(wellnessPlanProvider);
    final uiState = ref.watch(dashboardUiProvider);
    final dbState = ref.watch(dashboardProvider);
    final plan = planState.plan;
    final name = user?.nickname?.isNotEmpty == true
        ? user!.nickname!
        : user?.displayName.isNotEmpty == true
            ? user!.displayName.split(' ').first
            : 'Friend';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMorning = _isMorningMode(plan);
    final streakDays = (user != null) ? user.streakDays : 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo.icon(),
            const SizedBox(width: 8),
            Text(
              'Mental Mantra',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: isDark ? const Color(0xFFE2F3F2) : AppTheme.primaryDark,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedScale(
              scale: uiState.isBreathingActive ? 1.15 : 1.0,
              duration: 800.ms,
              curve: Curves.easeInOut,
              child: isMorning
                  ? const SunriseBackground()
                  : const StarryNightBackground(),
            ),
          ),
          // Subtle low-opacity background watermark logo
          Positioned(
            bottom: -50,
            right: -50,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: 15 * 3.141592653589793 / 180,
                child: const AppLogo(
                  width: 320,
                  height: 320,
                  variant: LogoVariant.watermark,
                ),
              ),
            ),
          ),
          // Dark overlay to ensure header text contrast
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: uiState.isBreathingActive ? 0.0 : 1.0,
            duration: 500.ms,
            curve: Curves.easeInOut,
            child: SafeArea(
              bottom: false,
              child: planState.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppLogo.medium(
                            animateBreathing: true,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Preparing your safe space...',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : Colors.black54,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (user != null) {
                          await ref.read(wellnessPlanProvider.notifier).load(
                              user.uid,
                              userName: user.nickname ?? user.displayName);
                        }
                      },
                      color: AppTheme.primaryColor,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: uiState.isBreathingActive
                            ? const NeverScrollableScrollPhysics()
                            : const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 80, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GreetingHeader(
                              plan: plan,
                              name: name,
                              user: user,
                              isMorning: isMorning,
                              onSettingsTap: () =>
                                  context.push(AppRoutes.settings),
                              onProfileTap: () =>
                                  context.push(AppRoutes.profile),
                            ),
                            const SizedBox(height: 16),
                            if (plan != null) ...[
                              if (isMorning) ...[
                                // 1. Mood Check-In ("How am I feeling?")
                                _buildMoodCheckInCard(uiState),
                                const SizedBox(height: 16),
                                
                                // 2. Daily Intention ("What matters today?")
                                FocusCardWellness(
                                  focus: plan.focus,
                                  onStartJourney: () {
                                    _scrollController.animateTo(
                                      _scrollController
                                          .position.maxScrollExtent,
                                      duration: 600.ms,
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // 3. Recovery Progress ("How am I progressing?")
                                _buildSupportiveStreakCard(streakDays),
                                const SizedBox(height: 16),
                                
                                // 4. Reflection Prompt
                                _buildGuidedJourney(plan, user),
                                const SizedBox(height: 16),
                                if (uiState.completedJourneySteps >= 4) ...[
                                  _buildMorningReflectionScene(plan),
                                  const SizedBox(height: 16),
                                ],
                                
                                // 5. Nova Support Card ("Where can I get support?")
                                _buildNovaCheckInCard(context),
                                const SizedBox(height: 24),
                                
                                // 6. Wellness Insights (collapsed by default)
                                _WellnessInsightsCollapsible(
                                  child: Column(
                                    children: [
                                      DailyRoutineCards(
                                        onStartRoutine: () {
                                          context.push(AppRoutes.meditation);
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      const WellnessScoreCard(height: 160),
                                      const SizedBox(height: 20),
                                      WellnessScoreRing(
                                        score: plan.wellnessScore,
                                        onTap: () => _showScoreBreakdownSheet(
                                            plan.wellnessScore),
                                      ),
                                      const SizedBox(height: 20),
                                      WeeklyTrendChart(
                                          moodHistory: dbState.recentMoods),
                                      const SizedBox(height: 20),
                                      const GamificationHub(),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                // Evening Mode Restructuring
                                // 1. Mood Check-In
                                _buildEveningMoodDial(user),
                                const SizedBox(height: 16),

                                // 2. Daily Intention (Tomorrow's Preview)
                                _buildTomorrowPreview(plan),
                                const SizedBox(height: 16),

                                // 3. Recovery Progress
                                _buildSupportiveStreakCard(streakDays),
                                const SizedBox(height: 16),

                                // 4. Reflection Prompt
                                _buildEveningReflection(plan, user),
                                const SizedBox(height: 16),

                                // 5. Nova Support Card
                                _buildNovaCheckInCard(context),
                                const SizedBox(height: 24),

                                // 6. Wellness Insights (collapsed by default)
                                _WellnessInsightsCollapsible(
                                  child: Column(
                                    children: [
                                      const SleepSoundsMixer(),
                                      const SizedBox(height: 20),
                                      const WellnessScoreCard(height: 160),
                                      const SizedBox(height: 20),
                                      WellnessScoreRing(
                                        score: plan.wellnessScore,
                                        onTap: () => _showScoreBreakdownSheet(
                                            plan.wellnessScore),
                                      ),
                                      const SizedBox(height: 20),
                                      WeeklyTrendChart(
                                          moodHistory: dbState.recentMoods),
                                      const SizedBox(height: 20),
                                      const GamificationHub(),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),
                              QuickActions(
                                plan: plan,
                                isMorningMode: isMorning,
                                onJournalTap: () =>
                                    context.push(AppRoutes.journal),
                                onMeditationTap: () =>
                                    context.push(AppRoutes.meditation),
                                onEmergencyTap: () =>
                                    context.push(AppRoutes.emergency),
                              ),
                            ] else ...[
                              _buildFallbackContent(user),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          const Positioned.fill(
            child: BreathingOverlay(),
          ),
          if (uiState.showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiOverlay(
                  show: uiState.showConfetti,
                  onComplete: () {
                    ref
                        .read(dashboardUiProvider.notifier)
                        .setShowConfetti(false);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Detailed breakdown bottom sheet
  void _showScoreBreakdownSheet(WellnessScore score) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Wellness Assessment',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildBreakdownRow('Mood Check-ins', (score.mood * 20).round(),
                  AppTheme.warningColor),
              _buildBreakdownRow(
                  'Sleep Quality', (score.sleep * 10).round(), Colors.blue),
              _buildBreakdownRow('Habits Completion', (score.habits).round(),
                  AppTheme.successColor),
              _buildBreakdownRow('Meditation Practice',
                  (score.meditationConsistency).round(), AppTheme.primaryColor),
              _buildBreakdownRow('Hydration Level', (score.hydration).round(),
                  AppTheme.secondaryColor),
              const SizedBox(height: 24),
              if (score.improvements.isNotEmpty) ...[
                const Text(
                  'Strengths Today',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                ...score.improvements.map((imp) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: AppTheme.successColor, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(imp,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13))),
                        ],
                      ),
                    )),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Back to Journey',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownRow(String title, int pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text('$pct%',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: pct / 100,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCheckInCard(DashboardUiState uiState) {
    final logged = uiState.journeySelectedMood != -1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white : AppTheme.primaryDark;

    return Semantics(
      label: 'Mood check-in card. How is your heart in this moment?',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How is your heart in this moment?',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            if (!logged)
              _buildJourneyMoodSelector()
            else
              Row(
                children: [
                  const Text('😌', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your mood is recorded. May you find peace and balance today. 🌿',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportiveStreakCard(int streak) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white : AppTheme.primaryDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: isDark ? 0.15 : 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department, color: AppTheme.warningColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak > 0 ? '$streak Days of Showing Up' : 'Begin Your Showing Up Journey',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold, 
                    fontSize: 15, 
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streak > 0 
                      ? 'Every step matters. You are nurturing consistency, and progress is not linear.' 
                      : 'Every step matters. Consistency grows one breath at a time.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12, 
                    color: isDark ? Colors.white70 : Colors.black54, 
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNovaCheckInCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white : AppTheme.primaryDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: AppLogo.icon(animateBreathing: true),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nova is here for you',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontWeight: FontWeight.bold, 
                    fontSize: 18, 
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Need to talk, vent, or rest? Nova is here to listen.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13, 
                    color: isDark ? Colors.white70 : Colors.black54, 
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: 'Talk to Nova',
                  child: PremiumBounceInteraction(
                    onTap: () => context.push(AppRoutes.aiChat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.forum_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Talk to Nova',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Scene 4: Guided Journey (Morning) ──────────────────────
  Widget _buildGuidedJourney(WellnessPlan plan, dynamic user) {
    final uiState = ref.watch(dashboardUiProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white : AppTheme.primaryDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guided Path',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete sequentially to anchor your day.',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54),
          ),
          const SizedBox(height: 24),
          _buildJourneyStep(
            stepNum: 1,
            title: '3-Minute Deep Breath',
            desc: 'Box breathing technique to lower pulse.',
            actionLabel: 'Breathe',
            isCompleted: uiState.completedJourneySteps >= 1,
            isActive: uiState.completedJourneySteps == 0,
            onAction: () {
              ref.read(dashboardUiProvider.notifier).setBreathingActive(true);
            },
          ),
          _buildStepDivider(),
          _buildJourneyStep(
            stepNum: 2,
            title: 'Hydration Reset',
            desc: 'Log a glass of water to refresh your body.',
            actionLabel: uiState.waterLogged ? 'Logged ✓' : 'Drink Water',
            isCompleted: uiState.completedJourneySteps >= 2,
            isActive: uiState.completedJourneySteps == 1,
            onAction: uiState.waterLogged ? null : () => _logHydration(user),
          ),
          _buildStepDivider(),
          _buildJourneyStep(
            stepNum: 3,
            title: 'Daily Micro-Habit',
            desc: 'Complete one recommended habit.',
            isCompleted: uiState.completedJourneySteps >= 3,
            isActive: uiState.completedJourneySteps == 2,
            customWidget: uiState.completedJourneySteps == 2
                ? _buildFlippingHabitCard(plan.habits)
                : (uiState.completedJourneySteps > 2
                    ? const Text('Habit completed ✓',
                        style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600))
                    : Text('Locked',
                        style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 12))),
          ),
          _buildStepDivider(),
          _buildJourneyStep(
            stepNum: 4,
            title: 'Check-in Your Mood',
            desc: 'Nova keeps a record of how you feel.',
            isCompleted: uiState.completedJourneySteps >= 4,
            isActive: uiState.completedJourneySteps == 3,
            customWidget: uiState.completedJourneySteps == 3
                ? _buildJourneyMoodSelector()
                : (uiState.completedJourneySteps > 3
                    ? const Text('Mood logged ✓',
                        style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600))
                    : Text('Locked',
                        style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 12))),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 180.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildStepDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 4, bottom: 4),
      child: Container(
        width: 2,
        height: 24,
        color: AppTheme.primaryColor.withValues(alpha: 0.15),
      ),
    );
  }

  Widget _buildJourneyStep({
    required int stepNum,
    required String title,
    required String desc,
    String? actionLabel,
    required bool isCompleted,
    required bool isActive,
    VoidCallback? onAction,
    Widget? customWidget,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = isCompleted
        ? AppTheme.successColor
        : isActive
            ? AppTheme.primaryColor
            : Colors.grey.withValues(alpha: 0.5);

    return Opacity(
      opacity: isActive || isCompleted ? 1.0 : 0.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : isActive
                      ? AppTheme.primaryColor.withValues(alpha: 0.15)
                      : Colors.transparent,
              border: Border.all(
                color: statusColor,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? const Icon(Icons.check,
                    color: AppTheme.successColor, size: 18)
                : Text(
                    '$stepNum',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isCompleted
                        ? (isDark ? Colors.white38 : Colors.black45)
                        : (isDark ? Colors.white : AppTheme.primaryDark),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54),
                ),
                if (isActive && customWidget == null && onAction != null) ...[
                  const SizedBox(height: 10),
                  Semantics(
                    button: true,
                    label: actionLabel ?? 'Start',
                    child: PremiumBounceInteraction(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        actionLabel ?? 'Start',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
                if (customWidget != null) ...[
                  const SizedBox(height: 10),
                  customWidget,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logHydration(dynamic user) async {
    ref.read(dashboardUiProvider.notifier).setWaterLogged(true);
    await Future.delayed(const Duration(milliseconds: 600));
    ref.read(dashboardUiProvider.notifier).setCompletedJourneySteps(2);
    _triggerCelebration();
  }

  Widget _buildFlippingHabitCard(List<HabitRecommendation> habits) {
    if (habits.isEmpty) return const SizedBox();
    final uiState = ref.watch(dashboardUiProvider);
    final habit = habits[min(_activeHabitIndex, habits.length - 1)];

    return PremiumBounceInteraction(
      onTap: () {
        ref.read(dashboardUiProvider.notifier).setHabitFlipped(true);
        _triggerCelebration();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            ref.read(dashboardUiProvider.notifier).setCompletedJourneySteps(3);
          }
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final isBack = child!.key == const ValueKey('flipped');
              var tilt = rotate.value;
              if (isBack) tilt = tilt - pi;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(tilt),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: !uiState.habitFlipped
            ? Container(
                key: const ValueKey('unflipped'),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_border, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(habit.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppTheme.primaryDark)),
                          const SizedBox(height: 2),
                          Text('Duration: ${habit.durationMinutes} mins',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_outline,
                        color: AppTheme.primaryColor),
                  ],
                ),
              )
            : Container(
                key: const ValueKey('flipped'),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.successColor.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🌿 Wonderful.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'You\'ve taken a small step today, and those often become the biggest changes over time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.primaryDark),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildJourneyMoodSelector() {
    final uiState = ref.watch(dashboardUiProvider);
    final emojis = ['😢', '😞', '😐', '🙂', '😄'];
    return Semantics(
      label: 'Select your current mood',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(emojis.length, (index) {
          final isSelected = uiState.journeySelectedMood == index;
          return DebounceButton(
            onTap: () async {
              final hapticsEnabled = ref.read(soundHapticProvider);
              if (hapticsEnabled) {
                HapticFeedback.mediumImpact();
              }
              ref
                  .read(dashboardUiProvider.notifier)
                  .setJourneySelectedMood(index);
              await ref.read(dashboardProvider.notifier).setTodayMood(index + 1);
              await Future.delayed(const Duration(milliseconds: 600));
              ref.read(dashboardUiProvider.notifier).setCompletedJourneySteps(4);
              _triggerCelebration();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentColor.withValues(alpha: 0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppTheme.accentColor, width: 1.5)
                    : null,
              ),
              child: Text(
                emojis[index],
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Scene 5: Morning Reflection (Post-Journey) ────────────────────
  Widget _buildMorningReflectionScene(WellnessPlan plan) {
    // Extract first AI insight if present
    final insight = plan.insights.isNotEmpty ? plan.insights.first : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white : AppTheme.primaryDark;
    final bodyColor = isDark ? Colors.white70 : Colors.black87;
    final evidenceColor = isDark ? Colors.white54 : Colors.black54;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? borderColor
                : AppTheme.successColor.withValues(alpha: 0.2),
            width: 1.0),
        boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌿 Reflection',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Nova: \"You have dedicated meaningful time to your wellbeing today. Nova welcomes your presence.\"",
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: bodyColor,
              height: 1.4,
            ),
          ),
          if (insight != null) ...[
            const SizedBox(height: 16),
            Divider(color: isDark ? AppTheme.darkBorder : Colors.black12),
            const SizedBox(height: 8),
            Text(
              'Observation: ${insight.message}',
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.primaryLight : AppTheme.primaryDark),
            ),
            if (insight.evidence.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Evidence: ${insight.evidence.map((e) => e.description).join(', ')}',
                style: TextStyle(
                    fontFamily: 'Outfit', fontSize: 11, color: evidenceColor),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Suggested Action: ${insight.title}',
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color:
                      isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
                  fontWeight: FontWeight.w600),
            ),
            if (insight.recommendation != null) ...[
              const SizedBox(height: 4),
              Text(
                'Expected Benefit: ${insight.recommendation!.detail}',
                style: TextStyle(
                    fontFamily: 'Outfit', fontSize: 11, color: evidenceColor),
              ),
            ],
          ],
        ],
      ),
    ).animate().scaleXY(begin: 0.95, end: 1.0, curve: Curves.elasticOut);
  }

  Widget _buildEveningMoodDial(dynamic user) {
    final uiState = ref.watch(dashboardUiProvider);
    final moods = [
      {'emoji': '😢', 'label': 'Struggling', 'color': AppTheme.errorColor},
      {'emoji': '😞', 'label': 'Heavy', 'color': Colors.orangeAccent},
      {'emoji': '😐', 'label': 'Quiet', 'color': AppTheme.warningColor},
      {'emoji': '🙂', 'label': 'Calm', 'color': AppTheme.primaryColor},
      {'emoji': '😄', 'label': 'Light', 'color': AppTheme.successColor},
    ];

    final selectedIndex = uiState.eveningMoodDragValue.round().clamp(0, 4);
    final activeMood = moods[selectedIndex];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white : AppTheme.primaryDark;

    return Semantics(
      label: 'Evening mood selector. Current mood: ${activeMood['label']}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
        ),
        child: Column(
          children: [
            Text(
              'How is your heart tonight?',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 90,
              height: 90,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (activeMood['color'] as Color).withValues(alpha: 0.2),
                boxShadow: [
                  BoxShadow(
                    color: (activeMood['color'] as Color).withValues(alpha: 0.3),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: Text(
                activeMood['emoji'] as String,
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              activeMood['label'] as String,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: activeMood['color'] as Color,
              ),
            ),
            const SizedBox(height: 20),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                activeTrackColor: activeMood['color'] as Color,
                inactiveTrackColor: Colors.white10,
                thumbColor: activeMood['color'] as Color,
                overlayColor:
                    (activeMood['color'] as Color).withValues(alpha: 0.15),
                valueIndicatorColor: activeMood['color'] as Color,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              ),
              child: Semantics(
                label: 'Mood intensity slider',
                value: activeMood['label'] as String,
                child: Slider(
                  value: uiState.eveningMoodDragValue,
                  min: 0,
                  max: 4,
                  divisions: 4,
                  onChanged: (val) {
                    ref
                        .read(dashboardUiProvider.notifier)
                        .setEveningMoodDragValue(val);
                    final hapticsEnabled = ref.read(soundHapticProvider);
                    if (hapticsEnabled) {
                      HapticFeedback.selectionClick();
                    }
                  },
                  onChangeEnd: (val) async {
                    final hapticsEnabled = ref.read(soundHapticProvider);
                    if (hapticsEnabled) {
                      HapticFeedback.mediumImpact();
                    }
                    await ref
                        .read(dashboardProvider.notifier)
                        .setTodayMood(val.round() + 1);
                    ref
                        .read(dashboardUiProvider.notifier)
                        .setEveningMoodSaved(true);
                    _triggerCelebration();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              uiState.eveningMoodSaved
                  ? 'Changes saved automatically ✓'
                  : 'Drag to adjust · Saves automatically on release',
              style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  // ── Scene 3 (Evening): Inline Journal Reflection (Autosaves) ──────
  Widget _buildEveningReflection(WellnessPlan plan, dynamic user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white : AppTheme.primaryDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evening Reflection',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prompt: "${plan.journalPrompt.prompt}"',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.secondaryColor,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Direct Text Field Composer (Autosaves)
          TextField(
            controller: _reflectionController,
            maxLines: 4,
            onChanged: _onJournalChanged,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Type your reflection freely here...',
              fillColor: Colors.black12,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Status indicator for autosave
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isAutosaving) ...[
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: Colors.white54),
                ),
                const SizedBox(width: 8),
                const Text('Saving draft...',
                    style: TextStyle(color: Colors.white30, fontSize: 11)),
              ] else if (_journalSaved) ...[
                const Icon(Icons.check, color: AppTheme.successColor, size: 14),
                const SizedBox(width: 6),
                const Text('Autosaved',
                    style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0);
  }

  // ── Scene 5 (Evening): Tomorrow Preview ────────────────────────────
  Widget _buildTomorrowPreview(WellnessPlan plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tomorrow\'s Outlook',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentColor,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tomorrow we\'ll focus on reducing your afternoon stress and supporting your recovery.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sleep well. 🌙',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 240.ms)
        .slideY(begin: 0.1, end: 0);
  }

  // ── Fallback when wellness plan is null ──────────────────────────
  Widget _buildFallbackContent(dynamic user) {
    final error = ref.read(wellnessPlanProvider).error;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                error ?? 'Unable to load your wellness plan',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to retry, or check your connection',
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Semantics(
              button: true,
              label: 'Retry loading wellness plan',
              child: PremiumBounceInteraction(
              onTap: () async {
                if (user != null) {
                  ref
                      .read(dashboardUiProvider.notifier)
                      .setShowConfetti(false); // Optional reset
                  await ref.read(wellnessPlanProvider.notifier).load(
                        user.uid,
                        userName: user.nickname ?? user.displayName,
                      );
                }
              },
              child: SizedBox(
                width: 120,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    ),
                    boxShadow:
                        isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.refresh_rounded,
                          color: AppTheme.primaryColor, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        'Retry',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Background backdrop widgets ────────────────────────────────────
class SunriseBackground extends StatelessWidget {
  const SunriseBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.7),
            AppTheme.lightCard.withValues(alpha: 0.8),
            AppTheme.lightBorder.withValues(alpha: 0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class StarryNightBackground extends StatefulWidget {
  const StarryNightBackground({super.key});

  @override
  State<StarryNightBackground> createState() => _StarryNightBackgroundState();
}

class _StarryNightBackgroundState extends State<StarryNightBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarrySkyPainter(twinkle: _controller.value),
        );
      },
    );
  }
}

class StarrySkyPainter extends CustomPainter {
  final double twinkle;
  StarrySkyPainter({required this.twinkle});

  @override
  void paint(Canvas canvas, Size size) {
    // Deep Space Purple gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppTheme.darkBg,
          AppTheme.darkSurface,
          AppTheme.darkCard,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, bgPaint);

    final rnd = Random(42); // Seed to keep stars consistent
    final starPaint = Paint()..color = Colors.white;

    for (var i = 0; i < 45; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.7; // Top 70% of screen
      final sizeStar = rnd.nextDouble() * 1.8 + 0.4;
      final alpha = (rnd.nextDouble() * 0.4 + 0.1) + (twinkle * 0.5);

      starPaint.color = Colors.white.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), sizeStar, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant StarrySkyPainter oldDelegate) =>
      oldDelegate.twinkle != twinkle;
}

// ── Ring Painter ───────────────────────────────────────────────────
class ScoreRingPainter extends CustomPainter {
  final double score;
  final Color color;

  ScoreRingPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.4), color],
        stops: const [0.0, 1.0],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = (score / 100.0) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ScoreRingPainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}

class _WellnessInsightsCollapsible extends StatefulWidget {
  final Widget child;
  const _WellnessInsightsCollapsible({required this.child});

  @override
  State<_WellnessInsightsCollapsible> createState() => _WellnessInsightsCollapsibleState();
}

class _WellnessInsightsCollapsibleState extends State<_WellnessInsightsCollapsible> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white70 : AppTheme.primaryDark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'Wellness Insights',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          leading: const Icon(Icons.insights_rounded, color: AppTheme.primaryColor),
          trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            color: AppTheme.primaryColor,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            widget.child,
          ],
        ),
      ),
    );
  }
}

