import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/mood_entry.dart';

final moodListProvider =
    StateNotifierProvider<MoodListNotifier, List<MoodEntry>>(
        (ref) => MoodListNotifier());

class MoodListNotifier extends StateNotifier<List<MoodEntry>> {
  MoodListNotifier() : super(_seedData);

  static final List<MoodEntry> _seedData = [
    MoodEntry(
        moodValue: 5,
        moodLabel: 'Great',
        moodEmoji: '😄',
        stressLevel: 3,
        energyLevel: 4,
        anxietyLevel: 2,
        sleepHours: 8,
        note: 'Had a productive day!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['Work', 'Exercise']),
    MoodEntry(
        moodValue: 3,
        moodLabel: 'Okay',
        moodEmoji: '😐',
        stressLevel: 5,
        energyLevel: 3,
        anxietyLevel: 4,
        sleepHours: 6,
        note: 'Feeling a bit tired',
        createdAt: DateTime.now().subtract(const Duration(hours: 26)),
        tags: ['Sleep']),
    MoodEntry(
        moodValue: 4,
        moodLabel: 'Good',
        moodEmoji: '🙂',
        stressLevel: 4,
        energyLevel: 4,
        anxietyLevel: 3,
        sleepHours: 7,
        note: 'Morning walk helped',
        createdAt: DateTime.now().subtract(const Duration(hours: 30)),
        tags: ['Health', 'Exercise']),
    MoodEntry(
        moodValue: 2,
        moodLabel: 'Low',
        moodEmoji: '😞',
        stressLevel: 7,
        energyLevel: 2,
        anxietyLevel: 6,
        sleepHours: 5,
        note: 'Work stress building up',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['Work', 'Money']),
    MoodEntry(
        moodValue: 5,
        moodLabel: 'Great',
        moodEmoji: '😄',
        stressLevel: 2,
        energyLevel: 5,
        anxietyLevel: 1,
        sleepHours: 9,
        note: 'Weekend relaxation',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['Social', 'Family']),
  ];

  void addEntry(MoodEntry entry) {
    state = [entry, ...state];
  }
}
