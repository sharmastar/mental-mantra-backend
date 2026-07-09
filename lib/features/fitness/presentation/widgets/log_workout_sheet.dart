import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/fitness_record.dart';
import '../providers/fitness_provider.dart';

class LogWorkoutSheet extends ConsumerStatefulWidget {
  const LogWorkoutSheet({super.key});

  @override
  ConsumerState<LogWorkoutSheet> createState() => _LogWorkoutSheetState();
}

class _LogWorkoutSheetState extends ConsumerState<LogWorkoutSheet> {
  WorkoutType _type = WorkoutType.walking;
  int _durationMinutes = 30;
  double _caloriesBurned = 0;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Log Workout', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WorkoutType.values.map((t) => ChoiceChip(
              label: Text(t.label),
              selected: _type == t,
              onSelected: (_) => setState(() => _type = t),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNumberField('Duration (min)', _durationMinutes, (v) => _durationMinutes = v),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField('Calories', _caloriesBurned.round(), (v) => _caloriesBurned = v.toDouble()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Notes (optional)',
              filled: true,
              fillColor: isDark ? const Color(0xFF153C3E) : const Color(0xFFF2F8F7),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _onLogWorkout,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF42C8B7),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, int value, void Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > 0 ? () => onChanged(value - 5) : null,
            ),
            Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 5),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onLogWorkout() async {
    final session = WorkoutSession(
      type: _type,
      durationMinutes: _durationMinutes,
      caloriesBurned: _caloriesBurned,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      startedAt: DateTime.now(),
    );
    final success = await ref.read(fitnessProvider.notifier).logWorkout(session);
    if (success && mounted) Navigator.of(context).pop();
  }
}

extension on WorkoutType {
  String get label {
    switch (this) {
      case WorkoutType.walking: return 'Walking';
      case WorkoutType.running: return 'Running';
      case WorkoutType.cycling: return 'Cycling';
      case WorkoutType.yoga: return 'Yoga';
      case WorkoutType.strength: return 'Strength';
      case WorkoutType.meditation: return 'Meditation';
      case WorkoutType.stretching: return 'Stretching';
      case WorkoutType.other: return 'Other';
    }
  }
}
