import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sleep_record.dart';
import '../../data/repositories/sleep_repository.dart';

final sleepRepositoryProvider =
    Provider<SleepRepository>((ref) => SleepRepository());

class SleepState {
  final List<SleepRecord> records;
  final SleepStats stats;
  final bool isLoading;
  final String? error;

  const SleepState({
    this.records = const [],
    this.stats = const SleepStats(),
    this.isLoading = false,
    this.error,
  });

  SleepState copyWith({
    List<SleepRecord>? records,
    SleepStats? stats,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      SleepState(
        records: records ?? this.records,
        stats: stats ?? this.stats,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class SleepNotifier extends StateNotifier<SleepState> {
  final SleepRepository _repository;

  SleepNotifier(this._repository) : super(const SleepState());

  Future<void> loadRecords() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final records = await _repository.getRecords();
      final stats = await _repository.computeStats();
      state = state.copyWith(records: records, stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load sleep records');
    }
  }

  Future<bool> addRecord(SleepRecord record) async {
    try {
      final success = await _repository.addRecord(record);
      if (success) {
        state = state.copyWith(records: [record, ...state.records]);
      }
      final stats = await _repository.computeStats();
      state = state.copyWith(stats: stats);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to save sleep record');
      return false;
    }
  }

  Future<bool> updateRecord(String id, SleepRecord record) async {
    try {
      await _repository.updateRecord(id, record);
      state = state.copyWith(
        records: state.records.map((r) => r.id == id ? record : r).toList(),
      );
      final stats = await _repository.computeStats();
      state = state.copyWith(stats: stats);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update sleep record');
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final sleepProvider = StateNotifierProvider<SleepNotifier, SleepState>((ref) {
  final repository = ref.watch(sleepRepositoryProvider);
  return SleepNotifier(repository);
});
