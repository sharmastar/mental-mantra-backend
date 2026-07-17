import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../../core/utils/meditation_utils.dart';
import '../../../meditation/presentation/widgets/breathing_sheet.dart';
import '../../../wellness/presentation/pages/emergency_wellness_page.dart';

class CravingSosPage extends ConsumerStatefulWidget {
  const CravingSosPage({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const CravingSosPage(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  ConsumerState<CravingSosPage> createState() => _CravingSosPageState();
}

class _CravingSosPageState extends ConsumerState<CravingSosPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnim;
  bool _showTools = false;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _breatheAnim = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showTools = true);
    });
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  bool get _hapticsEnabled => ref.read(soundHapticProvider);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A1F),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.emergency,
                            color: AppTheme.errorColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Craving SOS',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Take a breath. You are in control.',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _BreathingOrb(
                      breatheAnim: _breatheAnim,
                      onTap: () {
                        triggerHaptic(HapticType.medium,
                            enabled: _hapticsEnabled);
                        BreathingSheet.show(context, pattern: 1);
                      },
                    ),
                    const SizedBox(height: 28),
                    AnimatedOpacity(
                      opacity: _showTools ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: _showTools
                          ? Column(
                              children: [
                                _SosActionRow(
                                  actions: [
                                    _SosAction(
                                      icon: Icons.air,
                                      label: 'Box Breathing',
                                      subtitle: '4-4-4-4 calm',
                                      color: const Color(0xFF4ECDC4),
                                      onTap: () {
                                        triggerHaptic(HapticType.light,
                                            enabled: _hapticsEnabled);
                                        BreathingSheet.show(context,
                                            pattern: 0);
                                      },
                                    ),
                                    _SosAction(
                                      icon: Icons.landscape,
                                      label: 'Grounding',
                                      subtitle: '5-4-3-2-1 senses',
                                      color: const Color(0xFFF7B731),
                                      onTap: () {
                                        triggerHaptic(HapticType.light,
                                            enabled: _hapticsEnabled);
                                        EmergencyWellnessPage.show(context);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _SosActionRow(
                                  actions: [
                                    _SosAction(
                                      icon: Icons.headphones,
                                      label: 'Calm Music',
                                      subtitle: 'Soothing sounds',
                                      color: const Color(0xFF6C63FF),
                                      onTap: () {
                                        triggerHaptic(HapticType.light,
                                            enabled: _hapticsEnabled);
                                        context.push(AppRoutes.music);
                                      },
                                    ),
                                    _SosAction(
                                      icon: Icons.psychology,
                                      label: 'AI Coach',
                                      subtitle: 'Talk to Nova',
                                      color: const Color(0xFFA855F7),
                                      onTap: () {
                                        triggerHaptic(HapticType.light,
                                            enabled: _hapticsEnabled);
                                        context.push(AppRoutes.aiChat);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _SosActionRow(
                                  actions: [
                                    _SosAction(
                                      icon: Icons.warning_amber_rounded,
                                      label: 'Log Craving',
                                      subtitle: 'Track this urge',
                                      color: const Color(0xFFFF6B6B),
                                      onTap: () {
                                        triggerHaptic(HapticType.light,
                                            enabled: _hapticsEnabled);
                                        context.push(AppRoutes.urgeLog);
                                      },
                                    ),
                                    _SosAction(
                                      icon: Icons.phone,
                                      label: 'Emergency',
                                      subtitle: 'Helplines & contacts',
                                      color: const Color(0xFFEF4444),
                                      onTap: () {
                                        triggerHaptic(HapticType.light,
                                            enabled: _hapticsEnabled);
                                        context.push(AppRoutes.emergency);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _MotivationalBanner(isDark: isDark),
                                const SizedBox(height: 24),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GestureDetector(
                onTap: () {
                  triggerHaptic(HapticType.medium, enabled: _hapticsEnabled);
                  Navigator.maybePop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'I feel better now',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }
}

class _BreathingOrb extends StatelessWidget {
  final Animation<double> breatheAnim;
  final VoidCallback onTap;

  const _BreathingOrb({required this.breatheAnim, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: breatheAnim,
        builder: (context, _) {
          return Transform.scale(
            scale: breatheAnim.value,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.4),
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor
                        .withValues(alpha: 0.2 * breatheAnim.value),
                    blurRadius: 40 * breatheAnim.value,
                    spreadRadius: 10 * breatheAnim.value,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.air,
                    color: AppTheme.primaryColor,
                    size: 36,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SosAction {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SosAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _SosActionRow extends StatelessWidget {
  final List<_SosAction> actions;
  const _SosActionRow({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions
          .map((a) => Expanded(
                child: GestureDetector(
                  onTap: a.onTap,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: a.color.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: a.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(a.icon, color: a.color, size: 26),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          a.label,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: a.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.subtitle,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            color: a.color.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _MotivationalBanner extends StatelessWidget {
  final bool isDark;
  const _MotivationalBanner({required this.isDark});

  static const _messages = [
    'This craving will pass. You have survived every craving before this one.',
    'You are not your urge. You are the one who chooses.',
    'Every time you resist, you get stronger.',
    'The discomfort is temporary. Your freedom is permanent.',
    'You chose recovery. That takes real courage.',
    'Feel the craving. Accept it. Let it pass.',
  ];

  @override
  Widget build(BuildContext context) {
    final msg = _messages[Random().nextInt(_messages.length)];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome,
              color: AppTheme.primaryColor.withValues(alpha: 0.6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
