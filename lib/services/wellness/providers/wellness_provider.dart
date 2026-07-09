import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/network/api_client.dart';
import '../models/wellness_plan.dart';
import '../engines/wellness_engine.dart';
import '../../../core/personalization/personalization_repository.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/ai/insights/outcomes/outcome_repository.dart';
import '../../../features/journal/data/repositories/journal_repository.dart';

class WellnessPlanState {
  final WellnessPlan? plan;
  final bool isLoading;
  final String? error;

  const WellnessPlanState({this.plan, this.isLoading = false, this.error});

  WellnessPlanState copyWith({WellnessPlan? plan, bool? isLoading, String? error, bool clearError = false}) {
    return WellnessPlanState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WellnessPlanNotifier extends StateNotifier<WellnessPlanState> {
  final WellnessEngine _engine = WellnessEngine();
  final PersonalizationRepository _personalizationRepo = PersonalizationRepository();
  final JournalRepository _journalRepo = JournalRepository();
  final OutcomeRepository _outcomeRepo = OutcomeRepository();
  String? _userId;

  WellnessPlanNotifier() : super(const WellnessPlanState());

  Future<void> load(String userId, {String? userName}) async {
    _userId = userId;
    if (state.plan == null) {
      state = state.copyWith(isLoading: true);
    }
    try {
      final ctx = await _personalizationRepo.build();
      final journalEntries = await _journalRepo.getEntries(limit: 7);

      final userResponse = await ApiClient.get('/users/me');
      final userData = (userResponse.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};

      final moodResponse = await ApiClient.get('/mood', queryParameters: {'limit': 30});
      final moodData = moodResponse.data as Map<String, dynamic>;
      final moodHistory = (moodData['success'] == true && moodData['data'] != null)
          ? List<Map<String, dynamic>>.from(moodData['data'] as List)
          : <Map<String, dynamic>>[];

      final todayMood = _extractMood(moodHistory.isNotEmpty ? moodHistory.first : {}, 3);
      final yesterdayMood = _extractMood(moodHistory.length > 1 ? moodHistory[1] : {}, null);

      final outcomes = await _outcomeRepo.getOutcomesByUser(userId, limit: 100);

      final plan = _engine.generate(ctx,
        recentEntries: journalEntries,
        moodHistory: moodHistory,
        todayMood: todayMood,
        sleepHours: userData['lastSleepHours'] as int? ?? 7,
        waterGlasses: userData['waterGlasses'] as int? ?? 4,
        meditationMinutes: userData['stats']?['totalMeditationMinutes'] as int? ?? 0,
        streakDays: userData['streak']?['currentDays'] as int? ?? 0,
        screenTimeHours: userData['screenTimeHours'] as int? ?? 5,
        aiChatCount: userData['aiChatCount'] as int? ?? 0,
        habitsCompleted: userData['habitsCompleted'] as int? ?? 0,
        habitsTotal: (userData['habitsTotal'] as int?) ?? 5,
        morningAnxiety: _extractMood(moodHistory.isNotEmpty ? moodHistory.first : {}, null, key: 'anxiety'),
        eveningAnxiety: null,
        yesterdayMood: yesterdayMood,
        stress: userData['stress'] as int? ?? 5,
        anxiety: userData['anxiety'] as int? ?? 4,
        consecutiveBadSleep: userData['consecutiveBadSleep'] as int? ?? 0,
        userName: userName,
        outcomes: outcomes,
      );

      state = state.copyWith(plan: plan, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to generate wellness plan: $e');
    }
  }

  void refresh() {
    if (_userId != null) load(_userId!);
  }

  int _extractMood(Map<String, dynamic> data, int? defaultValue, {String key = 'mood'}) {
    final val = data[key];
    if (val is int) return val;
    if (val is double) return val.round();
    return defaultValue ?? 3;
  }
}

final wellnessPlanProvider = StateNotifierProvider<WellnessPlanNotifier, WellnessPlanState>((ref) {
  return WellnessPlanNotifier();
});

final wellnessPlanLoaderProvider = FutureProvider.family<void, String>((ref, userId) async {
  final user = ref.watch(currentUserProvider);
  await ref.read(wellnessPlanProvider.notifier).load(userId, userName: user?.nickname ?? user?.displayName);
});
