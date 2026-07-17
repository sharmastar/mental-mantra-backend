import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/nova_conversation_history.dart';

class WellnessActionCard extends StatelessWidget {
  final WellnessAction action;

  const WellnessActionCard({super.key, required this.action});

  Color _colorForType(WellnessActionType type) {
    switch (type) {
      case WellnessActionType.sos:
        return AppTheme.errorColor;
      case WellnessActionType.breathing:
        return const Color(0xFF6366F1);
      case WellnessActionType.grounding:
        return const Color(0xFF8B5CF6);
      case WellnessActionType.meditation:
        return AppTheme.primaryColor;
      case WellnessActionType.sleepSounds:
        return const Color(0xFF6366F1);
      case WellnessActionType.recoveryPlan:
        return AppTheme.warningColor;
      case WellnessActionType.professionalHelp:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _iconForType(WellnessActionType type) {
    switch (type) {
      case WellnessActionType.sos:
        return Icons.emergency_rounded;
      case WellnessActionType.breathing:
        return Icons.air_rounded;
      case WellnessActionType.grounding:
        return Icons.spa_rounded;
      case WellnessActionType.meditation:
        return Icons.self_improvement_rounded;
      case WellnessActionType.sleepSounds:
        return Icons.bedtime_rounded;
      case WellnessActionType.recoveryPlan:
        return Icons.shield_rounded;
      case WellnessActionType.professionalHelp:
        return Icons.favorite_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colorForType(action.type);

    return Padding(
      padding: const EdgeInsets.only(left: 44, right: 16, top: 4, bottom: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).pushNamed(action.route);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.10 : 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.25 : 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconForType(action.type), color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action.label.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : AppTheme.darkCard,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to open',
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withValues(alpha: 0.5),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
