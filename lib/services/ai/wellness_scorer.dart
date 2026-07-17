import 'package:mental_mantra/core/domain/entities/assessment_response.dart';

class WellnessScorer {
  const WellnessScorer();

  Map<String, double> calculateFromResponses(
      List<AssessmentResponse> responses) {
    final answers = <String, dynamic>{};
    for (final r in responses) {
      answers[r.questionId] = r.answer;
    }
    final stressScore = _computeStressScore(answers);
    final anxietyScore = _computeAnxietyScore(answers);
    final sleepScore = _computeSleepScore(answers);
    final moodScore = _computeMoodScore(answers);
    final energyScore = _computeEnergyScore(answers);
    final motivationScore = _computeMotivationScore(answers);
    final resilienceScore = _computeResilienceScore(answers);
    final overallScore = ((stressScore +
                anxietyScore +
                sleepScore +
                moodScore +
                energyScore +
                motivationScore +
                resilienceScore) /
            7)
        .roundToDouble();

    return {
      'overallScore': overallScore,
      'stressScore': stressScore,
      'anxietyScore': anxietyScore,
      'sleepScore': sleepScore,
      'moodScore': moodScore,
      'energyScore': energyScore,
      'motivationScore': motivationScore,
      'resilienceScore': resilienceScore,
    };
  }

  double _computeStressScore(Map<String, dynamic> a) {
    double score = 50;
    if (a['stress_level'] is int) {
      final level = a['stress_level'] as int;
      score = ((10 - level) / 9) * 100;
    }
    if (a['feelings'] is List) {
      final feelings = List<String>.from(a['feelings']);
      if (feelings.contains('Overwhelmed')) score -= 15;
      if (feelings.contains('Stressed')) score -= 10;
      if (feelings.contains('Peaceful')) score += 10;
    }
    return score.clamp(0, 100).roundToDouble();
  }

  double _computeAnxietyScore(Map<String, dynamic> a) {
    double score = 50;
    if (a['feelings'] is List) {
      final feelings = List<String>.from(a['feelings']);
      if (feelings.contains('Anxious')) score -= 20;
      if (feelings.contains('Peaceful')) score += 15;
    }
    if (a['sleep_quality'] is String) {
      if (a['sleep_quality'] == "I rarely sleep well") score -= 15;
      if (a['sleep_quality'] == "I sleep well most nights") score += 10;
    }
    return score.clamp(0, 100).roundToDouble();
  }

  double _computeSleepScore(Map<String, dynamic> a) {
    double score = 50;
    if (a['sleep_quality'] is String) {
      switch (a['sleep_quality'] as String) {
        case "I sleep well most nights":
          score = 80;
        case "I sometimes struggle":
          score = 55;
        case "I often have trouble sleeping":
          score = 35;
        case "I rarely sleep well":
          score = 20;
        case "I have a diagnosed sleep condition":
          score = 25;
      }
    }
    return score.clamp(0, 100).roundToDouble();
  }

  double _computeMoodScore(Map<String, dynamic> a) {
    double score = 50;
    if (a['feelings'] is List) {
      final feelings = List<String>.from(a['feelings']);
      if (feelings.contains('Sad')) score -= 15;
      if (feelings.contains('Hopeful')) score += 15;
      if (feelings.contains('Peaceful')) score += 10;
      if (feelings.contains('Energized')) score += 15;
      if (feelings.contains('Tired')) score -= 5;
      if (feelings.contains('Angry')) score -= 10;
    }
    if (a['hopefulness'] is int) {
      score = (score + ((a['hopefulness'] as int) / 10) * 100) / 2;
    }
    return score.clamp(0, 100).roundToDouble();
  }

  double _computeEnergyScore(Map<String, dynamic> a) {
    double score = 50;
    if (a['energy_level'] is int) {
      score = ((a['energy_level'] as int) / 10) * 100;
    }
    if (a['sleep_quality'] is String) {
      if (a['sleep_quality'] == "I rarely sleep well") score -= 15;
    }
    return score.clamp(0, 100).roundToDouble();
  }

  double _computeMotivationScore(Map<String, dynamic> a) {
    double score = 50;
    if (a['hopefulness'] is int) {
      score = ((a['hopefulness'] as int) / 10) * 100;
    }
    if (a['improvement_areas'] is List) {
      final areas = List<String>.from(a['improvement_areas']);
      if (areas.length > 3) score += 10;
      if (areas.isEmpty) score -= 10;
    }
    if (a['exercise_frequency'] is String) {
      if (a['exercise_frequency'] == 'Daily') score += 15;
      if (a['exercise_frequency'] == 'Never') score -= 10;
    }
    return score.clamp(0, 100).roundToDouble();
  }

  double _computeResilienceScore(Map<String, dynamic> a) {
    double score = 50;
    if (a['social_support'] is String) {
      switch (a['social_support'] as String) {
        case "I have a strong support system":
          score = 75;
        case "I have some support but wish I had more":
          score = 50;
        case "I feel mostly alone":
          score = 30;
        case "I don't have anyone I can count on":
          score = 20;
        case "Prefer not to say":
          score = 45;
      }
    }
    if (a['coping_mechanisms'] is List) {
      final coping = List<String>.from(a['coping_mechanisms']);
      if (coping.length >= 3) score += 10;
      if (coping.contains('Nothing seems to help')) score -= 20;
    }
    if (a['exercise_frequency'] is String) {
      if (a['exercise_frequency'] == 'Daily' ||
          a['exercise_frequency'] == '3-4 times a week') {
        score += 10;
      }
    }
    return score.clamp(0, 100).roundToDouble();
  }

  static String interpretScore(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Needs Attention';
    return 'Requires Support';
  }

  static String riskLevelFromScores(Map<String, double> scores) {
    if (scores['overallScore']! < 25) return 'critical';
    if (scores['overallScore']! < 40) return 'high';
    if (scores['overallScore']! < 55) return 'moderate';
    return 'low';
  }

  static List<String> identifyPrimaryConcerns(Map<String, double> scores) {
    final concerns = <String>[];
    if ((scores['stressScore'] ?? 50) < 35) concerns.add('Stress Management');
    if ((scores['anxietyScore'] ?? 50) < 35) concerns.add('Anxiety');
    if ((scores['sleepScore'] ?? 50) < 35) concerns.add('Sleep Quality');
    if ((scores['moodScore'] ?? 50) < 35) concerns.add('Mood');
    if ((scores['energyScore'] ?? 50) < 35) concerns.add('Energy Levels');
    if ((scores['motivationScore'] ?? 50) < 35) concerns.add('Motivation');
    if ((scores['resilienceScore'] ?? 50) < 35) concerns.add('Resilience');
    return concerns;
  }
}
