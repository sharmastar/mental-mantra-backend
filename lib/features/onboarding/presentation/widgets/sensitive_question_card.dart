import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/assessment_question.dart';
import '../../../../core/theme/app_theme.dart';

class SensitiveQuestionCard extends StatelessWidget {
  final AssessmentQuestion question;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const SensitiveQuestionCard({
    super.key,
    required this.question,
    required this.selectedValue,
    required this.onSelected,
  });

  void _showCrisisResources(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : AppTheme.darkBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.favorite,
                    color: AppTheme.errorColor, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'You Are Not Alone',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppTheme.darkBg
                      : Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for your courage in being honest about how you feel. '
                'Your feelings are valid, and help is always available.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black54
                      : Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _resourceCard(
                context,
                icon: Icons.phone,
                title: 'Vandrevala Foundation',
                subtitle: '1860-266-2345',
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 10),
              _resourceCard(
                context,
                icon: Icons.phone_in_talk,
                title: 'iCall Helpline',
                subtitle: '+91-9152987821',
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(height: 10),
              _resourceCard(
                context,
                icon: Icons.language,
                title: 'Global Crisis Support',
                subtitle: 'findahelpline.com',
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('I Understand',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showCrisisResources(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.errorColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite,
                    color: AppTheme.errorColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'If you need immediate support, crisis helplines are available 24/7. Tap to view.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isLight ? AppTheme.darkBg : Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppTheme.errorColor, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              final option = question.options[index];
              final isSelected = selectedValue == option.value;

              return Padding(
                padding: EdgeInsets.only(
                    bottom: index == question.options.length - 1 ? 0 : 10),
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
                      HapticFeedback.mediumImpact();
                      onSelected(option.value);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isLight
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.12)
                                : Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2))
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
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isLight
                                    ? (isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : AppTheme.darkBg)
                                    : (isSelected
                                        ? Colors.white
                                        : Colors.white70),
                              ),
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
                                    : (isLight
                                        ? Colors.grey.withValues(alpha: 0.4)
                                        : Colors.white38),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
