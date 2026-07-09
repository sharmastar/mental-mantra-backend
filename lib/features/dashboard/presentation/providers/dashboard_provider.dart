import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/network/api_client.dart';
import 'package:mental_mantra/services/ai/ai_coach_service.dart';

class DashboardState {
  final Map<String, dynamic>? dailyPlan;
  final Map<String, dynamic>? wellnessSummary;
  final int? todayMood;
  final int streak;
  final int totalMeditationMinutes;
  final List<Map<String, dynamic>> recentMoods;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.dailyPlan,
    this.wellnessSummary,
    this.todayMood,
    this.streak = 0,
    this.totalMeditationMinutes = 0,
    this.recentMoods = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    Map<String, dynamic>? dailyPlan,
    Map<String, dynamic>? wellnessSummary,
    int? todayMood,
    int? streak,
    int? totalMeditationMinutes,
    List<Map<String, dynamic>>? recentMoods,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      dailyPlan: dailyPlan ?? this.dailyPlan,
      wellnessSummary: wellnessSummary ?? this.wellnessSummary,
      todayMood: todayMood ?? this.todayMood,
      streak: streak ?? this.streak,
      totalMeditationMinutes: totalMeditationMinutes ?? this.totalMeditationMinutes,
      recentMoods: recentMoods ?? this.recentMoods,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final AiCoachService _aiService = AiCoachService();
  String? _userId;

  DashboardNotifier() : super(const DashboardState());

  Future<void> load(String userId) async {
    _userId = userId;
    if (state.dailyPlan == null) {
      state = state.copyWith(isLoading: true);
    }
    try {
      final plan = await _aiService.generateDailyPlan(userId);

      final userResponse = await ApiClient.get('/users/me');
      final userData = (userResponse.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      final streak = userData['streak']?['currentDays'] as int? ?? 0;
      final totalMin = userData['stats']?['totalMeditationMinutes'] as int? ?? 0;

      final moods = await _fetchRecentMoods(userId);

      state = state.copyWith(
        dailyPlan: plan,
        wellnessSummary: plan['wellnessSummary'],
        streak: streak,
        totalMeditationMinutes: totalMin,
        recentMoods: moods,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load dashboard: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRecentMoods(String userId) async {
    try {
      final response = await ApiClient.get('/mood', queryParameters: {'limit': 7});
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  Future<void> setTodayMood(int mood) async {
    if (_userId == null) return;
    final prevMood = state.todayMood;
    state = state.copyWith(todayMood: mood);
    try {
      await ApiClient.post('/mood', data: {
        'mood': mood,
        'date': DateTime.now().toIso8601String().split('T')[0],
      });
    } catch (e) {
      state = state.copyWith(todayMood: prevMood, error: 'Failed to save mood');
    }
  }

  void refresh() { if (_userId != null) load(_userId!); }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
