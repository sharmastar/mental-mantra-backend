// lib/features/dashboard/presentation/providers/routine_suggestion_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/services/ai/daily_routine_engine.dart';

class RoutineSuggestionState {
  final List<RoutineSuggestion> routines;
  final bool isLoading;

  const RoutineSuggestionState({
    this.routines = const [],
    this.isLoading = true,
  });
}

class RoutineSuggestionNotifier extends StateNotifier<RoutineSuggestionState> {
  final DailyRoutineEngine _engine;

  RoutineSuggestionNotifier(this._engine)
      : super(const RoutineSuggestionState()) {
    load();
  }

  Future<void> load() async {
    state = const RoutineSuggestionState(isLoading: true);
    final suggestions = await _engine.generateMorningRoutine();
    state = RoutineSuggestionState(routines: suggestions, isLoading: false);
  }
}

final dailyRoutineEngineProvider = Provider((ref) => DailyRoutineEngine());

final routineSuggestionProvider =
    StateNotifierProvider<RoutineSuggestionNotifier, RoutineSuggestionState>(
        (ref) {
  return RoutineSuggestionNotifier(ref.watch(dailyRoutineEngineProvider));
});
