import 'package:mental_mantra/core/network/api_client.dart';
import '../models/recommendation.dart';

class OutcomeRepository {
  Future<void> saveOutcome(RecommendationOutcome outcome) async {
    try {
      await ApiClient.post('/recommendations/outcomes', data: outcome.toJson());
    } catch (_) {}
  }

  Future<void> recordAccepted({
    required String recommendationId,
    required String userId,
    required String action,
    required String domain,
    required Map<String, double> beforeMetrics,
  }) async {
    final outcome = RecommendationOutcome(
      recommendationId: recommendationId,
      userId: userId,
      action: action,
      domain: domain,
      accepted: true,
      completed: false,
      acceptedAt: DateTime.now(),
      beforeMetrics: beforeMetrics,
    );
    await saveOutcome(outcome);
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
    final outcome = RecommendationOutcome(
      recommendationId: recommendationId,
      userId: userId,
      action: action,
      domain: domain,
      accepted: true,
      completed: true,
      acceptedAt: DateTime.now().subtract(Duration(seconds: timeTakenSeconds)),
      completedAt: DateTime.now(),
      timeTakenSeconds: timeTakenSeconds,
      beforeMetrics: beforeMetrics,
      afterMetrics: afterMetrics,
    );
    await saveOutcome(outcome);
  }

  Future<void> recordSkipped({
    required String recommendationId,
    required String userId,
    required String action,
    required String domain,
  }) async {
    final outcome = RecommendationOutcome(
      recommendationId: recommendationId,
      userId: userId,
      action: action,
      domain: domain,
      accepted: false,
      completed: false,
    );
    await saveOutcome(outcome);
  }

  Future<RecommendationOutcome?> getOutcome(String recommendationId) async {
    try {
      final response = await ApiClient.get('/recommendations/outcomes/$recommendationId');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return RecommendationOutcome.fromJson(data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<List<RecommendationOutcome>> getOutcomesByUser(String userId, {int limit = 50}) async {
    try {
      final response = await ApiClient.get('/recommendations/outcomes/user/$userId', queryParameters: {'limit': limit});
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List<dynamic>).map((e) => RecommendationOutcome.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<RecommendationOutcome>> getOutcomesByAction(String userId, String action, {int limit = 50}) async {
    try {
      final response = await ApiClient.get('/recommendations/outcomes/user/$userId/action/$action', queryParameters: {'limit': limit});
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List<dynamic>).map((e) => RecommendationOutcome.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }
}
