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
            colors: [AppTheme.darkBg, AppTheme.darkSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [AppTheme.lightCard, AppTheme.lightBorder],
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
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // New full branding logo replacing both individual logo and title
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 48, bottom: 24),
                    child: const AppLogo(
                      width: 220,
                      variant: LogoVariant.full,
                    ),
                  ),
                ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),

                // Mockup style Subtitle
                Text(
                  'Your mental wellbeing matters',
                  style: GoogleFonts.outfit(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    letterSpacing: 0.2,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 100.ms)
                    .slideY(begin: 0.1, end: 0),
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
                      color: isDark
                          ? Colors.white70
                          : AppTheme.primaryDark.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms)
                    .slideY(begin: 0.1, end: 0),

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
                        color: isDark
                            ? Colors.white60
                            : AppTheme.primaryDark.withValues(alpha: 0.6),
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
}
