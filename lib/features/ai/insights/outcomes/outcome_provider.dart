import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recommendation.dart';
import 'outcome_repository.dart';

class OutcomeState {
  final List<RecommendationOutcome> recentOutcomes;
  final Map<String, double> actionSuccessRates;
  final bool isLoading;
  final String? error;

  const OutcomeState({
    this.recentOutcomes = const [],
    this.actionSuccessRates = const {},
    this.isLoading = false,
    this.error,
  });

  OutcomeState copyWith(
      {List<RecommendationOutcome>? recentOutcomes,
      Map<String, double>? actionSuccessRates,
      bool? isLoading,
      String? error,
      bool clearError = false}) {
    return OutcomeState(
      recentOutcomes: recentOutcomes ?? this.recentOutcomes,
      actionSuccessRates: actionSuccessRates ?? this.actionSuccessRates,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final outcomeRepositoryProvider = Provider<OutcomeRepository>((ref) {
  return OutcomeRepository();
});

class OutcomeNotifier extends StateNotifier<OutcomeState> {
  final OutcomeRepository _repository;

  OutcomeNotifier(this._repository) : super(const OutcomeState());

  Future<void> loadOutcomes(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final outcomes = await _repository.getOutcomesByUser(userId);
      final rates = _computeSuccessRates(outcomes);
      state = state.copyWith(
          recentOutcomes: outcomes,
          actionSuccessRates: rates,
          isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load outcomes: $e');
    }
  }

  Future<void> recordAccepted({
    required String recommendationId,
    required String userId,
    required String action,
    required String domain,
    required Map<String, double> beforeMetrics,
  }) async {
    try {
      await _repository.recordAccepted(
        recommendationId: recommendationId,
        userId: userId,
        action: action,
        domain: domain,
        beforeMetrics: beforeMetrics,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to record acceptance: $e');
    }
  }

  Future<void> recordCompleted({
    required String recommendationId,
    required String userId,
    required String action,
    required String domain,
    required Map<String, double> beforeMetrics,
    required Map<String, double> afterMetrics,
    required int timeTakenSeconds,
  }) async {
    try {
      await _repository.recordCompleted(
        recommendationId: recommendationId,
        userId: userId,
        action: action,
        domain: domain,
        beforeMetrics: beforeMetrics,
        afterMetrics: afterMetrics,
        timeTakenSeconds: timeTakenSeconds,
      );
      final updated = [
        RecommendationOutcome(
          recommendationId: recommendationId,
          userId: userId,
          action: action,
          domain: domain,
          accepted: true,
          completed: true,
          acceptedAt:
              DateTime.now().subtract(Duration(seconds: timeTakenSeconds)),
          completedAt: DateTime.now(),
          timeTakenSeconds: timeTakenSeconds,
          beforeMetrics: beforeMetrics,
          afterMetrics: afterMetrics,
        ),
        ...state.recentOutcomes
      ];
      final rates = _computeSuccessRates(updated);
      state =
          state.copyWith(recentOutcomes: updated, actionSuccessRates: rates);
    } catch (e) {
      state = state.copyWith(error: 'Failed to record completion: $e');
    }
  }

  Future<void> recordSkipped({
    required String recommendationId,
    required String userId,
    required String action,
    required String domain,
  }) async {
    try {
      await _repository.recordSkipped(
        recommendationId: recommendationId,
        userId: userId,
        action: action,
        domain: domain,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to record skip: $e');
    }
  }

  double successRateFor(String? action) {
    if (action == null || action.isEmpty) return 0.0;
    return state.actionSuccessRates[action] ?? 0.0;
  }

  Map<String, double> _computeSuccessRates(
      List<RecommendationOutcome> outcomes) {
    final byAction = <String, List<RecommendationOutcome>>{};
    for (final o in outcomes.where((o) => o.completed)) {
      byAction.putIfAbsent(o.action, () => []).add(o);
    }
    return byAction.map((action, list) {
      final successes = list.where((o) => o.isSuccess).length;
      return MapEntry(action, successes / list.length);
    });
  }
}

final outcomeProvider =
    StateNotifierProvider<OutcomeNotifier, OutcomeState>((ref) {
  final repo = ref.read(outcomeRepositoryProvider);
  return OutcomeNotifier(repo);
});
