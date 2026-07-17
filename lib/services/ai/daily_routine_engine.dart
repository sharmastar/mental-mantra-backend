// lib/services/ai/daily_routine_engine.dart
import 'package:mental_mantra/core/storage/hive_storage.dart';

class RoutineSuggestion {
  final String title;
  final String description;
  final String type; // e.g., 'meditation', 'journal', 'breathing', 'exercise'
  final int durationMinutes;
  final String icon;

  const RoutineSuggestion({
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    required this.icon,
  });
}

class DailyRoutineEngine {
  Future<List<RoutineSuggestion>> generateMorningRoutine() async {
    final recentMoods = await HiveStorage.getRecentMoods(days: 3);
    final lastMood = recentMoods.isNotEmpty ? recentMoods.first : null;
    final lastMoodValue = (lastMood?['mood'] as num?)?.toDouble() ??
        (lastMood?['value'] as num?)?.toDouble() ??
        3.0;

    // We can use AI if connected, but for now we provide smart local generation based on recent data
    final suggestions = <RoutineSuggestion>[];

    // 1. Core mindfulness (depends on mood)
    if (lastMoodValue < 3.0) {
      suggestions.add(const RoutineSuggestion(
        title: 'Morning Healing Meditation',
        description:
            'A gentle meditation to ease anxiety and start the day with self-compassion.',
        type: 'meditation',
        durationMinutes: 10,
        icon: '🧘',
      ));
    } else {
      suggestions.add(const RoutineSuggestion(
        title: 'Morning Energizer',
        description:
            'Set a positive intention and build focus for the day ahead.',
        type: 'meditation',
        durationMinutes: 5,
        icon: '🌅',
      ));
    }

    // 2. Physical/Breathing
    if (lastMoodValue <= 2.5) {
      suggestions.add(const RoutineSuggestion(
        title: 'Box Breathing',
        description: 'Calm your nervous system with 4-4-4-4 breathing.',
        type: 'breathing',
        durationMinutes: 3,
        icon: '🫁',
      ));
    } else {
      suggestions.add(const RoutineSuggestion(
        title: 'Light Morning Yoga',
        description: 'Stretch out your body and awaken your energy.',
        type: 'exercise',
        durationMinutes: 15,
        icon: '🤸',
      ));
    }

    // 3. Cognitive
    suggestions.add(const RoutineSuggestion(
      title: 'Gratitude Journaling',
      description: 'Write down three things you are grateful for today.',
      type: 'journal',
      durationMinutes: 5,
      icon: '📔',
    ));

    return suggestions;
  }
}
