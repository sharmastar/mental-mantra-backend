import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/assessment_question.dart';

class SingleSelectCard extends StatelessWidget {
  final AssessmentQuestion question;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const SingleSelectCard({
    super.key,
    required this.question,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = selectedValue == option.value;

        return Padding(
          padding: EdgeInsets.only(bottom: index == question.options.length - 1 ? 0 : 10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 50)),
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
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSelected(option.value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isLight
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))
                      : (isLight
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isLight
                            ? Colors.grey.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.1)),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected && !isLight
                      ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    if (option.icon != null) ...[
                      Icon(option.icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white54, size: 22),
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
                                      ? Theme.of(context).colorScheme.primary
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
                                color: (isLight ? Colors.black38 : Colors.white38),
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
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
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
            ),
          ),
        );
      },
    );
  }
}
