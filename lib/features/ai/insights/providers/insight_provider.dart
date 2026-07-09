import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/network/api_client.dart';
import '../models/ai_insight.dart';
import '../engines/insight_engine.dart';
import '../../../../core/personalization/personalization_repository.dart';
import '../../../journal/data/repositories/journal_repository.dart';

class InsightState {
  final AIInsightCollection? collection;
  final bool isLoading;
  final String? error;

  const InsightState({this.collection, this.isLoading = false, this.error});

  InsightState copyWith({AIInsightCollection? collection, bool? isLoading, String? error, bool clearError = false}) {
    return InsightState(
      collection: collection ?? this.collection,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class InsightNotifier extends StateNotifier<InsightState> {
  final InsightEngine _engine = InsightEngine();
  final PersonalizationRepository _personalizationRepo = PersonalizationRepository();
  final JournalRepository _journalRepo = JournalRepository();
  String? _userId;

  InsightNotifier() : super(const InsightState());

  Future<void> load(String userId) async {
    _userId = userId;
    state = state.copyWith(isLoading: true);
    try {
      final ctx = await _personalizationRepo.build();
      final journalEntries = await _journalRepo.getEntries(limit: 10);

      final moodResponse = await ApiClient.get('/mood', queryParameters: {'limit': 30});
      final moodData = moodResponse.data as Map<String, dynamic>;
      final moodHistory = (moodData['success'] == true && moodData['data'] != null)
          ? List<Map<String, dynamic>>.from(moodData['data'] as List)
          : <Map<String, dynamic>>[];

      final userResponse = await ApiClient.get('/users/me');
      final userData = (userResponse.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};

      final todayMood = moodHistory.isNotEmpty
          ? ((moodHistory.first['mood'] as num?)?.toInt() ?? 3)
          : 3;

      final collection = _engine.generate(
        ctx: ctx,
        wellnessScore: null,
        journalEntries: journalEntries,
        moodHistory: moodHistory,
        todayMood: todayMood,
        sleepHours: userData['lastSleepHours'] as int? ?? 7,
        stress: userData['stress'] as int? ?? 5,
        anxiety: userData['anxiety'] as int? ?? 4,
        consecutiveBadSleep: userData['consecutiveBadSleep'] as int? ?? 0,
        meditationMinutes: userData['stats']?['totalMeditationMinutes'] as int? ?? 0,
        streakDays: userData['streak']?['currentDays'] as int? ?? 0,
        waterGlasses: userData['waterGlasses'] as int? ?? 4,
        screenTimeHours: userData['screenTimeHours'] as int? ?? 5,
        activitiesCompleted: userData['activitiesCompleted'] as int? ?? 0,
        habitsCompleted: userData['habitsCompleted'] as int? ?? 0,
        habitsTotal: (userData['habitsTotal'] as int?) ?? 5,
      );

      state = state.copyWith(collection: collection, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to generate insights: $e');
    }
  }

  void refresh() {
    if (_userId != null) load(_userId!);
  }
}

final insightProvider = StateNotifierProvider<InsightNotifier, InsightState>((ref) {
  return InsightNotifier();
});
