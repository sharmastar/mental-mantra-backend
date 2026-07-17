import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/network/api_client.dart';

class DashboardState {
  final int? todayMood;
  final int streak;
  final int totalMeditationMinutes;
  final List<Map<String, dynamic>> recentMoods;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.todayMood,
    this.streak = 0,
    this.totalMeditationMinutes = 0,
    this.recentMoods = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    int? todayMood,
    int? streak,
    int? totalMeditationMinutes,
    List<Map<String, dynamic>>? recentMoods,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      todayMood: todayMood ?? this.todayMood,
      streak: streak ?? this.streak,
      totalMeditationMinutes:
          totalMeditationMinutes ?? this.totalMeditationMinutes,
      recentMoods: recentMoods ?? this.recentMoods,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  String? _userId;

  DashboardNotifier() : super(const DashboardState());

  Future<void> load(String userId) async {
    _userId = userId;
    if (state.recentMoods.isEmpty && state.streak == 0) {
      state = state.copyWith(isLoading: true);
    }
    try {
      final userResponse = await ApiClient.get('/users/me');
      final userData = (userResponse.data as Map<String, dynamic>)['data']
              as Map<String, dynamic>? ??
          {};
      final streak = userData['streak']?['currentDays'] as int? ?? 0;
      final totalMin =
          userData['stats']?['totalMeditationMinutes'] as int? ?? 0;

      final moods = await _fetchRecentMoods();

      state = state.copyWith(
        streak: streak,
        totalMeditationMinutes: totalMin,
        recentMoods: moods,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load dashboard: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRecentMoods() async {
    try {
      final response =
          await ApiClient.get('/mood', queryParameters: {'limit': 7});
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
    } catch (e) {
      debugPrint('DashboardNotifier._fetchRecentMoods: $e');
    }
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

  void refresh() {
    if (_userId != null) load(_userId!);
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
