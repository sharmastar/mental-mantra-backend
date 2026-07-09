import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../../../core/storage/hive_storage.dart';
class NovaVoiceOverlay extends ConsumerStatefulWidget {
  const NovaVoiceOverlay({super.key});

  static Future<String?> show(BuildContext context) {
    return Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.8),
        pageBuilder: (context, _, __) => const NovaVoiceOverlay(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  ConsumerState<NovaVoiceOverlay> createState() => _NovaVoiceOverlayState();
}

class _NovaVoiceOverlayState extends ConsumerState<NovaVoiceOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbController;
  late Animation<double> _orbScale;
  late Animation<double> _orbGlow;
  final List<double> _waveValues = List.filled(24, 4.0);
  Timer? _waveTimer;
  Timer? _speechTimeout;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _orbScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOutCubic),
    );

    _orbGlow = Tween<double>(begin: 15.0, end: 35.0).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOutCubic),
    );

    _startListening();
  }

  void _startListening() {
    final rnd = Random();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _waveValues.length; i++) {
          final angle = (timer.tick * 0.15) + (i * 0.3);
          final baseVal = sin(angle) * 12.0 + 16.0;
          _waveValues[i] = max(4.0, baseVal + rnd.nextDouble() * 6.0);
        }
      });
    });

    // Timeout after 10 seconds of silence
    _speechTimeout = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No speech detected. Please try again.')),
      );
      Navigator.of(context).pop();
    });
  }

  void _completeListening(String text) {
    _speechTimeout?.cancel();
    _waveTimer?.cancel();
    setState(() {
      _isProcessing = true;
    });
    final haptics = ref.read(soundHapticProvider);
    if (haptics) HapticFeedback.mediumImpact();
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.of(context).pop(text);
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _waveTimer?.cancel();
    _speechTimeout?.cancel();
    super.dispose();
  }

  void _cancelSpeech() {
    _speechTimeout?.cancel();
    _waveTimer?.cancel();
    final haptics = ref.read(soundHapticProvider);
    if (haptics) HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = HiveStorage.getUser();
    final name = user['nickname'] as String? ?? 'Friend';
    final firstName = name.split(' ').first;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft radial gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryDark.withValues(alpha: 0.8),
                    const Color(0xFF12101E).withValues(alpha: 0.95),
                  ],
                  radius: 1.2,
                ),
              ),
            ),
          ),

          // Central Presence Orb & Guide
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nova Voice Guide',
                style: GoogleFonts.outfit(
                  color: Colors.white30,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              // Animated Breathing Orb
              AnimatedBuilder(
                animation: _orbController,
                builder: (context, child) {
                  return Container(
                    width: 140 * _orbScale.value,
                    height: 140 * _orbScale.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.9),
                          AppTheme.primaryColor.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: _orbGlow.value,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '🌿',
                        style: TextStyle(fontSize: 42),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              
              // Empathy instructions / text
              Text(
                'Speak freely, $firstName.',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isProcessing ? 'Processing...' : 'Listening...',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 64),
              
              // Dynamic Sound Equalizer Wave
              SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(_waveValues.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 80),
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: 3.5,
                      height: _waveValues[index],
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(
                          alpha: (0.4 + (index % 5) * 0.12).clamp(0.2, 1.0),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          // Cancel / Stop Floating button at bottom
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 36,
            child: PremiumBounceInteraction(
              onTap: _cancelSpeech,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Cancel Session',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
