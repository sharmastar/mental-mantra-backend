import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/theme/app_theme.dart';
import '../../data/models/goal.dart';

class GoalsState {
  final List<Goal> goals;
  final bool isLoading;
  final String? error;

  const GoalsState({
    this.goals = const [],
    this.isLoading = false,
    this.error,
  });

  GoalsState copyWith({
    List<Goal>? goals,
    bool? isLoading,
    String? error,
  }) {
    return GoalsState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class GoalsNotifier extends StateNotifier<GoalsState> {
  GoalsNotifier() : super(const GoalsState()) {
    _loadSampleGoals();
  }

  void _loadSampleGoals() {
    state = GoalsState(goals: _sampleGoals);
  }

  void addGoal({
    required String title,
    required String category,
    IconData icon = Icons.self_improvement,
    Color color = AppTheme.primaryColor,
    int target = 1,
  }) {
    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      icon: icon,
      color: color,
      target: target,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(goals: [goal, ...state.goals]);
  }

  void updateProgress(String id, {int? current, int? target}) {
    state = state.copyWith(
      goals: state.goals.map((g) {
        if (g.id != id) return g;
        final newCurrent = current ?? g.current;
        final newTarget = target ?? g.target;
        return g.copyWith(
          current: newCurrent,
          target: newTarget,
          progress: newTarget > 0 ? newCurrent / newTarget : 0.0,
        );
      }).toList(),
    );
  }

  void removeGoal(String id) {
    state = state.copyWith(
      goals: state.goals.where((g) => g.id != id).toList(),
    );
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  return GoalsNotifier();
});

final _sampleGoals = [
  Goal(
    id: 'g1',
    title: 'Meditate 30 days in a row',
    category: 'Mindfulness',
    progress: 0.7,
    color: AppTheme.primaryColor,
    icon: Icons.self_improvement,
    current: 21,
    target: 30,
    createdAt: DateTime(2026, 6, 1),
  ),
  Goal(
    id: 'g2',
    title: 'Write 10 journal entries',
    category: 'Journaling',
    progress: 0.5,
    color: AppTheme.errorColor,
    icon: Icons.book_outlined,
    current: 5,
    target: 10,
    createdAt: DateTime(2026, 6, 5),
  ),
  Goal(
    id: 'g3',
    title: 'Complete anxiety course',
    category: 'Learning',
    progress: 0.35,
    color: AppTheme.secondaryColor,
    icon: Icons.school_outlined,
    current: 7,
    target: 20,
    createdAt: DateTime(2026, 6, 10),
  ),
  Goal(
    id: 'g4',
    title: 'Build sleep routine',
    category: 'Sleep',
    progress: 0.9,
    color: AppTheme.primaryLight,
    icon: Icons.bedtime_outlined,
    current: 18,
    target: 20,
    createdAt: DateTime(2026, 6, 15),
  ),
];
