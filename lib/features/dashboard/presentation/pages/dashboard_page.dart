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
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../../core/widgets/debounce_button.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../../../services/wellness/models/wellness_plan.dart';
import '../../../../services/wellness/models/habit_recommendation.dart';
import '../../../../services/wellness/providers/wellness_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/dashboard_ui_provider.dart';
import '../../../journal/data/models/journal_entry.dart';
import '../../../journal/presentation/providers/journal_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> with TickerProviderStateMixin {
  final int _activeHabitIndex = 0;

  // Breathing Overlay states (managed locally for animation controllers)
  Timer? _breathingTimer;
  late AnimationController _breathingOrbController;
  late Animation<double> _breathingScaleAnimation;

  // Confetti Particle states
  List<Particle> _particles = [];
  Timer? _confettiTimer;

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
        ref.read(wellnessPlanProvider.notifier).load(user.uid, userName: user.nickname ?? user.displayName);
      });
    }

    _breathingOrbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breathingScaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathingOrbController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _breathingTimer?.cancel();
    _confettiTimer?.cancel();
    _autosaveTimer?.cancel();
    _breathingOrbController.dispose();
    _reflectionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Time detection for layouts
  bool _isMorningMode(WellnessPlan? plan) {
    if (plan == null) return true;
    return plan.currentPeriod == TimeOfDayPeriod.morning || plan.currentPeriod == TimeOfDayPeriod.afternoon;
  }

  // Trigger celebration confetti
  void _triggerCelebration() {
    final hapticsEnabled = ref.read(soundHapticProvider);
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    ref.read(dashboardUiProvider.notifier).setShowConfetti(true);
    _particles = List.generate(80, (index) => Particle());
    _confettiTimer?.cancel();
    _confettiTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        ref.read(dashboardUiProvider.notifier).setShowConfetti(false);
      }
    });
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
    final tasksState = ref.watch(tasksProvider);
    final dbState = ref.watch(dashboardProvider);
    final plan = planState.plan;
    final name = user?.nickname?.isNotEmpty == true
        ? user!.nickname!
        : user?.displayName.isNotEmpty == true ? user!.displayName.split(' ').first : 'Friend';

    final isMorning = _isMorningMode(plan);

    return Scaffold(
      backgroundColor: Colors.transparent,
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

          AnimatedOpacity(
            opacity: uiState.isBreathingActive ? 0.0 : 1.0,
            duration: 500.ms,
            curve: Curves.easeInOut,
            child: SafeArea(
              bottom: false,
              child: planState.isLoading
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      children: List.generate(5, (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: SkeletonCardLoader(),
                      )),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (user != null) {
                          await ref.read(wellnessPlanProvider.notifier).load(user.uid, userName: user.nickname ?? user.displayName);
                        }
                      },
                      color: AppTheme.primaryColor,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: uiState.isBreathingActive ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGreetingHeader(plan, name, user, isMorning),
                            const SizedBox(height: 24),

                            if (plan != null) ...[
                              if (isMorning) ...[
                                _buildWellnessScoreRing(plan.wellnessScore),
                                const SizedBox(height: 24),
                                _buildGamificationHub(tasksState),
                                const SizedBox(height: 24),
                                _buildWeeklyTrendChart(dbState.recentMoods),
                                const SizedBox(height: 24),
                                _buildFocusCard(plan.focus),
                                const SizedBox(height: 24),
                                _buildGuidedJourney(plan, user),
                                const SizedBox(height: 24),
                                if (uiState.completedJourneySteps >= 4)
                                  _buildMorningReflectionScene(plan),
                              ] else ...[
                                _buildEveningMoodDial(user),
                                const SizedBox(height: 24),
                                _buildEveningReflection(plan, user),
                                const SizedBox(height: 24),
                                _buildSleepSoundsMixer(),
                                const SizedBox(height: 24),
                                _buildTomorrowPreview(plan),
                              ],
                              const SizedBox(height: 32),
                              _buildQuickActions(plan),
                            ] else ...[
                              _buildFallbackContent(user),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          if (uiState.isBreathingActive)
            Positioned.fill(
              child: _buildBreathingOverlay(),
            ),

          if (uiState.showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ConfettiPainter(particles: _particles),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Scene 1: Header Greeting ──────────────────────────────────────
  Widget _buildGreetingHeader(WellnessPlan? plan, String name, dynamic user, bool isMorning) {
    final streak = user?.streakDays ?? 0;
    final greetingText = plan?.briefing.greeting ?? (isMorning ? 'Good morning' : 'Welcome back');
    final subGreeting = isMorning
        ? "Yesterday was challenging, but today is a new beginning."
        : "You accomplished more than you realize today.";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingText,
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isMorning ? AppTheme.primaryDark : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isMorning ? AppTheme.primaryColor : AppTheme.secondaryColor.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subGreeting,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: isMorning ? Colors.black54 : Colors.white60,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            if (streak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isMorning ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: AppTheme.accentColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$streak',
                      style: TextStyle(
                        color: isMorning ? AppTheme.primaryColor : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push(AppRoutes.settings),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isMorning ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.settings_outlined, size: 20, color: isMorning ? AppTheme.primaryColor : Colors.white70),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push(AppRoutes.profile),
                borderRadius: BorderRadius.circular(20),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: isMorning ? AppTheme.primaryColor.withValues(alpha: 0.2) : AppTheme.secondaryColor.withValues(alpha: 0.2),
                  backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                  child: user?.photoUrl == null
                      ? Text(
                          (user?.displayName.isNotEmpty == true) ? user!.displayName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: isMorning ? AppTheme.primaryColor : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Scene 2: Wellness Pulse (Ring) ──────────────────────────────────
  Widget _buildWellnessScoreRing(WellnessScore score) {
    final ratingColor = score.overall >= 75
        ? AppTheme.successColor
        : score.overall >= 50
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    return Center(
      child: GestureDetector(
        onTap: () => _showScoreBreakdownSheet(score),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: ratingColor.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse Glow Effect
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ratingColor.withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .scaleXY(begin: 0.95, end: 1.05, duration: 2.seconds, curve: Curves.easeInOut),

                  // Custom Score Ring
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CustomPaint(
                      painter: ScoreRingPainter(
                        score: score.overall.toDouble(),
                        color: ratingColor,
                      ),
                    ),
                  ),

                  // Score Center Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${score.overall}',
                        style: const TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      Text(
                        'Wellness Score',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Directions Breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreMetricIndicator('Sleep', score.sleep >= 7 ? '↑' : '↓', score.sleep >= 7 ? AppTheme.successColor : AppTheme.warningColor),
                  _buildScoreMetricIndicator('Stress', score.overall >= 70 ? '↓' : '↑', score.overall >= 70 ? AppTheme.successColor : AppTheme.errorColor),
                  _buildScoreMetricIndicator('Mood', score.mood >= 3.5 ? '↑' : '↓', score.mood >= 3.5 ? AppTheme.successColor : AppTheme.warningColor),
                  _buildScoreMetricIndicator('Energy', score.activity >= 50 ? '↑' : '↓', score.activity >= 50 ? AppTheme.successColor : AppTheme.warningColor),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to explore details',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.primaryColor.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildScoreMetricIndicator(String label, String arrow, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              arrow,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDark,
              ),
            ),
          ],
        ),
      ],
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
              _buildBreakdownRow('Mood Check-ins', (score.mood * 20).round(), AppTheme.warningColor),
              _buildBreakdownRow('Sleep Quality', (score.sleep * 10).round(), Colors.blue),
              _buildBreakdownRow('Habits Completion', (score.habits).round(), AppTheme.successColor),
              _buildBreakdownRow('Meditation Practice', (score.meditationConsistency).round(), AppTheme.primaryColor),
              _buildBreakdownRow('Hydration Level', (score.hydration).round(), const Color(0xFF00BCD4)),
              const SizedBox(height: 24),
              if (score.improvements.isNotEmpty) ...[
                const Text(
                  'Strengths Today',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                ...score.improvements.map((imp) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(imp, style: const TextStyle(color: Colors.white70, fontSize: 13))),
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
                child: const Text('Back to Journey', style: TextStyle(color: Colors.white)),
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
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text('$pct%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
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

  // ── Scene 3: Today's Mission ──────────────────────────────────────
  Widget _buildFocusCard(DailyFocus focus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                focus.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TODAY'S MISSION",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      focus.title,
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            focus.description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFocusMeta('Estimated time', '15 minutes', Icons.timer_outlined),
              _buildFocusMeta('Expected benefit', 'Higher energy this afternoon', Icons.flash_on_outlined),
            ],
          ),
          const SizedBox(height: 20),
          PremiumBounceInteraction(
            onTap: () {
              // Smooth scroll to the Guided Journey stepper
              _scrollController.animateTo(
                450,
                duration: 600.ms,
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Start My Journey",
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFocusMeta(String label, String val, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
            Text(
              val,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
            ),
          ],
        ),
      ],
    );
  }

  // ── Scene 4: Guided Journey (Morning) ──────────────────────
  Widget _buildGuidedJourney(WellnessPlan plan, dynamic user) {
    final uiState = ref.watch(dashboardUiProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guided Path',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Complete sequentially to anchor your day.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 24),

          _buildJourneyStep(
            stepNum: 1,
            title: '3-Minute Deep Breath',
            desc: 'Box breathing technique to lower pulse.',
            actionLabel: 'Breathe',
            isCompleted: uiState.completedJourneySteps >= 1,
            isActive: uiState.completedJourneySteps == 0,
            onAction: () => _launchBreathingSession(),
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
                    ? const Text('Habit completed ✓', style: TextStyle(color: AppTheme.successColor, fontSize: 13, fontWeight: FontWeight.w600))
                    : const Text('Locked', style: TextStyle(color: Colors.black38, fontSize: 12))),
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
                    ? const Text('Mood logged ✓', style: TextStyle(color: AppTheme.successColor, fontSize: 13, fontWeight: FontWeight.w600))
                    : const Text('Locked', style: TextStyle(color: Colors.black38, fontSize: 12))),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 180.ms).slideY(begin: 0.1, end: 0);
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
    final statusColor = isCompleted
        ? AppTheme.successColor
        : isActive
            ? AppTheme.accentColor
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
                      ? AppTheme.accentColor.withValues(alpha: 0.15)
                      : Colors.transparent,
              border: Border.all(
                color: statusColor,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? const Icon(Icons.check, color: AppTheme.successColor, size: 18)
                : Text(
                    '$stepNum',
                    style: TextStyle(
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
                    color: isCompleted ? Colors.black54 : AppTheme.primaryDark,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                if (isActive && customWidget == null && onAction != null) ...[
                  const SizedBox(height: 10),
                  PremiumBounceInteraction(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_border, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(habit.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryDark)),
                          const SizedBox(height: 2),
                          Text('Duration: ${habit.durationMinutes} mins', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_outline, color: AppTheme.primaryColor),
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
                  border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🌿 Wonderful.',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'You\'ve taken a small step today, and those often become the biggest changes over time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.primaryDark),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(emojis.length, (index) {
        final isSelected = uiState.journeySelectedMood == index;
        return DebounceButton(
          onTap: () async {
            final hapticsEnabled = ref.read(soundHapticProvider);
            if (hapticsEnabled) {
              HapticFeedback.mediumImpact();
            }
            ref.read(dashboardUiProvider.notifier).setJourneySelectedMood(index);
            await ref.read(dashboardProvider.notifier).setTodayMood(index + 1);
            await Future.delayed(const Duration(milliseconds: 600));
            ref.read(dashboardUiProvider.notifier).setCompletedJourneySteps(4);
            _triggerCelebration();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentColor.withValues(alpha: 0.2) : Colors.transparent,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: AppTheme.accentColor, width: 1.5) : null,
            ),
            child: Text(
              emojis[index],
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      }),
    );
  }

  // ── Scene 5: Morning Reflection (Post-Journey) ────────────────────
  Widget _buildMorningReflectionScene(WellnessPlan plan) {
    // Extract first AI insight if present
    final insight = plan.insights.isNotEmpty ? plan.insights.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌿 Reflection',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Nova: \"You have dedicated meaningful time to your wellbeing today. Nova welcomes your presence.\"",
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
          ),
          if (insight != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.black12),
            const SizedBox(height: 8),
            Text(
              'Observation: ${insight.message}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
            ),
            if (insight.evidence.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Evidence: ${insight.evidence.map((e) => e.description).join(', ')}',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              'Suggested Action: ${insight.title}',
              style: const TextStyle(fontSize: 11, color: AppTheme.accentColor, fontWeight: FontWeight.w600),
            ),
            if (insight.recommendation != null) ...[
              const SizedBox(height: 4),
              Text(
                'Expected Benefit: ${insight.recommendation!.detail}',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Text(
            'How is your heart tonight?',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
              overlayColor: (activeMood['color'] as Color).withValues(alpha: 0.15),
              valueIndicatorColor: activeMood['color'] as Color,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: uiState.eveningMoodDragValue,
              min: 0,
              max: 4,
              divisions: 4,
              onChanged: (val) {
                ref.read(dashboardUiProvider.notifier).setEveningMoodDragValue(val);
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
                await ref.read(dashboardProvider.notifier).setTodayMood(val.round() + 1);
                ref.read(dashboardUiProvider.notifier).setEveningMoodSaved(true);
                _triggerCelebration();
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            uiState.eveningMoodSaved ? 'Changes saved automatically ✓' : 'Drag to adjust · Saves automatically on release',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  // ── Scene 3 (Evening): Inline Journal Reflection (Autosaves) ──────
  Widget _buildEveningReflection(WellnessPlan plan, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evening Reflection',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54),
                ),
                const SizedBox(width: 8),
                const Text('Saving draft...', style: TextStyle(color: Colors.white30, fontSize: 11)),
              ] else if (_journalSaved) ...[
                const Icon(Icons.check, color: AppTheme.successColor, size: 14),
                const SizedBox(width: 6),
                const Text('Autosaved', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSleepSoundsMixer() {
    final uiState = ref.watch(dashboardUiProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sleep Soundscape',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nova suggests: "Rain sounds would help tonight"',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  final hapticsEnabled = ref.read(soundHapticProvider);
                  if (hapticsEnabled) {
                    HapticFeedback.lightImpact();
                  }
                  ref.read(dashboardUiProvider.notifier).toggleSoundPlaying();
                },
                child: CircleAvatar(
                  backgroundColor: uiState.isSoundPlaying ? AppTheme.primaryColor : Colors.white10,
                  radius: 20,
                  child: Icon(
                    uiState.isSoundPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (uiState.isSoundPlaying) ...[
            SizedBox(
              height: 30,
              width: double.infinity,
              child: CustomPaint(
                painter: EqualizerWavePainter(
                  rain: uiState.rainVolume,
                  ocean: uiState.oceanVolume,
                  forest: uiState.forestVolume,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSoundBubble('Gentle Rain', 'rain', Icons.water_drop, Colors.blue, uiState.rainVolume),
              _buildSoundBubble('Ocean Waves', 'ocean', Icons.waves, Colors.teal, uiState.oceanVolume),
              _buildSoundBubble('Forest Wind', 'forest', Icons.nature_people, Colors.green, uiState.forestVolume),
            ],
          ),

          if (uiState.expandedSoundBubble != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    uiState.expandedSoundBubble == 'rain'
                        ? Icons.water_drop
                        : uiState.expandedSoundBubble == 'ocean'
                            ? Icons.waves
                            : Icons.nature_people,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: uiState.expandedSoundBubble == 'rain'
                          ? uiState.rainVolume
                          : uiState.expandedSoundBubble == 'ocean'
                              ? uiState.oceanVolume
                              : uiState.forestVolume,
                      onChanged: (val) {
                        ref.read(dashboardUiProvider.notifier).setSoundVolume(
                          rain: uiState.expandedSoundBubble == 'rain' ? val : null,
                          ocean: uiState.expandedSoundBubble == 'ocean' ? val : null,
                          forest: uiState.expandedSoundBubble == 'forest' ? val : null,
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white30, size: 16),
                    onPressed: () {
                      ref.read(dashboardUiProvider.notifier).setExpandedSoundBubble(null);
                    },
                  ),
                ],
              ),
            ).animate().fadeIn().scaleY(begin: 0.8, end: 1.0),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 180.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSoundBubble(String name, String key, IconData icon, Color baseColor, double vol) {
    final uiState = ref.watch(dashboardUiProvider);
    final isSelected = uiState.expandedSoundBubble == key;
    return GestureDetector(
      onTap: () {
        final hapticsEnabled = ref.read(soundHapticProvider);
        if (hapticsEnabled) {
          HapticFeedback.lightImpact();
        }
        ref.read(dashboardUiProvider.notifier).setExpandedSoundBubble(key);
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? baseColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isSelected ? baseColor : Colors.white12,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: isSelected ? baseColor : Colors.white54,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 10, color: Colors.white70)),
          Text('${(vol * 100).round()}%', style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  // ── Scene 5 (Evening): Tomorrow Preview ────────────────────────────
  Widget _buildTomorrowPreview(WellnessPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tomorrow\'s Outlook',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentColor,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Tomorrow we\'ll focus on reducing your afternoon stress and supporting your recovery.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8),
          Text(
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
    ).animate().fadeIn(duration: 500.ms, delay: 240.ms).slideY(begin: 0.1, end: 0);
  }

  // ── Quick Actions ──────────────────────────────────────────────────
  Widget _buildQuickActions(WellnessPlan plan) {
    final isMorning = _isMorningMode(plan);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Explore',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isMorning ? AppTheme.primaryDark : Colors.white,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: _buildActionItem('Analytics', Icons.insights_rounded, isMorning, () => context.push(AppRoutes.analytics))),
            const SizedBox(width: 8),
            Expanded(child: _buildActionItem('Daily Tasks', Icons.checklist_rounded, isMorning, () => context.push(AppRoutes.dailyTasks))),
            const SizedBox(width: 8),
            Expanded(child: _buildActionItem('Therapy Hub', Icons.healing_outlined, isMorning, () => context.push(AppRoutes.therapyHub))),
            const SizedBox(width: 8),
            Expanded(child: _buildActionItem('Check-in', Icons.assignment_rounded, isMorning, () => context.push(AppRoutes.checkin))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildActionItem('Journal', Icons.book_outlined, isMorning, () => context.push(AppRoutes.journal))),
            const SizedBox(width: 8),
            Expanded(child: _buildActionItem('Meditate', Icons.self_improvement_outlined, isMorning, () => context.push(AppRoutes.meditation))),
            const SizedBox(width: 8),
            Expanded(child: _buildActionItem('Nova Chat', Icons.chat_bubble_outline, isMorning, () => context.push(AppRoutes.aiChat))),
            const SizedBox(width: 8),
            Expanded(child: _buildActionItem('Videos', Icons.smart_display_outlined, isMorning, () => context.push(AppRoutes.videos))),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(String label, IconData icon, bool isMorning, VoidCallback onTap) {
    return PremiumBounceInteraction(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isMorning ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isMorning ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white10,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isMorning ? AppTheme.primaryColor : AppTheme.secondaryColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isMorning ? AppTheme.primaryDark : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchBreathingSession({bool isEmergency = false}) {
    final hapticsEnabled = ref.read(soundHapticProvider);
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    ref.read(dashboardUiProvider.notifier).setBreathingActive(true, isEmergency: isEmergency);

    _breathingOrbController.duration = Duration(seconds: isEmergency ? 5 : 4);
    _breathingOrbController.reset();
    _breathingOrbController.forward();

    _breathingTimer?.cancel();
    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final uiState = ref.read(dashboardUiProvider);
      final isEmergencyCalm = uiState.isEmergencyCalm;
      final cycleTime = isEmergencyCalm ? 5 : 4;

      if (uiState.breathingSecondsLeft > 1) {
        ref.read(dashboardUiProvider.notifier).updateBreathingPhase(
          phaseText: uiState.breathingPhaseText,
          secondsLeft: uiState.breathingSecondsLeft - 1,
          rounds: uiState.breathingRounds,
        );
      } else {
        String nextPhase;
        int newRounds = uiState.breathingRounds;

        if (uiState.breathingPhaseText == 'Prepare' || uiState.breathingPhaseText == 'Exhale') {
          nextPhase = 'Inhale';
          _breathingOrbController.duration = Duration(seconds: cycleTime);
          _breathingOrbController.reset();
          _breathingOrbController.forward();
          final h = ref.read(soundHapticProvider);
          if (h) HapticFeedback.selectionClick();
        } else if (uiState.breathingPhaseText == 'Inhale') {
          nextPhase = 'Hold';
          final h = ref.read(soundHapticProvider);
          if (h) HapticFeedback.selectionClick();
        } else {
          nextPhase = 'Exhale';
          _breathingOrbController.duration = Duration(seconds: cycleTime);
          _breathingOrbController.reset();
          _breathingOrbController.reverse();
          newRounds++;
          final h = ref.read(soundHapticProvider);
          if (h) HapticFeedback.selectionClick();
        }

        if (newRounds >= 3) {
          _stopBreathingSession(completed: true);
          return;
        }

        ref.read(dashboardUiProvider.notifier).updateBreathingPhase(
          phaseText: nextPhase,
          secondsLeft: cycleTime,
          rounds: newRounds,
        );
      }
    });
  }

  void _stopBreathingSession({bool completed = false}) {
    _breathingTimer?.cancel();
    _breathingOrbController.reset();
    final uiState = ref.read(dashboardUiProvider);
    ref.read(dashboardUiProvider.notifier).stopBreathing();
    if (completed && uiState.completedJourneySteps == 0 && !uiState.isEmergencyCalm) {
      ref.read(dashboardUiProvider.notifier).setCompletedJourneySteps(1);
    }
    final hapticsEnabled = ref.read(soundHapticProvider);
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (completed) _triggerCelebration();
  }

  // ── Fallback when wellness plan is null ──────────────────────────
  Widget _buildFallbackContent(dynamic user) {
    final error = ref.read(wellnessPlanProvider).error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              error ?? 'Unable to load your wellness plan',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to retry, or check your connection',
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 120,
              child: _buildActionItem('Retry', Icons.refresh_rounded, true, () {
                if (user != null) {
                  ref.read(wellnessPlanProvider.notifier).load(user.uid,
                      userName: user.nickname ?? user.displayName);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingOverlay() {
    final uiState = ref.watch(dashboardUiProvider);
    return Container(
      color: Colors.black.withValues(alpha: 0.95),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Semantics(
                  label: 'Close breathing exercise',
                  hint: 'Ends the breathing session',
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60, size: 28),
                    onPressed: () => _stopBreathingSession(),
                  ),
                ),
              ),
            ),
            const Spacer(),

            RepaintBoundary(
              child: AnimatedBuilder(
              animation: _breathingScaleAnimation,
              builder: (context, child) {
                final scale = _breathingScaleAnimation.value;
                return Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: uiState.isEmergencyCalm
                            ? [const Color(0xFFFFB399), const Color(0xFFD35400)]
                            : [const Color(0xFF8CE0E0), const Color(0xFF3B9B9B)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (uiState.isEmergencyCalm ? const Color(0xFFFFB399) : const Color(0xFF8CE0E0))
                              .withValues(alpha: 0.35 + (_breathingOrbController.value * 0.15)),
                          blurRadius: 30 + (_breathingOrbController.value * 20),
                          spreadRadius: 4 + (_breathingOrbController.value * 6),
                        ),
                      ],
                    ),
                    transform: Matrix4.diagonal3Values(scale, scale, 1.0),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          uiState.breathingPhaseText,
                          style: const TextStyle(
                            fontFamily: 'Playfair Display',
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${uiState.breathingSecondsLeft}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ),

            const Spacer(),
            Text(
              uiState.isEmergencyCalm
                  ? 'Emergency Calm mode · Focus on the rhythm'
                  : 'Rounds: ${uiState.breathingRounds} / 3',
              style: const TextStyle(color: Colors.white30, fontSize: 13),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Gamification Hub Card ──
  Widget _buildGamificationHub(TasksState tasksState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = tasksState.xpForNextLevel > 0 
        ? (tasksState.xpInLevel / tasksState.xpForNextLevel).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars_rounded, color: AppTheme.accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEVEL ${tasksState.currentLevel}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'Wellness Explorer',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${tasksState.totalXp} XP',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // XP Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${tasksState.xpInLevel}/${tasksState.xpForNextLevel} XP',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Badges row
          Row(
            children: [
              Text(
                'Earned Badges:',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: tasksState.badges.where((b) => b.earned).map((badge) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Tooltip(
                          message: '${badge.label}: ${badge.description}',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(badge.emoji, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  badge.label,
                                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 120.ms).slideY(begin: 0.1, end: 0);
  }

  // ── Weekly Mood Trend Chart ──
  Widget _buildWeeklyTrendChart(List<Map<String, dynamic>> moodHistory) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<FlSpot> spots = [];

    // Parse moods in chronological order (reverse of database query which is descending)
    final sortedMoods = List<Map<String, dynamic>>.from(moodHistory).reversed.toList();
    
    for (int i = 0; i < sortedMoods.length; i++) {
      final moodVal = (sortedMoods[i]['mood'] as num?)?.toDouble() ?? 3.0;
      spots.add(FlSpot(i.toDouble(), moodVal));
    }

    // Fallback spots for premium layout when empty
    final isMock = spots.isEmpty || spots.length < 2;
    if (isMock) {
      spots.clear();
      spots.addAll([
        const FlSpot(0, 3.0),
        const FlSpot(1, 3.5),
        const FlSpot(2, 3.2),
        const FlSpot(3, 4.0),
        const FlSpot(4, 3.8),
        const FlSpot(5, 4.5),
        const FlSpot(6, 4.2),
      ]);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Mood Flow',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.primaryDark,
                ),
              ),
              if (isMock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No Data Yet',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= spots.length) return const SizedBox.shrink();
                        // Standard days short labels
                        final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Text(
                          labels[idx % labels.length],
                          style: GoogleFonts.outfit(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: spots.length.toDouble() - 1,
                minY: 1,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.25),
                          AppTheme.primaryColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 140.ms).slideY(begin: 0.1, end: 0);
  }
}

// ── Background backdrop widgets ────────────────────────────────────
class SunriseBackground extends StatelessWidget {
  const SunriseBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF0EBFF), // Lavender glow
            Color(0xFFE8E0FF), // Soft Lavender
            Color(0xFFD5CCFF), // Deep Lavender Sky
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
          Color(0xFF0A0815),
          Color(0xFF120E24),
          Color(0xFF1A1633),
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

// ── Particle celebration helper structures ─────────────────────────
class Particle {
  double x = 0.5;
  double y = 0.1;
  double vx = 0;
  double vy = 0;
  double size = 0;
  Color color = Colors.white;

  Particle() {
    final rnd = Random();
    x = rnd.nextDouble();
    y = -0.05;
    vx = (rnd.nextDouble() - 0.5) * 0.02;
    vy = rnd.nextDouble() * 0.02 + 0.01;
    size = rnd.nextDouble() * 5 + 3;
    color = [
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      const Color(0xFF00BCD4),
      Colors.pinkAccent,
    ][rnd.nextInt(5)];
  }

  void update() {
    x += vx;
    y += vy;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;
  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      p.update();
      if (p.x < 0 || p.x > 1 || p.y > 1) continue;
      paint.color = p.color;
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Visual sleep equalizer waveform painter ────────────────────────
class EqualizerWavePainter extends CustomPainter {
  final double rain;
  final double ocean;
  final double forest;

  EqualizerWavePainter({required this.rain, required this.ocean, required this.forest});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.secondaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const barsCount = 20;
    final spacing = size.width / barsCount;


    final timeFactor = DateTime.now().millisecondsSinceEpoch / 100.0;

    for (var i = 0; i < barsCount; i++) {
      final x = i * spacing + spacing / 2;
      // Calculate dynamic wave amplitude
      final ampFactor = (sin(i * 0.5 + timeFactor) * 0.5 + 0.5);
      final mixFactor = (rain * 15.0) + (ocean * 12.0) + (forest * 8.0);
      final h = max(4.0, ampFactor * mixFactor);

      canvas.drawLine(
        Offset(x, size.height / 2 - h / 2),
        Offset(x, size.height / 2 + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
