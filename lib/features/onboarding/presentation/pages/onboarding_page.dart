import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/assessment_provider.dart';
import '../../data/models/assessment_question.dart';
import 'assessment_page.dart';
import 'analysis_page.dart';
import 'completion_page.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../music/providers/background_music_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  final bool isRecheckin;
  const OnboardingPage({super.key, this.isRecheckin = false});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step =
      0; // 0: Welcome/Consent, 1: Assessment, 2: Analysis, 3: Completion
  String _userName = '';
  Map<String, dynamic> _profile = const {};
  Future<void>? _analysisFuture;

  // Consent checkboxes
  bool _consent1 = false;
  bool _consent2 = false;
  bool _consent3 = false;
  bool _consent4 = false;

  void _onConsentSubmit() {
    if (!_consent1 || !_consent2 || !_consent3 || !_consent4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept all consent checkboxes to continue.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _step = 1;
    });
  }

  void _onAssessmentComplete(List<AssessmentResponse> responses) {
    try {
      final notifier = ref.read(assessmentProvider.notifier);

      String nickname = 'Friend';
      String ageGroup = '25-34';

      // Save each response into the notifier
      for (final response in responses) {
        notifier.selectOption(response.questionId, response.answer);
        if (response.questionId == 'nickname' &&
            response.answer != null &&
            (response.answer as String).isNotEmpty) {
          nickname = response.answer as String;
        } else if (response.questionId == 'age_group' &&
            response.answer != null) {
          ageGroup = response.answer as String;
        }
      }

      // Transition to Analysis Page immediately to show the loading screen
      if (mounted) {
        setState(() {
          _userName = nickname;
          _step = 2; // Transition to Analysis Page
        });
      }

      // Start the heavy background calculations concurrently
      final Future<void> processFuture = () async {
        // Generate classification/wellness result
        final result = await notifier.generateResult();

        // Mark onboarding complete in global auth provider
        await ref.read(authStateProvider.notifier).markOnboardingComplete({
          'assessment_completed': true,
          'assessment_answers': ref.read(assessmentProvider).answers.toJson(),
          'wellness_result': result.toJson(),
          'consent_accepted': true,
          'nickname': nickname,
          'age_group': ageGroup,
        });

        // Save classification result to Hive
        final domainScores = result.domainScores;
        final sorted = domainScores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        String domainKey(String name) {
          return switch (name) {
            'Stress & Burnout' => 'stress_burnout',
            'Anxiety & Overthinking' => 'anxiety_overthinking',
            'Low Mood' => 'stress_burnout',
            'Sleep Wellness' => 'sleep_dysregulation',
            'Relationship Wellness' => 'emotional_isolation',
            'Habit Recovery' => 'addiction_recovery',
            'Confidence Building' => 'low_motivation',
            'Social Connection' => 'emotional_isolation',
            'Mindfulness & Inner Peace' => 'spiritual_seeking',
            _ => name
                .toLowerCase()
                .replaceAll(' ', '_')
                .replaceAll('&', '')
                .replaceAll('__', '_')
                .trim(),
          };
        }

        final classification = <String, dynamic>{
          'primaryDomain': sorted.isNotEmpty
              ? domainKey(sorted.first.key)
              : 'stress_burnout',
          'secondaryDomains':
              sorted.length > 1 ? [domainKey(sorted[1].key)] : <String>[],
          'scores':
              domainScores.map((k, v) => MapEntry(domainKey(k), v.toDouble())),
          'confidence': 0.85,
          'riskLevel': result.needsCrisisSupport ? 'high' : 'low',
          'completedAt': DateTime.now().toIso8601String(),
          'version': 2,
        };
        await HiveStorage.saveClassificationV2(classification);

        // Trigger AI profile calculations in the background without blocking the UI
        notifier.calculateProfile();
      }();

      setState(() {
        _analysisFuture = processFuture;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to submit assessment: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _onAnalysisComplete() {
    final profileState = ref.read(assessmentProvider).profile;
    setState(() {
      _profile = profileState ??
          {
            'overallScore': 75.0,
            'summary':
                'Your wellness profile shows good resilience with opportunities to improve sleep and handle stress.',
            'recommendedFocusAreas': [
              'Sleep',
              'Anxiety management',
              'Physical health'
            ],
          };
      _step = 3; // Transition to Completion Page
    });
  }

  void _onBeginJourney() {
    context.go(AppRoutes.dashboard);
  }

  @override
  void initState() {
    super.initState();
    if (widget.isRecheckin) {
      _step = 1;
    }
    // Auto-initialize background music on onboarding/welcome screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backgroundMusicProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 0:
        return _buildConsentScreen();
      case 1:
        return AssessmentPage(onComplete: _onAssessmentComplete);
      case 2:
        return AnalysisPage(
          onComplete: _onAnalysisComplete,
          analysisFuture: _analysisFuture,
        );
      case 3:
        return CompletionPage(
          profile: _profile,
          userName: _userName,
          onBeginJourney: widget.isRecheckin
              ? () => Navigator.of(context).pop()
              : _onBeginJourney,
        );
      default:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }

  Widget _buildConsentScreen() {
    const Color purpleTheme = Color(0xFF623CE7);
    const Color titleColor = Color(0xFF2B2062);
    final isMusicPlaying = ref.watch(backgroundMusicProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FD),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const AppLogo(
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your mental wellbeing matters.',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: purpleTheme,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),

                  // Speech bubble
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: purpleTheme.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: purpleTheme.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.spa_rounded,
                              color: purpleTheme, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Welcome to Mental Mantra 💚\nThis space is designed to support your emotional wellness, habits, relationships, focus, and overall balance in life.",
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E1F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tune_rounded,
                                size: 18, color: purpleTheme),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your responses help us personalize your experience and recommendations.',
                                style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: titleColor,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.skip_next_rounded,
                                size: 18, color: purpleTheme),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You may skip any question you are not comfortable answering.',
                                style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: titleColor,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Consent Checklist
                  _buildConsentTile(
                    value: _consent1,
                    label: 'Do you agree to our Privacy Policy?',
                    onChanged: (val) =>
                        setState(() => _consent1 = val ?? false),
                  ),
                  const SizedBox(height: 12),
                  _buildConsentTile(
                    value: _consent2,
                    label: 'Do you agree to the Terms & Conditions?',
                    onChanged: (val) =>
                        setState(() => _consent2 = val ?? false),
                  ),
                  const SizedBox(height: 12),
                  _buildConsentTile(
                    value: _consent3,
                    label:
                        'I understand that Mental Mantra is a wellness-support platform and not a substitute for medical diagnosis or emergency psychiatric care.',
                    onChanged: (val) =>
                        setState(() => _consent3 = val ?? false),
                  ),
                  const SizedBox(height: 12),
                  _buildConsentTile(
                    value: _consent4,
                    label:
                        'Are you ready to begin your personalized assessment?',
                    onChanged: (val) =>
                        setState(() => _consent4 = val ?? false),
                  ),
                  const SizedBox(height: 36),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onConsentSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purpleTheme,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Let\'s Get Started',
                              style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward,
                              size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isMusicPlaying
                        ? Icons.music_note
                        : Icons.music_note_outlined,
                    color: isMusicPlaying ? purpleTheme : Colors.grey,
                  ),
                  onPressed: () =>
                      ref.read(backgroundMusicProvider.notifier).toggle(),
                  tooltip: isMusicPlaying
                      ? 'Mute Background Music'
                      : 'Play Background Music',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentTile({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    const Color purpleTheme = Color(0xFF623CE7);
    const Color titleColor = Color(0xFF2B2062);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value ? purpleTheme.withValues(alpha: 0.04) : Colors.white,
          border:
              Border.all(color: value ? purpleTheme : const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              activeColor: purpleTheme,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              onChanged: onChanged,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: titleColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
