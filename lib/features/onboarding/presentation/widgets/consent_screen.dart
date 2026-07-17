import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_logo.dart';

class ConsentScreen extends StatefulWidget {
  final VoidCallback onAccepted;

  const ConsentScreen({super.key, required this.onAccepted});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _isConsented = false;
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Beautiful pulsing/glowing icon container
            const AppLogo.large(),
            const SizedBox(height: 32),
            const Text(
              'Welcome to',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your safe space for emotional healing, habit recovery, and daily mindfulness.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Privacy Assurance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkCard
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? AppTheme.darkBorder
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🛡️ Privacy & Consent Agreement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacyBullet(
                    icon: Icons.lock_outline_rounded,
                    title: 'Secure & Encrypted',
                    description:
                        'All answers are fully encrypted and kept private.',
                  ),
                  const SizedBox(height: 14),
                  _buildPrivacyBullet(
                    icon: Icons.person_outline_rounded,
                    title: 'Tailored Just For You',
                    description:
                        'Data is used solely to generate your personalized wellness plans.',
                  ),
                  const SizedBox(height: 14),
                  _buildPrivacyBullet(
                    icon: Icons.delete_outline_rounded,
                    title: 'Full Data Control',
                    description:
                        'You can request deletion of all data at any time from your settings.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Consent Checkbox
            InkWell(
              onTap: () {
                setState(() {
                  _isConsented = !_isConsented;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isConsented
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        border: Border.all(
                          color: _isConsented
                              ? AppTheme.primaryColor
                              : Colors.white38,
                          width: 2,
                        ),
                      ),
                      child: _isConsented
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'I consent to the collection and processing of my responses to personalize my wellness journey.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Next Button
            GestureDetector(
              onTap: () {
                if (!_isConsented) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please accept the consent agreement to proceed.'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Feedback.forLongPress(context);
                } else if (!_accepted) {
                  setState(() {
                    _accepted = true;
                  });
                  widget.onAccepted();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: _isConsented
                      ? AppTheme.primaryGradient
                      : LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.08)
                          ],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isConsented
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Agree & Begin Journey',
                    style: TextStyle(
                      color: _isConsented ? Colors.white : Colors.white24,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyBullet({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
