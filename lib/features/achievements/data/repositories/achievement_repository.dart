import 'package:mental_mantra/core/network/api_client.dart';
import '../models/achievement.dart';

class AchievementRepository {
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final response = await ApiClient.get('/achievements');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List<dynamic>).map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    try {
      final response = await ApiClient.get('/achievements/user/$userId');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List<dynamic>).map((e) => UserAchievement.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      await ApiClient.post('/achievements/unlock', data: {
        'userId': userId,
        'achievementId': achievementId,
      });
    } catch (_) {}
  }

  Future<void> updateProgress(String userId, String achievementId, {required double progress, required int currentValue}) async {
    try {
      await ApiClient.put('/achievements/progress/$userId/$achievementId', data: {
        'progress': progress,
        'currentValue': currentValue,
      });
    } catch (_) {}
  }

  Future<Map<String, dynamic>> getStreak(String userId) async {
    try {
      final response = await ApiClient.get('/achievements/streak/$userId');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'currentDays': 0, 'longestDays': 0, 'lastActivityDate': null};
  }
}
