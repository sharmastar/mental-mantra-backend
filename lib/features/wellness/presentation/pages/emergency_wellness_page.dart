import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../../../core/utils/meditation_utils.dart';
import '../../../meditation/presentation/widgets/breathing_sheet.dart';

class EmergencyWellnessPage extends ConsumerStatefulWidget {
  const EmergencyWellnessPage({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const EmergencyWellnessPage(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  ConsumerState<EmergencyWellnessPage> createState() =>
      _EmergencyWellnessPageState();
}

class _EmergencyWellnessPageState extends ConsumerState<EmergencyWellnessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _hapticsEnabled => ref.read(soundHapticProvider);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C2425) : const Color(0xFFF8F7FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Emergency Wellness',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: isDark ? Colors.white60 : Colors.black54),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Quick tools to help you feel better right now',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              _buildEmergencyAction(
                icon: Icons.air,
                title: 'Panic Breathing',
                subtitle: '4-4-4-4 box breathing for immediate calm',
                color: AppTheme.errorColor,
                onTap: () {
                  triggerHaptic(HapticType.medium, enabled: _hapticsEnabled);
                  BreathingSheet.show(context, pattern: 1);
                },
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _buildEmergencyAction(
                icon: Icons.landscape,
                title: '5-4-3-2-1 Grounding',
                subtitle: 'See 5, touch 4, hear 3, smell 2, taste 1',
                color: AppTheme.warningColor,
                onTap: () => _showGroundingExercise(context, isDark),
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _buildEmergencyAction(
                icon: Icons.format_quote,
                title: 'Calming Quote',
                subtitle: 'Read a reassuring message',
                color: AppTheme.primaryColor,
                onTap: () => _showCalmingQuote(context, isDark),
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _buildEmergencyAction(
                icon: Icons.headphones,
                title: 'Box Breathing',
                subtitle: 'Classic 4-4-4-4 breathing exercise',
                color: AppTheme.secondaryColor,
                onTap: () {
                  triggerHaptic(HapticType.light, enabled: _hapticsEnabled);
                  BreathingSheet.show(context, pattern: 0);
                },
                isDark: isDark,
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _pulseAnim.value,
                    child: PremiumBounceInteraction(
                      onTap: () {
                        triggerHaptic(HapticType.medium,
                            enabled: _hapticsEnabled);
                        Navigator.maybePop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.3),
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return PremiumBounceInteraction(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  void _showGroundingExercise(BuildContext context, bool isDark) {
    triggerHaptic(HapticType.light, enabled: _hapticsEnabled);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GroundingSheet(isDark: isDark),
    );
  }

  void _showCalmingQuote(BuildContext context, bool isDark) {
    triggerHaptic(HapticType.light, enabled: _hapticsEnabled);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CalmingQuoteSheet(isDark: isDark),
    );
  }
}

class _GroundingSheet extends StatefulWidget {
  final bool isDark;
  const _GroundingSheet({required this.isDark});

  @override
  State<_GroundingSheet> createState() => _GroundingSheetState();
}

class _GroundingSheetState extends State<_GroundingSheet> {
  int _step = 0;
  static const _steps = [
    'Look around and name\n5 things you can SEE',
    'Notice and name\n4 things you can TOUCH',
    'Listen carefully and name\n3 things you can HEAR',
    'Identify and name\n2 things you can SMELL',
    'Name\n1 thing you can TASTE',
  ];
  static const _icons = [
    Icons.visibility,
    Icons.touch_app,
    Icons.hearing,
    Icons.air,
    Icons.restaurant,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.darkBg : const Color(0xFFF8F7FC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white30 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '5-4-3-2-1 Grounding',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use your senses to return to the present moment',
            style: TextStyle(
              fontFamily: 'Outfit',
              color: widget.isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_step),
              children: [
                Icon(
                  _icons[_step],
                  size: 72,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  _steps[_step],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_step > 0)
                TextButton(
                  onPressed: () => setState(() => _step--),
                  child: const Text('Previous',
                      style: TextStyle(fontFamily: 'Outfit')),
                ),
              if (_step < _steps.length - 1)
                ElevatedButton(
                  onPressed: () => setState(() => _step++),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Next',
                      style: TextStyle(fontFamily: 'Outfit')),
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.maybePop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Done',
                      style:
                          TextStyle(fontFamily: 'Outfit', color: Colors.white)),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CalmingQuoteSheet extends StatelessWidget {
  final bool isDark;
  const _CalmingQuoteSheet({required this.isDark});

  static const _quotes = [
    '"This feeling will pass. You have survived everything life has thrown at you so far."',
    '"You are not your thoughts. You are the observer of your thoughts."',
    '"Breathe in courage, breathe out fear. You are stronger than you know."',
    '"Peace is not the absence of chaos, but the presence of calm within it."',
    '"You are exactly where you need to be. Trust the journey."',
    '"The only way out is through. And you have everything you need to get through this."',
    '"Be gentle with yourself. You are doing the best you can."',
    '"This moment is all you have. And in this moment, you are safe."',
  ];

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[Random().nextInt(_quotes.length)];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBg : const Color(0xFFF8F7FC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white30 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Icon(
            Icons.format_quote,
            size: 48,
            color: AppTheme.primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          Text(
            quote,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.maybePop(context),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child:
                const Text('Thank you', style: TextStyle(fontFamily: 'Outfit')),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
