class HabitRecommendation {
  final String title;
  final String description;
  final HabitDomain domain;
  final HabitDifficulty difficulty;
  final int durationMinutes;
  final int estimatedBenefit;
  final String aiRationale;
  final String category;

  const HabitRecommendation({
    required this.title,
    required this.description,
    required this.domain,
    required this.difficulty,
    required this.durationMinutes,
    required this.estimatedBenefit,
    required this.aiRationale,
    required this.category,
  });

  HabitRecommendation copyWith({int? streakDays, bool? isActive}) {
    return HabitRecommendation(
      title: title,
      description: description,
      domain: domain,
      difficulty: difficulty,
      durationMinutes: durationMinutes,
      estimatedBenefit: estimatedBenefit,
      aiRationale: aiRationale,
      category: category,
    );
  }
}

enum HabitDomain {
  stress,
  sleep,
  motivation,
  anxiety,
  mindfulness,
  energy,
  social,
  recovery,
}

enum HabitDifficulty { easy, medium, hard }

class HabitTemplate {
  final String title;
  final String description;
  final HabitDomain domain;
  final HabitDifficulty difficulty;
  final int durationMinutes;
  final int estimatedBenefit;

  const HabitTemplate({
    required this.title,
    required this.description,
    required this.domain,
    required this.difficulty,
    required this.durationMinutes,
    required this.estimatedBenefit,
  });
}
