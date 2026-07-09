import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../../../shared/widgets/app_logo.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Time-aware background sunset gradient (teal theme matching screenshot)
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF124C4E), Color(0xFF092526)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Mockup style Circular Leaf Icon Logo
                Center(
                  child: const AppLogo.large().animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                ),
                const SizedBox(height: 48),

                // Large Editorial Serif Branding
                Text(
                  'Mental Mantra',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 12),

                // Mockup style Subtitle
                Text(
                  'Your mental wellbeing matters 🌿',
                  style: GoogleFonts.outfit(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    letterSpacing: 0.2,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 10),

                // Mockup style Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'A safe space for your mind to rest, reflect, and recover.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white70 : const Color(0xFF092828).withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                
                const Spacer(flex: 4),

                // Solid primary CTA button leading to Sign Up
                PremiumBounceInteraction(
                  onTap: () => context.go(AppRoutes.signup),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Start Your Journey',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 350.ms),
                const SizedBox(height: 16),

                // Text trigger leading to Log In
                PremiumBounceInteraction(
                  onTap: () => context.go(AppRoutes.login),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Already have an account? Sign in',
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : const Color(0xFF092828).withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 450.ms),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String emoji, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF1A1530).withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}
