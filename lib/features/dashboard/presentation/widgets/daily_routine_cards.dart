// lib/features/dashboard/presentation/widgets/daily_routine_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/theme/app_theme.dart';
import 'package:mental_mantra/services/ai/daily_routine_engine.dart';
import '../providers/routine_suggestion_provider.dart';

class DailyRoutineCards extends ConsumerWidget {
  final VoidCallback? onStartRoutine;

  const DailyRoutineCards({super.key, this.onStartRoutine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routineSuggestionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading) {
      return const SizedBox(
          height: 140, child: Center(child: CircularProgressIndicator()));
    }

    if (state.routines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFFFB547), size: 20),
            const SizedBox(width: 8),
            Text(
              'Your Smart Routine',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.routines.length,
            itemBuilder: (context, index) {
              final routine = state.routines[index];
              return _buildCard(routine, index, isDark, context)
                  .animate(delay: Duration(milliseconds: 100 * index))
                  .fadeIn()
                  .slideX(begin: 0.05);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
      RoutineSuggestion routine, int index, bool isDark, BuildContext context) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF7C4DFF),
      const Color(0xFF00BCD4),
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: onStartRoutine,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 1.0,
          ),
          boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Text(routine.icon, style: const TextStyle(fontSize: 18)),
                ),
                const Spacer(),
                Text(
                  '${routine.durationMinutes} min',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              routine.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                routine.description,
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
