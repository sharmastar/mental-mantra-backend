import 'evidence.dart';
import 'recommendation.dart';

enum InsightType {
  prediction,
  recommendation,
  achievement,
  warning,
  trend,
  celebration,
  reminder,
}

class AIInsight {
  final String id;
  final InsightType type;
  final String title;
  final String message;
  final double confidence;
  final List<Evidence> evidence;
  final Recommendation? recommendation;
  final double expectedImpact;
  final DateTime? expiresAt;
  final String domain;
  final String category;

  const AIInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.confidence = 0.0,
    this.evidence = const [],
    this.recommendation,
    this.expectedImpact = 0.0,
    this.expiresAt,
    this.domain = '',
    this.category = '',
  });

  bool get actionable => recommendation != null;

  bool get expired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  String get confidenceLabel {
    if (confidence >= 0.8) return 'High confidence';
    if (confidence >= 0.5) return 'Moderate confidence';
    return 'Low confidence';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'message': message,
        'confidence': confidence,
        'evidence': evidence.map((e) => e.toJson()).toList(),
        'recommendation': recommendation?.toJson(),
        'expectedImpact': expectedImpact,
        'expiresAt': expiresAt?.toIso8601String(),
        'domain': domain,
        'category': category,
      };

  factory AIInsight.fromJson(Map<String, dynamic> json) => AIInsight(
        id: json['id'] as String? ?? '',
        type: InsightType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => InsightType.trend,
        ),
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        evidence: (json['evidence'] as List<dynamic>?)
                ?.map((e) => Evidence.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        recommendation: json['recommendation'] != null
            ? Recommendation.fromJson(
                json['recommendation'] as Map<String, dynamic>)
            : null,
        expectedImpact: (json['expectedImpact'] as num?)?.toDouble() ?? 0.0,
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
        domain: json['domain'] as String? ?? '',
        category: json['category'] as String? ?? '',
      );
}

class AIInsightCollection {
  final List<AIInsight> insights;
  final DateTime generatedAt;
  final int totalCount;

  const AIInsightCollection({
    required this.insights,
    required this.generatedAt,
    required this.totalCount,
  });

  List<AIInsight> byType(InsightType type) =>
      insights.where((i) => i.type == type).toList();

  List<AIInsight> get predictions => byType(InsightType.prediction);
  List<AIInsight> get recommendations => byType(InsightType.recommendation);
  List<AIInsight> get achievements => byType(InsightType.achievement);
  List<AIInsight> get warnings => byType(InsightType.warning);
  List<AIInsight> get trends => byType(InsightType.trend);
  List<AIInsight> get celebrations => byType(InsightType.celebration);
  List<AIInsight> get reminders => byType(InsightType.reminder);
  List<AIInsight> get actionable =>
      insights.where((i) => i.actionable).toList();
  List<AIInsight> get all => insights;

  List<AIInsight> get sortedByConfidence =>
      List.from(insights)..sort((a, b) => b.confidence.compareTo(a.confidence));
}
