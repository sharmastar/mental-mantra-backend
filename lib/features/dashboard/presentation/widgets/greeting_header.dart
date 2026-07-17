import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../services/wellness/models/wellness_plan.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../shared/widgets/app_logo.dart';

class GreetingHeader extends StatelessWidget {
  final WellnessPlan? plan;
  final String name;
  final UserModel? user;
  final bool isMorning;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap;

  const GreetingHeader({
    super.key,
    required this.plan,
    required this.name,
    required this.user,
    required this.isMorning,
    this.onSettingsTap,
    this.onProfileTap,
  });

  String get _greetingText {
    return plan?.briefing.greeting ??
        (isMorning ? 'Good morning' : 'Welcome back');
  }

  String get _subGreeting {
    return isMorning
        ? "Yesterday was challenging, but today is a new beginning."
        : "You accomplished more than you realize today.";
  }

  @override
  Widget build(BuildContext context) {
    final streak = (user is UserModel) ? (user as UserModel).streakDays : 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isMorning
        ? Colors.white
        : theme.colorScheme.onSurface;

    final subColor = isMorning
        ? Colors.white.withValues(alpha: 0.9)
        : theme.colorScheme.secondary;

    final iconBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppTheme.primaryColor.withValues(alpha: 0.08);

    final iconColor = isDark ? Colors.white70 : AppTheme.primaryColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: 'Greeting: $_greetingText',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppLogo.icon(
                      color: titleColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: AppDesign.space8),
                    Expanded(
                      child: Text(
                        _greetingText,
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDesign.space4),
              Semantics(
                label: 'User name: $name',
                child: Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: subColor,
                  ),
                ),
              ),
              const SizedBox(height: AppDesign.space4),
              Semantics(
                label: _subGreeting,
                child: Text(
                  _subGreeting,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: isMorning
                        ? Colors.white.withValues(alpha: 0.7)
                        : (isDark ? Colors.white60 : Colors.black54),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDesign.space12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (streak > 0)
              Semantics(
                label: '$streak days of showing up',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor
                        .withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.warningColor
                          .withValues(alpha: isDark ? 0.3 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: AppTheme.warningColor, size: 16),
                      const SizedBox(width: AppDesign.space4),
                      Text(
                        '$streak',
                        style: const TextStyle(
                          color: AppTheme.warningColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (streak > 0) const SizedBox(width: AppDesign.space8),
            Semantics(
              label: 'Open settings',
              button: true,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSettingsTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      size: 18,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDesign.space8),
            Semantics(
              label: 'Open profile',
              button: true,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.transparent,
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Text(
                              (user != null &&
                                      user!.displayName.isNotEmpty)
                                  ? user!.displayName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
