import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/assessment_question.dart';

class MultiSelectChip extends StatelessWidget {
  final AssessmentQuestion question;
  final List<String> selectedValues;
  final ValueChanged<String> onToggled;

  const MultiSelectChip({
    super.key,
    required this.question,
    required this.selectedValues,
    required this.onToggled,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < question.options.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == question.options.length - 1 ? 0 : 10),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 300 + (i * 50)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: _buildOption(context, question.options[i], isLight),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, AnswerOption option, bool isLight) {
    final isSelected = selectedValues.contains(option.value);
    final effectiveColor = option.color;
    final showColor = option.color != null && option.icon != null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggled(option.value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (showColor
                  ? effectiveColor!.withValues(alpha: isLight ? 0.12 : 0.25)
                  : isLight
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))
              : (isLight ? Colors.white : Colors.white.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (showColor ? effectiveColor! : Theme.of(context).colorScheme.primary)
                : (isLight ? Colors.grey.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                color: isSelected
                    ? (showColor ? effectiveColor : Theme.of(context).colorScheme.primary)
                    : Colors.white54,
                size: 22,
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isLight
                          ? (isSelected
                              ? (showColor
                                  ? effectiveColor
                                  : Theme.of(context).colorScheme.primary)
                              : const Color(0xFF1A1A2E))
                          : (isSelected ? Colors.white : Colors.white70),
                    ),
                  ),
                  if (option.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isLight ? Colors.black38 : Colors.white38,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isSelected
                    ? (showColor ? effectiveColor : Theme.of(context).colorScheme.primary)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? (showColor ? effectiveColor! : Theme.of(context).colorScheme.primary)
                      : (isLight ? Colors.grey.withValues(alpha: 0.4) : Colors.white38),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
