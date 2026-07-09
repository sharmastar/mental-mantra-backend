import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/assessment_question.dart';

class SliderQuestionCard extends StatefulWidget {
  final AssessmentQuestion question;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const SliderQuestionCard({
    super.key,
    required this.question,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<SliderQuestionCard> createState() => _SliderQuestionCardState();
}

class _SliderQuestionCardState extends State<SliderQuestionCard> {
  double _currentValue = 5.0;

  @override
  void initState() {
    super.initState();
    if (widget.selectedValue != null) {
      _currentValue = double.tryParse(widget.selectedValue!) ?? 5.0;
    } else {
      // Proactively set default value
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSelected(_currentValue.round().toString());
      });
    }
  }

  @override
  void didUpdateWidget(covariant SliderQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != null) {
      final parsed = double.tryParse(widget.selectedValue!);
      if (parsed != null && parsed != _currentValue) {
        setState(() {
          _currentValue = parsed;
        });
      }
    }
  }

  String _getInterpretationText(double val) {
    final intVal = val.round();
    final isConfidence = widget.question.id == '48' || widget.question.questionText.toLowerCase().contains('confidence');
    
    if (isConfidence) {
      if (intVal <= 2) return 'Feeling very insecure or doubtful 🌧️';
      if (intVal <= 4) return 'A bit shaky, room to grow 🌱';
      if (intVal <= 6) return 'Relatively steady and balanced ⚖️';
      if (intVal <= 8) return 'Feeling strong and self-assured ✨';
      return 'Unstoppable, ready for anything! 🚀';
    } else {
      // Mindfulness or default
      if (intVal <= 2) return 'Constantly distracted or on autopilot 🌪️';
      if (intVal <= 4) return 'Mind wanders frequently, slightly present 🌬️';
      if (intVal <= 6) return 'Balanced, present in key moments ⚓';
      if (intVal <= 8) return 'Highly present and calm 🧘';
      return 'Deeply aligned, aware, and centered 🌌';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: SingleChildScrollView(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, child) {
            return Opacity(
              opacity: animValue,
              child: Transform.translate(
                offset: Offset(0, 40 * (1 - animValue)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isLight 
                  ? Colors.white 
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isLight 
                    ? Colors.grey.withValues(alpha: 0.15) 
                    : Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: isLight
                  ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentValue.round().toString(),
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _getInterpretationText(_currentValue),
                    key: ValueKey<String>(_getInterpretationText(_currentValue)),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLight ? Colors.black87 : Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: isLight 
                        ? Colors.grey.withValues(alpha: 0.2) 
                        : Colors.white.withValues(alpha: 0.1),
                    thumbColor: primaryColor,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 14,
                    ),
                    overlayColor: primaryColor.withValues(alpha: 0.15),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                    tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
                    activeTickMarkColor: Colors.white24,
                    inactiveTickMarkColor: isLight ? Colors.black12 : Colors.white12,
                  ),
                  child: Slider(
                    value: _currentValue,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    onChanged: (val) {
                      if (val != _currentValue) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _currentValue = val;
                        });
                        widget.onSelected(val.round().toString());
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0 (Low)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isLight ? Colors.black38 : Colors.white38,
                        ),
                      ),
                      Text(
                        '10 (High)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isLight ? Colors.black38 : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
