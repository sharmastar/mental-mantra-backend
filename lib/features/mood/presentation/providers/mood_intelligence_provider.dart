// lib/features/mood/presentation/providers/mood_intelligence_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/services/ai/mood_intelligence_engine.dart';
import 'package:mental_mantra/services/ai/weekly_summary_engine.dart';

// ── Mood Intelligence Report Provider ─────────────────────────────────

class MoodIntelligenceState {
  final MoodIntelligenceReport? weeklyReport;
  final MoodIntelligenceReport? monthlyReport;
  final bool isLoading;
  final String? error;
  final int selectedPeriodDays; // 7 or 30

  const MoodIntelligenceState({
    this.weeklyReport,
    this.monthlyReport,
    this.isLoading = false,
    this.error,
    this.selectedPeriodDays = 7,
  });

  MoodIntelligenceState copyWith({
    MoodIntelligenceReport? weeklyReport,
    MoodIntelligenceReport? monthlyReport,
    bool? isLoading,
    String? error,
    int? selectedPeriodDays,
    bool clearError = false,
  }) =>
      MoodIntelligenceState(
        weeklyReport: weeklyReport ?? this.weeklyReport,
        monthlyReport: monthlyReport ?? this.monthlyReport,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        selectedPeriodDays: selectedPeriodDays ?? this.selectedPeriodDays,
      );

  MoodIntelligenceReport? get currentReport =>
      selectedPeriodDays == 7 ? weeklyReport : monthlyReport;
}

class MoodIntelligenceNotifier extends StateNotifier<MoodIntelligenceState> {
  final _engine = MoodIntelligenceEngine();

  MoodIntelligenceNotifier() : super(const MoodIntelligenceState());

  Future<void> loadReports() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final weekly = await _engine.generateReport(days: 7);
      final monthly = await _engine.generateReport(days: 30);
      state = state.copyWith(
        weeklyReport: weekly,
        monthlyReport: monthly,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate mood insights. Please try again.',
      );
    }
  }

  void selectPeriod(int days) {
    state = state.copyWith(selectedPeriodDays: days);
  }
}

final moodIntelligenceProvider =
    StateNotifierProvider<MoodIntelligenceNotifier, MoodIntelligenceState>(
  (ref) => MoodIntelligenceNotifier(),
);

// ── Weekly Summary Provider ────────────────────────────────────────────

class WeeklySummaryState {
  final WeeklySummary? current;
  final List<WeeklySummary> history;
  final bool isLoading;

  const WeeklySummaryState({
    this.current,
    this.history = const [],
    this.isLoading = false,
  });

  WeeklySummaryState copyWith({
    WeeklySummary? current,
    List<WeeklySummary>? history,
    bool? isLoading,
  }) =>
      WeeklySummaryState(
        current: current ?? this.current,
        history: history ?? this.history,
        isLoading: isLoading ?? this.isLoading,
      );
}

class WeeklySummaryNotifier extends StateNotifier<WeeklySummaryState> {
  final _engine = WeeklySummaryEngine();

  WeeklySummaryNotifier() : super(const WeeklySummaryState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final current = await _engine.generateCurrentWeekSummary();
      final history = await _engine.getRecentSummaries(count: 4);
      state =
          state.copyWith(current: current, history: history, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final weeklySummaryProvider =
    StateNotifierProvider<WeeklySummaryNotifier, WeeklySummaryState>(
  (ref) => WeeklySummaryNotifier(),
);
