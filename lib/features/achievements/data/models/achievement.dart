class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category;
  final AchievementCriteria criteria;
  final int points;
  final String tier;
  final bool isHidden;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.criteria,
    required this.points,
    required this.tier,
    this.isHidden = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        icon: json['icon'] ?? '🏆',
        category: json['category'] ?? '',
        criteria: AchievementCriteria.fromJson(json['criteria'] ?? {}),
        points: json['points'] ?? 0,
        tier: json['tier'] ?? 'bronze',
        isHidden: json['isHidden'] ?? false,
      );
}

class AchievementCriteria {
  final String type;
  final int threshold;
  final String scope;

  const AchievementCriteria(
      {required this.type, required this.threshold, required this.scope});

  factory AchievementCriteria.fromJson(Map<String, dynamic> json) =>
      AchievementCriteria(
        type: json['type'] ?? 'count',
        threshold: json['threshold'] ?? 1,
        scope: json['scope'] ?? 'lifetime',
      );
}

class UserAchievement {
  final String userId;
  final String achievementId;
  final DateTime? unlockedAt;
  final double progress;
  final bool isCompleted;
  final int currentValue;

  const UserAchievement({
    required this.userId,
    required this.achievementId,
    this.unlockedAt,
    this.progress = 0.0,
    this.isCompleted = false,
    this.currentValue = 0,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      UserAchievement(
        userId: json['userId'] ?? '',
        achievementId: json['achievementId'] ?? '',
        unlockedAt: (json['unlockedAt'] as dynamic)?.toDate(),
        progress: (json['progress'] ?? 0.0).toDouble(),
        isCompleted: json['isCompleted'] ?? false,
        currentValue: json['currentValue'] ?? 0,
      );

  factory UserAchievement.create(String userId, String achievementId) =>
      UserAchievement(
        userId: userId,
        achievementId: achievementId,
      );
}
