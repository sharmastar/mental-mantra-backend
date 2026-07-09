import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/daily_task.dart';
import '../../data/models/badge.dart';

class TasksState {
  final List<DailyTask> tasks;
  final List<Badge> badges;
  final int totalXp;
  final int currentLevel;
  final int xpForNextLevel;
  final int xpInLevel;
  final int streak;

  const TasksState({
    this.tasks = const [],
    this.badges = const [],
    this.totalXp = 1240,
    this.currentLevel = 4,
    this.xpForNextLevel = 500,
    this.xpInLevel = 240,
    this.streak = 7,
  });

  TasksState copyWith({
    List<DailyTask>? tasks,
    List<Badge>? badges,
    int? totalXp,
    int? currentLevel,
    int? xpForNextLevel,
    int? xpInLevel,
    int? streak,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      badges: badges ?? this.badges,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      xpForNextLevel: xpForNextLevel ?? this.xpForNextLevel,
      xpInLevel: xpInLevel ?? this.xpInLevel,
      streak: streak ?? this.streak,
    );
  }

  int get tasksDone => tasks.where((t) => t.done).length;
  int get tasksTotal => tasks.length;
}

class TasksNotifier extends StateNotifier<TasksState> {
  TasksNotifier() : super(const TasksState()) {
    _loadSampleData();
  }

  void _loadSampleData() {
    state = const TasksState(tasks: _sampleTasks, badges: _sampleBadges);
  }

  void completeTask(int index) {
    if (index < 0 || index >= state.tasks.length) return;
    final task = state.tasks[index];
    if (task.done) return;

    final tasks = [...state.tasks];
    tasks[index] = task.copyWith(done: true);

    var totalXp = state.totalXp + task.xp;
    var xpInLevel = state.xpInLevel + task.xp;
    var currentLevel = state.currentLevel;

    while (xpInLevel >= state.xpForNextLevel) {
      currentLevel++;
      xpInLevel -= state.xpForNextLevel;
    }

    state = state.copyWith(
      tasks: tasks,
      totalXp: totalXp,
      xpInLevel: xpInLevel,
      currentLevel: currentLevel,
    );
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  return TasksNotifier();
});

const _sampleTasks = [
  DailyTask(id: 't1', emoji: '🧘', label: 'Morning Meditation', type: 'meditation', xp: 30, done: true),
  DailyTask(id: 't2', emoji: '📖', label: 'Reflect on a gratitude quote', type: 'quote', xp: 20, done: true),
  DailyTask(id: 't3', emoji: '💧', label: 'Drink 8 glasses of water', type: 'habit', xp: 15, done: true),
  DailyTask(id: 't4', emoji: '🚶', label: '15-min mindful walk', type: 'exercise', xp: 40, done: true),
  DailyTask(id: 't5', emoji: '📝', label: 'Evening journal entry', type: 'journal', xp: 25, done: true),
  DailyTask(id: 't6', emoji: '🧠', label: 'Brain training game', type: 'game', xp: 20, done: false),
];

const _sampleBadges = [
  Badge(id: 'b1', emoji: '🔥', label: 'Week Warrior', description: '7-day streak', earned: true),
  Badge(id: 'b2', emoji: '🌅', label: 'Early Bird', description: '5 morning sessions', earned: true),
  Badge(id: 'b3', emoji: '🧘', label: 'Zen Master', description: '10 meditations', earned: false),
  Badge(id: 'b4', emoji: '📚', label: 'Scribe', description: '20 journal entries', earned: false),
  Badge(id: 'b5', emoji: '💪', label: 'Iron Will', description: '30-day streak', earned: false),
  Badge(id: 'b6', emoji: '🌟', label: 'Shining Star', description: '100 tasks done', earned: false),
];
