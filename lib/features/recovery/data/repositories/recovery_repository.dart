import 'package:mental_mantra/core/network/api_client.dart';
import '../models/recovery_models.dart';

class RecoveryRepository {
  Future<void> logUrge(UrgeLog urge) async {
    try {
      await ApiClient.post('/recovery/urges', data: urge.toJson());
    } catch (_) {}
  }

  Future<List<UrgeLog>> getUrges({int limit = 20}) async {
    try {
      final response = await ApiClient.get('/recovery/urges', queryParameters: {'limit': limit});
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List<dynamic>)
            .map((e) => UrgeLog.fromJson({...e as Map<String, dynamic>, 'id': e['id'] ?? ''}))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String?> saveDetoxSession(DetoxSession session) async {
    try {
      final response = await ApiClient.post('/recovery/sessions', data: session.toJson());
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return data['data']['id'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateDetoxSession(String id, DetoxSession session) async {
    try {
      await ApiClient.put('/recovery/sessions/$id', data: session.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<DetoxSession>> getDetoxSessions({int limit = 20}) async {
    try {
      final response = await ApiClient.get('/recovery/sessions', queryParameters: {'limit': limit});
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List<dynamic>)
            .map((e) => DetoxSession.fromJson({...e as Map<String, dynamic>, 'id': e['id'] ?? ''}))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> setRecoveryGoal(RecoveryGoal goal) async {
    try {
      await ApiClient.post('/recovery/goals', data: goal.toJson());
    } catch (_) {}
  }

  Future<RecoveryGoal?> getActiveGoal() async {
    try {
      final response = await ApiClient.get('/recovery/goals');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return RecoveryGoal.fromJson({...(data['data'] as Map<String, dynamic>), 'id': data['data']['id'] ?? ''});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<RecoveryStats> getStats() async {
    try {
      final response = await ApiClient.get('/recovery/stats');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final d = data['data'] as Map<String, dynamic>;
        return RecoveryStats(
          currentStreak: (d['currentStreak'] as num?)?.toInt() ?? 0,
          bestStreak: (d['bestStreak'] as num?)?.toInt() ?? 0,
          totalUrgesLogged: (d['totalUrgesLogged'] as num?)?.toInt() ?? 0,
          urgesResisted: (d['urgesResisted'] as num?)?.toInt() ?? 0,
          totalDetoxMinutes: (d['totalDetoxMinutes'] as num?)?.toInt() ?? 0,
          totalDetoxSessions: (d['totalDetoxSessions'] as num?)?.toInt() ?? 0,
          recentUrges: (d['recentUrges'] as List<dynamic>? ?? []).map((e) => UrgeLog.fromJson(e as Map<String, dynamic>)).toList(),
          recentSessions: (d['recentSessions'] as List<dynamic>? ?? []).map((e) => DetoxSession.fromJson(e as Map<String, dynamic>)).toList(),
          activeGoal: d['activeGoal'] != null ? RecoveryGoal.fromJson(d['activeGoal'] as Map<String, dynamic>) : null,
        );
      }
    } catch (_) {}
    return const RecoveryStats();
  }
}
