class Recommendation {
  final String id;
  final String action;
  final String detail;
  final String route;
  final List<ExpectedImpact> expectedImpacts;
  final String domain;

  const Recommendation({
    required this.id,
    required this.action,
    required this.detail,
    required this.route,
    required this.expectedImpacts,
    required this.domain,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'detail': detail,
    'route': route,
    'expectedImpacts': expectedImpacts.map((e) => e.toJson()).toList(),
    'domain': domain,
  };

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
    id: json['id'] as String? ?? '',
    action: json['action'] as String? ?? '',
    detail: json['detail'] as String? ?? '',
    route: json['route'] as String? ?? '',
    expectedImpacts: (json['expectedImpacts'] as List<dynamic>?)
        ?.map((e) => ExpectedImpact.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    domain: json['domain'] as String? ?? '',
  );
}

class ExpectedImpact {
  final String metric;
  final double change;
  final String direction;
  final String description;

  const ExpectedImpact({
    required this.metric,
    required this.change,
    required this.direction,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'metric': metric,
    'change': change,
    'direction': direction,
    'description': description,
  };

  factory ExpectedImpact.fromJson(Map<String, dynamic> json) => ExpectedImpact(
    metric: json['metric'] as String? ?? '',
    change: (json['change'] as num?)?.toDouble() ?? 0.0,
    direction: json['direction'] as String? ?? 'improve',
    description: json['description'] as String? ?? '',
  );
}

class RecommendationOutcome {
  final String recommendationId;
  final String userId;
  final String action;
  final String domain;
  final bool accepted;
  final bool completed;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final int timeTakenSeconds;
  final Map<String, double> beforeMetrics;
  final Map<String, double> afterMetrics;

  const RecommendationOutcome({
    required this.recommendationId,
    required this.userId,
    required this.action,
    required this.domain,
    required this.accepted,
    required this.completed,
    this.acceptedAt,
    this.completedAt,
    this.timeTakenSeconds = 0,
    this.beforeMetrics = const {},
    this.afterMetrics = const {},
  });

  bool get isAccepted => accepted;
  bool get isCompleted => completed;

  Map<String, dynamic> toJson() => {
    'recommendationId': recommendationId,
    'userId': userId,
    'action': action,
    'domain': domain,
    'accepted': accepted,
    'completed': completed,
    'acceptedAt': acceptedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'timeTakenSeconds': timeTakenSeconds,
    'beforeMetrics': beforeMetrics,
    'afterMetrics': afterMetrics,
  };

  factory RecommendationOutcome.fromJson(Map<String, dynamic> json) => RecommendationOutcome(
    recommendationId: json['recommendationId'] as String? ?? '',
    userId: json['userId'] as String? ?? '',
    action: json['action'] as String? ?? '',
    domain: json['domain'] as String? ?? '',
    accepted: json['accepted'] as bool? ?? false,
    completed: json['completed'] as bool? ?? false,
    acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt'] as String) : null,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    timeTakenSeconds: (json['timeTakenSeconds'] as num?)?.toInt() ?? 0,
    beforeMetrics: (json['beforeMetrics'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
    afterMetrics: (json['afterMetrics'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
  );

  bool get isSuccess {
    if (!completed || afterMetrics.isEmpty || beforeMetrics.isEmpty) return false;
    bool improved = false;
    for (final key in afterMetrics.keys) {
      final before = beforeMetrics[key] ?? 0;
      final after = afterMetrics[key] ?? 0;
      if (after > before) improved = true;
    }
    return improved;
  }
}

class RecommendationHistory {
  final String domain;
  final int totalRecommended;
  final int accepted;
  final int completed;
  final int improved;
  final double successRate;

  const RecommendationHistory({
    required this.domain,
    required this.totalRecommended,
    required this.accepted,
    required this.completed,
    required this.improved,
    required this.successRate,
  });

  factory RecommendationHistory.fromOutcomes(String domain, List<RecommendationOutcome> outcomes) {
    final total = outcomes.length;
    final accepted = outcomes.where((o) => o.accepted).length;
    final completed = outcomes.where((o) => o.completed).length;
    final improved = outcomes.where((o) => o.isSuccess).length;
    return RecommendationHistory(
      domain: domain,
      totalRecommended: total,
      accepted: accepted,
      completed: completed,
      improved: improved,
      successRate: completed > 0 ? improved / completed : 0,
    );
  }
}
