import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/habit.dart';

class HabitsState {
  final List<Habit> habits;
  final bool isLoading;

  const HabitsState({this.habits = const [], this.isLoading = false});

  HabitsState copyWith({List<Habit>? habits, bool? isLoading}) {
    return HabitsState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get completedCount => habits.where((h) => h.done).length;
  int get totalCount => habits.length;
  double get completionRatio => totalCount > 0 ? completedCount / totalCount : 0.0;
}

class HabitsNotifier extends StateNotifier<HabitsState> {
  HabitsNotifier() : super(const HabitsState()) {
    _loadSampleHabits();
  }

  void _loadSampleHabits() {
    state = HabitsState(habits: _sampleHabits);
  }

  void addHabit({
    required String title,
    IconData icon = Icons.check_circle_outline,
    Color color = const Color(0xFF42C8B7),
    int target = 1,
  }) {
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      icon: icon,
      color: color,
      target: target,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(habits: [habit, ...state.habits]);
  }

  void toggleHabit(int index) {
    if (index < 0 || index >= state.habits.length) return;
    final habits = [...state.habits];
    final habit = habits[index];
    final newDone = !habit.done;
    habits[index] = habit.copyWith(
      done: newDone,
      streak: newDone ? habit.streak + 1 : habit.streak,
    );
    state = state.copyWith(habits: habits);
  }
}

final habitsProvider = StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  return HabitsNotifier();
});

final _sampleHabits = [
  Habit(id: 'h1', title: 'Morning Meditation', icon: Icons.self_improvement, color: const Color(0xFF42C8B7), streak: 7, done: true, target: 10, createdAt: DateTime(2026, 6, 1)),
  Habit(id: 'h2', title: 'Drink 8 glasses of water', icon: Icons.water_drop_outlined, color: const Color(0xFF00BCD4), streak: 3, done: false, target: 8, createdAt: DateTime(2026, 6, 2)),
  Habit(id: 'h3', title: 'Evening Walk', icon: Icons.directions_walk, color: const Color(0xFF4CAF50), streak: 5, done: true, target: 30, createdAt: DateTime(2026, 6, 3)),
  Habit(id: 'h4', title: 'Gratitude Journal', icon: Icons.book_outlined, color: const Color(0xFFFF6B9D), streak: 12, done: false, target: 5, createdAt: DateTime(2026, 6, 4)),
  Habit(id: 'h5', title: 'No Social Media', icon: Icons.phone_android, color: const Color(0xFFFF9800), streak: 2, done: false, target: 1, createdAt: DateTime(2026, 6, 5)),
  Habit(id: 'h6', title: 'Read 30 minutes', icon: Icons.menu_book_outlined, color: const Color(0xFF9C27B0), streak: 4, done: true, target: 30, createdAt: DateTime(2026, 6, 6)),
];
