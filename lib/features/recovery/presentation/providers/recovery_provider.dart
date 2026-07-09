import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recovery_models.dart';
import '../../data/repositories/recovery_repository.dart';

final recoveryRepositoryProvider = Provider<RecoveryRepository>((ref) {
  return RecoveryRepository();
});

class RecoveryState {
  final RecoveryStats stats;
  final bool isLoading;
  final String? error;
  final DetoxSession? activeDetox;
  final bool isRecoveryActive;
  final bool isRecoveryLoading;

  const RecoveryState({
    this.stats = const RecoveryStats(),
    this.isLoading = false,
    this.error,
    this.activeDetox,
    this.isRecoveryActive = false,
    this.isRecoveryLoading = false,
  });

  RecoveryState copyWith({
    RecoveryStats? stats,
    bool? isLoading,
    String? error,
    DetoxSession? activeDetox,
    bool? isRecoveryActive,
    bool? isRecoveryLoading,
    bool clearError = false,
  }) => RecoveryState(
    stats: stats ?? this.stats,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    activeDetox: activeDetox ?? this.activeDetox,
    isRecoveryActive: isRecoveryActive ?? this.isRecoveryActive,
    isRecoveryLoading: isRecoveryLoading ?? this.isRecoveryLoading,
  );
}

class RecoveryNotifier extends StateNotifier<RecoveryState> {
  final RecoveryRepository _repository;

  RecoveryNotifier(this._repository) : super(const RecoveryState());

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final stats = await _repository.getStats();
      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load recovery data');
    }
  }

  Future<bool> logUrge(UrgeLog urge) async {
    try {
      await _repository.logUrge(urge);
      await loadStats();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to log urge');
      return false;
    }
  }

  Future<String?> startDetoxSession(DetoxSession session) async {
    try {
      final docId = await _repository.saveDetoxSession(session);
      if (docId != null) {
        state = state.copyWith(activeDetox: session);
      }
      return docId;
    } catch (e) {
      state = state.copyWith(error: 'Failed to start detox session');
      return null;
    }
  }

  Future<bool> completeDetoxSession(String id, DetoxSession session) async {
    try {
      await _repository.updateDetoxSession(id, session);
      state = state.copyWith(activeDetox: null);
      await loadStats();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to complete detox session');
      return false;
    }
  }

  Future<bool> setGoal(RecoveryGoal goal) async {
    try {
      await _repository.setRecoveryGoal(goal);
      await loadStats();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to set recovery goal');
      return false;
    }
  }

  void clearActiveDetox() {
    state = state.copyWith(activeDetox: null);
  }

  void startRecovery() {
    state = state.copyWith(isRecoveryActive: true, isRecoveryLoading: true);
  }

  void stopRecovery() {
    state = state.copyWith(isRecoveryActive: false, isRecoveryLoading: false);
  }

  Future<void> performRecovery() async {
    if (state.isRecoveryLoading) return;
    state = state.copyWith(isRecoveryLoading: true, clearError: true);
    try {
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      state = state.copyWith(error: 'Recovery failed. Please try again.');
    } finally {
      state = state.copyWith(isRecoveryLoading: false, isRecoveryActive: false);
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final recoveryProvider = StateNotifierProvider<RecoveryNotifier, RecoveryState>((ref) {
  final repo = ref.watch(recoveryRepositoryProvider);
  return RecoveryNotifier(repo);
});
