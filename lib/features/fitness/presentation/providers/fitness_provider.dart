import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/fitness_record.dart';
import '../../data/repositories/fitness_repository.dart';

final fitnessRepositoryProvider =
    Provider<FitnessRepository>((ref) => FitnessRepository());

class FitnessState {
  final FitnessRecord? todayRecord;
  final FitnessStats stats;
  final List<FitnessRecord> history;
  final bool isLoading;
  final String? error;

  const FitnessState({
    this.todayRecord,
    this.stats = const FitnessStats(),
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  FitnessState copyWith({
    FitnessRecord? todayRecord,
    FitnessStats? stats,
    List<FitnessRecord>? history,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      FitnessState(
        todayRecord: todayRecord ?? this.todayRecord,
        stats: stats ?? this.stats,
        history: history ?? this.history,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class FitnessNotifier extends StateNotifier<FitnessState> {
  final FitnessRepository _repository;

  FitnessNotifier(this._repository) : super(const FitnessState());

  Future<void> loadFitnessData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final todayRecord = await _repository.getTodayRecord();
      final history = await _repository.getHistory();
      final stats = _computeStats(history);
      state = state.copyWith(
        todayRecord: todayRecord,
        history: history,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load fitness data');
    }
  }

  Future<bool> logWorkout(WorkoutSession session) async {
    try {
      await _repository.logWorkout(session);
      await loadFitnessData();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to log workout');
      return false;
    }
  }

  Future<bool> updateSteps(int steps) async {
    try {
      final currentRecord = state.todayRecord ??
          FitnessRecord(
            date: DateTime.now(),
            steps: steps,
          );
      final updated = FitnessRecord(
        date: currentRecord.date,
        steps: steps,
        caloriesBurned: currentRecord.caloriesBurned,
        activeMinutes: currentRecord.activeMinutes,
      );
      await _repository.saveTodayRecord(updated);
      state = state.copyWith(todayRecord: updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update steps');
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  FitnessStats _computeStats(List<FitnessRecord> history) {
    if (history.isEmpty) return const FitnessStats();
    final totalSteps = history.fold(0, (int sum, r) => sum + r.steps);
    final totalActive = history.fold(0, (int sum, r) => sum + r.activeMinutes);
    final totalCals =
        history.fold(0.0, (double sum, r) => sum + r.caloriesBurned);
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < history.length; i++) {
      final expected = today.subtract(Duration(days: i));
      final hd = history[i].date;
      if (hd.year == expected.year &&
          hd.month == expected.month &&
          hd.day == expected.day) {
        streak++;
      } else {
        break;
      }
    }
    return FitnessStats(
      averageSteps: totalSteps ~/ history.length,
      totalActiveMinutes: totalActive,
      totalCaloriesBurned: totalCals,
      streakDays: streak,
      weeklyHistory: history.take(7).toList(),
    );
  }
}

final fitnessProvider =
    StateNotifierProvider<FitnessNotifier, FitnessState>((ref) {
  final repository = ref.watch(fitnessRepositoryProvider);
  return FitnessNotifier(repository);
});
