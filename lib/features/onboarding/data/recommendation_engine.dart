import 'models/assessment_question.dart';
import '../../meditation/data/meditation_catalog.dart';
import '../../music/data/music_catalog.dart';

class WellnessDomains {
  static const stressBurnout = 'Stress & Burnout';
  static const anxietyOverthinking = 'Anxiety & Overthinking';
  static const lowMood = 'Low Mood';
  static const sleepWellness = 'Sleep Wellness';
  static const relationshipWellness = 'Relationship Wellness';
  static const habitRecovery = 'Habit Recovery';
  static const confidenceBuilding = 'Confidence Building';
  static const socialConnection = 'Social Connection';
  static const mindfulnessPeace = 'Mindfulness & Inner Peace';

  static const all = [
    stressBurnout,
    anxietyOverthinking,
    lowMood,
    sleepWellness,
    relationshipWellness,
    habitRecovery,
    confidenceBuilding,
    socialConnection,
    mindfulnessPeace,
  ];
}

class WellnessResult {
  final int wellnessScore;
  final String primaryFocus;
  final String secondaryFocus;
  final Map<String, double> domainScores;
  final String dailyMotivation;
  final String recommendedMeditation;
  final String recommendedMusic;
  final String breathingExercise;
  final String journalPrompt;
  final String habitChallenge;
  final String aiSuggestion;
  final String dailyWellnessPlan;
  final List<String> affirmations;
  final bool needsCrisisSupport;
  final String? crisisMessage;
  final Map<String, String> personalityProfile;

  const WellnessResult({
    required this.wellnessScore,
    required this.primaryFocus,
    required this.secondaryFocus,
    required this.domainScores,
    required this.dailyMotivation,
    required this.recommendedMeditation,
    required this.recommendedMusic,
    required this.breathingExercise,
    required this.journalPrompt,
    required this.habitChallenge,
    required this.aiSuggestion,
    required this.dailyWellnessPlan,
    required this.affirmations,
    required this.personalityProfile,
    this.needsCrisisSupport = false,
    this.crisisMessage,
  });

  Map<String, dynamic> toJson() => {
        'wellnessScore': wellnessScore,
        'primaryFocus': primaryFocus,
        'secondaryFocus': secondaryFocus,
        'domainScores': domainScores,
        'dailyMotivation': dailyMotivation,
        'recommendedMeditation': recommendedMeditation,
        'recommendedMusic': recommendedMusic,
        'breathingExercise': breathingExercise,
        'journalPrompt': journalPrompt,
        'habitChallenge': habitChallenge,
        'aiSuggestion': aiSuggestion,
        'dailyWellnessPlan': dailyWellnessPlan,
        'affirmations': affirmations,
        'needsCrisisSupport': needsCrisisSupport,
        'crisisMessage': crisisMessage,
        'personalityProfile': personalityProfile,
      };

  factory WellnessResult.fromJson(Map<String, dynamic> json) => WellnessResult(
        wellnessScore: json['wellnessScore'] as int? ?? 75,
        primaryFocus: json['primaryFocus'] as String? ?? '',
        secondaryFocus: json['secondaryFocus'] as String? ?? '',
        domainScores: Map<String, double>.from(json['domainScores'] ?? {}),
        dailyMotivation: json['dailyMotivation'] as String? ?? '',
        recommendedMeditation: json['recommendedMeditation'] as String? ?? '',
        recommendedMusic: json['recommendedMusic'] as String? ?? '',
        breathingExercise: json['breathingExercise'] as String? ?? '',
        journalPrompt: json['journalPrompt'] as String? ?? '',
        habitChallenge: json['habitChallenge'] as String? ?? '',
        aiSuggestion: json['aiSuggestion'] as String? ?? '',
        dailyWellnessPlan: json['dailyWellnessPlan'] as String? ?? '',
        affirmations:
            (json['affirmations'] as List<dynamic>?)?.cast<String>() ?? [],
        needsCrisisSupport: json['needsCrisisSupport'] as bool? ?? false,
        crisisMessage: json['crisisMessage'] as String?,
        personalityProfile:
            Map<String, String>.from(json['personalityProfile'] ?? {}),
      );
}

class RecommendationEngine {
  Map<String, double> calculateDomainScores(AssessmentAnswers answers) {
    final scores = <String, double>{
      WellnessDomains.stressBurnout: 0,
      WellnessDomains.anxietyOverthinking: 0,
      WellnessDomains.lowMood: 0,
      WellnessDomains.sleepWellness: 0,
      WellnessDomains.relationshipWellness: 0,
      WellnessDomains.habitRecovery: 0,
      WellnessDomains.confidenceBuilding: 0,
      WellnessDomains.socialConnection: 0,
      WellnessDomains.mindfulnessPeace: 0,
    };

    // Helper to convert frequency scale to numeric score
    double freqScore(String? val) {
      switch (val) {
        case 'Never':
          return 0;
        case 'Rarely':
          return 1;
        case 'Sometimes':
          return 2;
        case 'Often':
          return 3;
        case 'Almost Always':
          return 4;
        default:
          return 0;
      }
    }

    final reasons = answers.getMulti('reasons_joined');
    final affectedAreas = answers.getMulti('affected_areas');
    final overwhelm = freqScore(answers.getSingle('emotional_overwhelm'));
    final worry = freqScore(answers.getSingle('excessive_worry'));
    final lonely = freqScore(answers.getSingle('feeling_lonely'));
    final sleepHours = answers.getSingle('sleep_hours');
    final sleepQuality = answers.getSingle('sleep_quality');
    final activity = answers.getSingle('physical_activity');
    final support = answers.getSingle('emotional_support');
    final habits = answers.getMulti('habit_struggles');
    final coping = answers.getMulti('coping_style');
    final goals = answers.getMulti('improvement_goals');
    final duration = answers.getSingle('challenge_duration');

    // Duration multiplier (longer = more severe)
    double durationMult = 1.0;
    if (duration == 'A few months') durationMult = 1.3;
    if (duration == 'More than a year') durationMult = 1.5;

    // ── Stress & Burnout ────────────────────────────────────────
    if (reasons.contains('Stress or pressure')) {
      scores[WellnessDomains.stressBurnout] =
          scores[WellnessDomains.stressBurnout]! + 20;
    }
    if (reasons.contains('Work stress')) {
      scores[WellnessDomains.stressBurnout] =
          scores[WellnessDomains.stressBurnout]! + 15;
    }
    if (reasons.contains('Academic stress')) {
      scores[WellnessDomains.stressBurnout] =
          scores[WellnessDomains.stressBurnout]! + 15;
    }
    if (reasons.contains('Emotional burnout')) {
      scores[WellnessDomains.stressBurnout] =
          scores[WellnessDomains.stressBurnout]! + 20;
    }
    scores[WellnessDomains.stressBurnout] =
        scores[WellnessDomains.stressBurnout]! + overwhelm * 6;
    if (affectedAreas.contains('Work performance') ||
        affectedAreas.contains('Studies')) {
      scores[WellnessDomains.stressBurnout] =
          scores[WellnessDomains.stressBurnout]! + 8;
    }
    if (goals.contains('Reduce stress')) {
      scores[WellnessDomains.stressBurnout] =
          scores[WellnessDomains.stressBurnout]! + 5;
    }
    if (activity == 'Mostly inactive') {
      scores[WellnessDomains.stressBurnout] =
          scores[WellnessDomains.stressBurnout]! + 5;
    }

    // ── Anxiety & Overthinking ──────────────────────────────────
    if (reasons.contains('Anxiety or overthinking')) {
      scores[WellnessDomains.anxietyOverthinking] =
          scores[WellnessDomains.anxietyOverthinking]! + 20;
    }
    scores[WellnessDomains.anxietyOverthinking] =
        scores[WellnessDomains.anxietyOverthinking]! + worry * 7;
    scores[WellnessDomains.anxietyOverthinking] =
        scores[WellnessDomains.anxietyOverthinking]! + overwhelm * 3;
    if (sleepQuality == 'Poor' || sleepQuality == 'Very poor') {
      scores[WellnessDomains.anxietyOverthinking] =
          scores[WellnessDomains.anxietyOverthinking]! + 5;
    }
    if (goals.contains('Reduce anxiety')) {
      scores[WellnessDomains.anxietyOverthinking] =
          scores[WellnessDomains.anxietyOverthinking]! + 5;
    }
    if (coping.contains('Stay alone') ||
        coping.contains('Scroll social media')) {
      scores[WellnessDomains.anxietyOverthinking] =
          scores[WellnessDomains.anxietyOverthinking]! + 3;
    }

    // ── Low Mood ────────────────────────────────────────────────
    if (reasons.contains('Feeling emotionally low')) {
      scores[WellnessDomains.lowMood] = scores[WellnessDomains.lowMood]! + 20;
    }
    if (reasons.contains('Lack of motivation')) {
      scores[WellnessDomains.lowMood] = scores[WellnessDomains.lowMood]! + 15;
    }
    scores[WellnessDomains.lowMood] =
        scores[WellnessDomains.lowMood]! + lonely * 5;
    scores[WellnessDomains.lowMood] =
        scores[WellnessDomains.lowMood]! + overwhelm * 3;
    if (coping.contains('Cry')) {
      scores[WellnessDomains.lowMood] = scores[WellnessDomains.lowMood]! + 5;
    }
    if (goals.contains('Emotional balance')) {
      scores[WellnessDomains.lowMood] = scores[WellnessDomains.lowMood]! + 5;
    }
    if (goals.contains('Motivation')) {
      scores[WellnessDomains.lowMood] = scores[WellnessDomains.lowMood]! + 5;
    }
    if (affectedAreas.contains('Motivation/productivity')) {
      scores[WellnessDomains.lowMood] = scores[WellnessDomains.lowMood]! + 8;
    }

    // ── Sleep Wellness ──────────────────────────────────────────
    if (reasons.contains('Sleep problems')) {
      scores[WellnessDomains.sleepWellness] =
          scores[WellnessDomains.sleepWellness]! + 20;
    }
    if (sleepQuality == 'Poor') {
      scores[WellnessDomains.sleepWellness] =
          scores[WellnessDomains.sleepWellness]! + 15;
    }
    if (sleepQuality == 'Very poor') {
      scores[WellnessDomains.sleepWellness] =
          scores[WellnessDomains.sleepWellness]! + 25;
    }
    if (sleepHours == 'Less than 4') {
      scores[WellnessDomains.sleepWellness] =
          scores[WellnessDomains.sleepWellness]! + 20;
    }
    if (sleepHours == '4-5') {
      scores[WellnessDomains.sleepWellness] =
          scores[WellnessDomains.sleepWellness]! + 12;
    }
    if (affectedAreas.contains('Sleep')) {
      scores[WellnessDomains.sleepWellness] =
          scores[WellnessDomains.sleepWellness]! + 10;
    }
    if (goals.contains('Improve sleep')) {
      scores[WellnessDomains.sleepWellness] =
          scores[WellnessDomains.sleepWellness]! + 5;
    }

    // ── Relationship Wellness ───────────────────────────────────
    if (reasons.contains('Relationship difficulties')) {
      scores[WellnessDomains.relationshipWellness] =
          scores[WellnessDomains.relationshipWellness]! + 20;
    }
    if (reasons.contains('Family conflicts')) {
      scores[WellnessDomains.relationshipWellness] =
          scores[WellnessDomains.relationshipWellness]! + 20;
    }
    if (affectedAreas.contains('Relationships') ||
        affectedAreas.contains('Family life')) {
      scores[WellnessDomains.relationshipWellness] =
          scores[WellnessDomains.relationshipWellness]! + 12;
    }
    if (support == 'No') {
      scores[WellnessDomains.relationshipWellness] =
          scores[WellnessDomains.relationshipWellness]! + 10;
    }
    if (goals.contains('Improve relationships')) {
      scores[WellnessDomains.relationshipWellness] =
          scores[WellnessDomains.relationshipWellness]! + 5;
    }

    // ── Habit Recovery ──────────────────────────────────────────
    if (reasons.contains('Addiction or habit control')) {
      scores[WellnessDomains.habitRecovery] =
          scores[WellnessDomains.habitRecovery]! + 20;
    }
    if (habits.isNotEmpty && !habits.contains('None')) {
      scores[WellnessDomains.habitRecovery] =
          scores[WellnessDomains.habitRecovery]! +
              (habits.length * 8).clamp(0, 40).toDouble();
    }
    if (goals.contains('Addiction recovery')) {
      scores[WellnessDomains.habitRecovery] =
          scores[WellnessDomains.habitRecovery]! + 10;
    }
    if (goals.contains('Self-discipline')) {
      scores[WellnessDomains.habitRecovery] =
          scores[WellnessDomains.habitRecovery]! + 5;
    }
    if (goals.contains('Healthier habits')) {
      scores[WellnessDomains.habitRecovery] =
          scores[WellnessDomains.habitRecovery]! + 5;
    }

    // ── Confidence Building ─────────────────────────────────────
    if (reasons.contains('Low confidence/self-esteem')) {
      scores[WellnessDomains.confidenceBuilding] =
          scores[WellnessDomains.confidenceBuilding]! + 25;
    }
    if (affectedAreas.contains('Confidence')) {
      scores[WellnessDomains.confidenceBuilding] =
          scores[WellnessDomains.confidenceBuilding]! + 12;
    }
    if (goals.contains('Build confidence')) {
      scores[WellnessDomains.confidenceBuilding] =
          scores[WellnessDomains.confidenceBuilding]! + 10;
    }
    if (coping.contains('Stay alone')) {
      scores[WellnessDomains.confidenceBuilding] =
          scores[WellnessDomains.confidenceBuilding]! + 5;
    }

    // ── Social Connection ───────────────────────────────────────
    if (reasons.contains('Loneliness')) {
      scores[WellnessDomains.socialConnection] =
          scores[WellnessDomains.socialConnection]! + 20;
    }
    if (support == 'No') {
      scores[WellnessDomains.socialConnection] =
          scores[WellnessDomains.socialConnection]! + 20;
    }
    if (support == 'Sometimes') {
      scores[WellnessDomains.socialConnection] =
          scores[WellnessDomains.socialConnection]! + 10;
    }
    scores[WellnessDomains.socialConnection] =
        scores[WellnessDomains.socialConnection]! + lonely * 5;
    if (coping.contains('Stay alone')) {
      scores[WellnessDomains.socialConnection] =
          scores[WellnessDomains.socialConnection]! + 8;
    }
    if (affectedAreas.contains('Social interactions')) {
      scores[WellnessDomains.socialConnection] =
          scores[WellnessDomains.socialConnection]! + 8;
    }

    // ── Mindfulness & Inner Peace ───────────────────────────────
    if (goals.contains('Inner peace')) {
      scores[WellnessDomains.mindfulnessPeace] =
          scores[WellnessDomains.mindfulnessPeace]! + 15;
    }
    if (goals.contains('Reduce stress') || goals.contains('Reduce anxiety')) {
      scores[WellnessDomains.mindfulnessPeace] =
          scores[WellnessDomains.mindfulnessPeace]! + 5;
    }
    if (worry >= 3) {
      scores[WellnessDomains.mindfulnessPeace] =
          scores[WellnessDomains.mindfulnessPeace]! + 10;
    }
    if (coping.contains('Pray/meditate')) {
      scores[WellnessDomains.mindfulnessPeace] =
          scores[WellnessDomains.mindfulnessPeace]! + 5;
    }
    if (reasons.contains('Just exploring mental wellness')) {
      scores[WellnessDomains.mindfulnessPeace] =
          scores[WellnessDomains.mindfulnessPeace]! + 10;
    }
    if (goals.contains('Overall wellbeing')) {
      scores[WellnessDomains.mindfulnessPeace] =
          scores[WellnessDomains.mindfulnessPeace]! + 5;
    }

    // Apply duration multiplier to all scores
    return scores
        .map((k, v) => MapEntry(k, (v * durationMult).clamp(0.0, 100.0)));
  }

  Map<String, String> generatePersonalityProfile(AssessmentAnswers answers) {
    final profile = <String, String>{};

    // Helper to convert frequency scale to numeric score
    double freqScore(String? val) {
      switch (val) {
        case 'Never':
          return 0;
        case 'Rarely':
          return 1;
        case 'Sometimes':
          return 2;
        case 'Often':
          return 3;
        case 'Almost Always':
          return 4;
        default:
          return 0;
      }
    }

    // 1. Stress Level
    int stressSignals = 0;
    final reasons = answers.getMulti('reasons_joined');
    if (reasons.contains('Stress or pressure') ||
        reasons.contains('Emotional burnout')) {
      stressSignals += 2;
    }
    if (reasons.contains('Work stress') ||
        reasons.contains('Academic stress')) {
      stressSignals += 2;
    }
    final overwhelm = freqScore(answers.getSingle('emotional_overwhelm'));
    if (overwhelm >= 4) stressSignals += 3;
    if (overwhelm >= 3) stressSignals += 2;

    if (stressSignals >= 5) {
      profile['Stress Level'] =
          'Severe (Confidence: 90%) - Experiencing high workload or life pressure resulting in constant overwhelm.';
    } else if (stressSignals >= 2) {
      profile['Stress Level'] =
          'Moderate (Confidence: 80%) - Coping with noticeable triggers, but maintaining balance in most scenarios.';
    } else {
      profile['Stress Level'] =
          'Low (Confidence: 75%) - General daily pressures remain within normal, healthy limits.';
    }

    // 2. Anxiety Tendency
    int anxietySignals = 0;
    if (reasons.contains('Anxiety or overthinking')) anxietySignals += 2;
    final worry = freqScore(answers.getSingle('excessive_worry'));
    if (worry >= 4) anxietySignals += 3;
    if (worry >= 3) anxietySignals += 2;

    if (anxietySignals >= 5) {
      profile['Anxiety Tendency'] =
          'High (Confidence: 90%) - Significant tendency to overthink, worry excessively, and feel anxious.';
    } else if (anxietySignals >= 2) {
      profile['Anxiety Tendency'] =
          'Moderate (Confidence: 80%) - Periodic overthinking patterns that can temporarily cloud focus.';
    } else {
      profile['Anxiety Tendency'] =
          'Low (Confidence: 70%) - Generally calm, mindful mindset with stable daily responses.';
    }

    // 3. Sleep Quality
    final sleepQuality = answers.getSingle('sleep_quality');
    final sleepHours = answers.getSingle('sleep_hours');
    if (sleepQuality == 'Very good' || sleepQuality == 'Good') {
      profile['Sleep Quality'] =
          'Healthy (Confidence: 90%) - Satisfactory rest duration ($sleepHours hours) and quality with stable patterns.';
    } else if (sleepQuality == 'Average') {
      profile['Sleep Quality'] =
          'Average (Confidence: 80%) - Sleeps reasonably ($sleepHours hours) but encounters occasional restlessness.';
    } else {
      profile['Sleep Quality'] =
          'Disrupted (Confidence: 92%) - Fragmented or shallow sleep ($sleepHours hours), impacting daily energy.';
    }

    // 4. Social Connectedness
    final support = answers.getSingle('emotional_support');
    final lonely = freqScore(answers.getSingle('feeling_lonely'));
    if (support == 'Yes' && lonely < 2) {
      profile['Social Connectedness'] =
          'Well-Connected (Confidence: 85%) - Strong support network with consistent emotional connection.';
    } else if (support == 'Sometimes') {
      profile['Social Connectedness'] =
          'Moderately Supported (Confidence: 80%) - Has relationships, but feels cautious or isolated at times.';
    } else {
      profile['Social Connectedness'] =
          'Isolated (Confidence: 90%) - Lacks a trusted support system, indicating a strong need for safe connection.';
    }

    // 5. Habit Risk
    final targetHabits = answers.getMulti('habit_struggles');
    if (targetHabits.contains('None') || targetHabits.isEmpty) {
      profile['Habit Risk'] =
          'Low (Confidence: 90%) - Demonstrates healthy lifestyle control with no troublesome behaviors.';
    } else if (targetHabits.length >= 3) {
      profile['Habit Risk'] =
          'High (Confidence: 88%) - Compulsive patterns detected across multiple areas, impacting daily functioning.';
    } else {
      profile['Habit Risk'] =
          'Moderate (Confidence: 85%) - Working through localized habits (${targetHabits.join(", ")}) that cause concern.';
    }

    // 6. Coping Style
    final cope = answers.getMulti('coping_style');
    String style = 'Action-focused';
    if (cope.contains('Stay alone') ||
        cope.contains('Scroll social media') ||
        cope.contains('Watch content/videos')) {
      style = 'Avoidance & Distraction';
    } else if (cope.contains('Talk to someone') ||
        cope.contains('Pray/meditate')) {
      style = 'Support Seeking / Reflective';
    } else if (cope.contains('Exercise')) {
      style = 'Physical / Active';
    }
    profile['Coping Style'] =
        '$style (Confidence: 80%) - Primary response to stress through $style strategies.';

    // 7. Physical Activity
    final activity = answers.getSingle('physical_activity');
    if (activity == 'Very active') {
      profile['Physical Wellness'] =
          'Strong (Confidence: 90%) - Regular exercise supporting mental and physical health.';
    } else if (activity == 'Moderately active') {
      profile['Physical Wellness'] =
          'Moderate (Confidence: 85%) - Consistent movement with room for improvement.';
    } else {
      profile['Physical Wellness'] =
          'Needs Attention (Confidence: 85%) - Limited physical activity, which may impact mood and energy.';
    }

    // 8. Wellness Goals
    final targetGoals = answers.getMulti('improvement_goals');
    if (targetGoals.isNotEmpty) {
      profile['Wellness Goals'] =
          'Aligned (Confidence: 95%) - Focused on: ${targetGoals.join(", ")}.';
    }

    // 9. Challenge Duration
    final duration = answers.getSingle('challenge_duration');
    if (duration == 'More than a year') {
      profile['Challenge Duration'] =
          'Long-term (Confidence: 95%) - Persistent challenges requiring sustained support and intervention.';
    } else if (duration == 'A few months') {
      profile['Challenge Duration'] =
          'Medium-term (Confidence: 90%) - Developing patterns that benefit from early intervention.';
    } else {
      profile['Challenge Duration'] =
          'Recent (Confidence: 85%) - Emerging challenges with strong potential for quick positive change.';
    }

    return profile;
  }

  WellnessResult generate(AssessmentAnswers answers) {
    final domainScores = calculateDomainScores(answers);
    final sorted = domainScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final primary =
        sorted.isNotEmpty ? sorted[0].key : WellnessDomains.mindfulnessPeace;
    final secondary =
        sorted.length > 1 ? sorted[1].key : WellnessDomains.confidenceBuilding;

    // Cap scores at 100
    final capped = domainScores.map((k, v) => MapEntry(k, v.clamp(0.0, 100.0)));

    // Wellness score: lower domain scores = higher wellness
    final avgDomainScore =
        capped.values.fold(0.0, (a, b) => a + b) / capped.values.length;
    final wellnessScore = (100 - avgDomainScore * 0.8).round().clamp(0, 100);

    final overwhelm = answers.getSingle('emotional_overwhelm');
    final sleepQuality = answers.getSingle('sleep_quality');

    // Check for crisis signals from answer patterns
    final habits = answers.getMulti('habit_struggles');
    final lonely = answers.getSingle('feeling_lonely');
    final needsCrisis =
        (overwhelm == 'Almost Always' && lonely == 'Almost Always') ||
            (habits.length >= 4 && !habits.contains('None'));

    return WellnessResult(
      wellnessScore: wellnessScore,
      primaryFocus: primary,
      secondaryFocus: secondary,
      domainScores: capped,
      dailyMotivation: _getMotivation(primary, wellnessScore),
      recommendedMeditation: _getMeditation(primary, sleepQuality),
      recommendedMusic: _getMusic(primary),
      breathingExercise: _getBreathing(overwhelm),
      journalPrompt: _getJournalPrompt(primary),
      habitChallenge: _getHabitChallenge(primary),
      aiSuggestion: _getAiSuggestion(primary),
      dailyWellnessPlan: _generatePlan(primary, wellnessScore),
      affirmations: _getAffirmations(primary),
      personalityProfile: generatePersonalityProfile(answers),
      needsCrisisSupport: needsCrisis,
      crisisMessage: needsCrisis ? _getCrisisMessage() : null,
    );
  }

  String _getMotivation(String domain, int score) {
    final messages = {
      WellnessDomains.stressBurnout:
          'Feeling overwhelmed is a clear signal that your nervous system is overloaded from carrying so much. Taking an intentional pause isn\'t slacking—it is a critical tool to restore your brain\'s focus. Today, give yourself permission to take brief 2-minute breathers; your productivity will actually benefit from it. 💚',
      WellnessDomains.anxietyOverthinking:
          'Anxiety is simply your mind\'s hypervigilant way of trying to protect you from uncertainty. While this warning system is active, you don\'t have to follow every scenario it creates. Focus your energy by dividing things into what you can control right now vs. what you cannot, and anchor yourself in this present step. 💚',
      WellnessDomains.lowMood:
          'Experiencing a low mood is a natural human season, and it is okay to feel heavy today. Setbacks are transient, and taking even a micro-action helps re-engage your brain\'s dopamine. Try getting just 5 minutes of direct sunlight or a short walk to gently shift your state—every small effort counts. 💚',
      WellnessDomains.sleepWellness:
          'Rest is not a luxury—it is a biological necessity. Tonight, give yourself the gift of deep, peaceful sleep by keeping screens away for 30 minutes before bed, allowing your brain\'s sleep hormones to release naturally. 💚',
      WellnessDomains.relationshipWellness:
          'Healthy relationships start with a healthy relationship with yourself. Nurturing your inner boundary first allows you to connect with others from a place of emotional clarity and strength. 💚',
      WellnessDomains.habitRecovery:
          'Urges are natural dopamine responses triggered by stress, not a reflection of your willpower. As you sit through a craving without acting, the old neural pathways gradually weaken and fade. Next time an urge hits, try delaying it for exactly 10 minutes; you are fully capable of riding this wave. 💚',
      WellnessDomains.confidenceBuilding:
          'Self-doubt is just a pattern of protective thoughts, not a reflection of your actual ability. Your worth is inherent and does not depend on your daily performance. Try listing three small achievements today to celebrate your progress. 💚',
      WellnessDomains.socialConnection:
          'Social anxiety or isolation can make reaching out feel risky, but connection is a powerful healer for our nervous system. Reaching out isn\'t a weakness; try sending just one low-pressure message to a friend today. 💚',
      WellnessDomains.mindfulnessPeace:
          'Mindfulness is a practical practice to reset an overstimulated mind. Many people find chanting or sound practices emotionally grounding because rhythmic focus physically calms the vagus nerve. Allow yourself to just breathe and exist for 3 minutes today. 💚',
    };
    return messages[domain] ??
        'Every day is a fresh opportunity to grow and heal. Focus on taking just one small step at a time. 💚';
  }

  String _getMeditation(String domain, String? sleepQuality) {
    String catId = 'mindfulness';
    if (domain == WellnessDomains.sleepWellness) {
      catId = 'sleep';
    } else if (domain == WellnessDomains.stressBurnout) {
      catId = 'stress';
    } else if (domain == WellnessDomains.anxietyOverthinking) {
      catId = 'anxiety';
    } else if (domain == WellnessDomains.lowMood) {
      catId = 'depression';
    } else if (domain == WellnessDomains.confidenceBuilding) {
      catId = 'confidence';
    } else if (domain == WellnessDomains.mindfulnessPeace) {
      catId = 'mindfulness';
    } else if (domain == WellnessDomains.habitRecovery) {
      catId = 'healing';
    } else if (domain == WellnessDomains.relationshipWellness) {
      catId = 'self_love';
    }

    final matching = MeditationCatalog.allSessions
        .where((s) => s.id.startsWith(catId.substring(0, 3)))
        .toList();
    final title =
        matching.isNotEmpty ? matching.first.title : 'Guided Calm Meditation';
    return '🧘 $title — Custom session selected for your profile.';
  }

  String _getMusic(String domain) {
    String categoryName = 'Calming Melodies';
    if (domain == WellnessDomains.sleepWellness) {
      categoryName = 'Sleep Noise';
    } else if (domain == WellnessDomains.stressBurnout) {
      categoryName = 'Solfeggio Frequencies';
    } else if (domain == WellnessDomains.anxietyOverthinking) {
      categoryName = 'Binaural Beats';
    }

    final matching = MusicCatalog.allTracks
        .where((t) => t.category == categoryName)
        .toList();
    final title =
        matching.isNotEmpty ? matching.first.title : 'Relaxation Music';
    return '🎵 $title — Solfeggio frequency to quiet racing thoughts.';
  }

  String _getBreathing(String? overwhelmed) {
    if (overwhelmed == 'often' || overwhelmed == 'almost_always') {
      return '🌬️ 4-7-8 Breathing Technique:\n1. Inhale quietly through your nose for 4 seconds.\n2. Hold your breath for a count of 7 seconds.\n3. Exhale completely through your mouth making a whoosh sound for 8 seconds.\n4. Repeat this cycle 4 times to physically trigger your parasympathetic nervous system for instant calm.';
    }
    return '🌬️ Box Breathing Technique:\n1. Inhale through your nose for 4 seconds.\n2. Hold your breath for 4 seconds.\n3. Exhale slowly through your mouth for 4 seconds.\n4. Hold your lungs empty for 4 seconds.\n5. Repeat this cycle 4-5 times to anchor your mind and restore focus.';
  }

  String _getJournalPrompt(String domain) {
    final prompts = {
      WellnessDomains.stressBurnout:
          'What is one thing I can let go of right now?',
      WellnessDomains.anxietyOverthinking:
          'What is actually true in this moment, vs what is my mind creating?',
      WellnessDomains.lowMood:
          'What is one small thing that brought me joy today?',
      WellnessDomains.sleepWellness:
          'What am I grateful for about today? What can I release before sleep?',
      WellnessDomains.relationshipWellness:
          'How can I be a better friend to myself today?',
      WellnessDomains.habitRecovery:
          'What triggered my urge today, and what could I do differently next time?',
      WellnessDomains.confidenceBuilding:
          'What is one thing I did today that my future self would be proud of?',
      WellnessDomains.socialConnection:
          'Who in my life makes me feel seen and understood?',
      WellnessDomains.mindfulnessPeace:
          'What does inner peace mean to me, and how can I invite more of it today?',
    };
    return prompts[domain] ??
        'How am I feeling right now, and what do I need most in this moment?';
  }

  String _getHabitChallenge(String domain) {
    final challenges = {
      WellnessDomains.stressBurnout:
          'Take 3 intentional "pause" moments today — just 60 seconds of deep breathing.',
      WellnessDomains.anxietyOverthinking:
          'Whenever you catch yourself overthinking, name 3 things you can see, hear, and feel.',
      WellnessDomains.lowMood:
          'Do one small act of kindness for yourself today — even if it\'s just drinking water mindfully.',
      WellnessDomains.sleepWellness:
          'No screens 30 minutes before bed tonight. Read or journal instead.',
      WellnessDomains.relationshipWellness:
          'Send a thoughtful message to someone you care about.',
      WellnessDomains.habitRecovery:
          'Replace one urge episode with a 5-minute walk or cold water drink.',
      WellnessDomains.confidenceBuilding:
          'Write down 3 things you like about yourself and read them aloud.',
      WellnessDomains.socialConnection:
          'Reach out to one person today — just to say hello or check in.',
      WellnessDomains.mindfulnessPeace:
          'Spend 5 minutes in complete silence, focusing only on your breath.',
    };
    return challenges[domain] ??
        'Take 5 minutes today for yourself — no phone, no distractions.';
  }

  String _getAiSuggestion(String domain) {
    final suggestions = {
      WellnessDomains.stressBurnout:
          '💬 Talk to your AI Companion about what\'s overwhelming you right now. Sometimes just saying it out loud helps.',
      WellnessDomains.anxietyOverthinking:
          '💬 Your AI Companion can guide you through a thought-reframing exercise. Try asking "Help me stop overthinking."',
      WellnessDomains.lowMood:
          '💬 Your AI Companion is here to listen without judgment. Share what\'s on your mind, even if it feels small.',
      WellnessDomains.sleepWellness:
          '💬 Ask your AI Companion for a personalized wind-down routine or sleep story.',
      WellnessDomains.relationshipWellness:
          '💬 Your AI Companion can help you explore relationship patterns and practice difficult conversations.',
      WellnessDomains.habitRecovery:
          '💬 Talk to your AI Companion about your recovery journey. Use the Recovery tab to log urges, start detox timers, and track your progress.',
      WellnessDomains.confidenceBuilding:
          '💬 Ask your AI Companion for a confidence-boosting exercise or affirmation session.',
      WellnessDomains.socialConnection:
          '💬 Your AI Companion can help you practice social skills and build confidence in connecting with others.',
      WellnessDomains.mindfulnessPeace:
          '💬 Ask your AI Companion to guide you through a mindfulness or gratitude practice.',
    };
    return suggestions[domain] ??
        '💬 Your AI Companion is always here. Start a conversation anytime.';
  }

  String _generatePlan(String domain, int score) {
    final base = score >= 70
        ? 'Your wellness is on a strong path!'
        : 'Every step forward matters, no matter how small.';
    final plan = {
      WellnessDomains.stressBurnout:
          '🌅 Morning: 5-min breathing • 🌤️ Afternoon: Short walk outside • 🌙 Evening: Gratitude journaling • 😴 Night: Calming music before bed',
      WellnessDomains.anxietyOverthinking:
          '🌅 Morning: Grounding exercise • 🌤️ Afternoon: Name 3 things you can see/hear/feel • 🌙 Evening: Brain dump journaling • 😴 Night: Guided meditation',
      WellnessDomains.lowMood:
          '🌅 Morning: Sunlight exposure • 🌤️ Afternoon: Small win task • 🌙 Evening: Self-compassion practice • 😴 Night: Loving-kindness meditation',
      WellnessDomains.sleepWellness:
          '🌅 Morning: Wake up same time • 🌤️ Afternoon: Limit caffeine after 2 PM • 🌙 Evening: No screens 30 min before bed • 😴 Night: Sleep meditation',
      WellnessDomains.relationshipWellness:
          '🌅 Morning: Set positive intention • 🌤️ Afternoon: Mindful communication • 🌙 Evening: Reflect on connections • 😴 Night: Heart healing meditation',
      WellnessDomains.habitRecovery:
          '🌅 Morning: Affirm your commitment • 🌤️ Afternoon: Log urges in Recovery • 🌙 Evening: Complete a detox session • 😴 Night: Urge surfing meditation',
      WellnessDomains.confidenceBuilding:
          '🌅 Morning: Positive affirmation • 🌤️ Afternoon: Do something that scares you a little • 🌙 Evening: List 3 wins • 😴 Night: Confidence meditation',
      WellnessDomains.socialConnection:
          '🌅 Morning: Intention to connect • 🌤️ Afternoon: Reach out to one person • 🌙 Evening: Reflect on interactions • 😴 Night: Connection visualization',
      WellnessDomains.mindfulnessPeace:
          '🌅 Morning: 5-min silence • 🌤️ Afternoon: Mindful eating • 🌙 Evening: Gratitude practice • 😴 Night: Body scan meditation',
    };
    return '$base\n\n${plan[domain] ?? '🌅 Morning: Deep breathing • 🌤️ Afternoon: Mindful moment • 🌙 Evening: Journal • 😴 Night: Relaxation'}';
  }

  List<String> _getAffirmations(String domain) {
    return {
          WellnessDomains.stressBurnout: [
            'I am allowed to rest.',
            'I release what I cannot control.',
            'My peace is my priority.',
            'I am enough, even when I\'m not productive.'
          ],
          WellnessDomains.anxietyOverthinking: [
            'I am safe in this moment.',
            'I don\'t have to believe every thought.',
            'This feeling will pass.',
            'I trust myself to handle whatever comes.'
          ],
          WellnessDomains.lowMood: [
            'This is temporary.',
            'I am worthy of happiness.',
            'I am not alone.',
            'Even small steps count.'
          ],
          WellnessDomains.sleepWellness: [
            'I welcome restful sleep.',
            'My body deserves deep rest.',
            'I release the day with gratitude.',
            'Sleep is my superpower.'
          ],
          WellnessDomains.relationshipWellness: [
            'I deserve healthy love.',
            'My heart is open and strong.',
            'I attract respectful relationships.',
            'I am complete on my own.'
          ],
          WellnessDomains.habitRecovery: [
            'I am stronger than my urges.',
            'Every choice is a fresh start.',
            'I am building a new identity.',
            'My future self is counting on me.'
          ],
          WellnessDomains.confidenceBuilding: [
            'I am capable and worthy.',
            'My voice matters.',
            'I trust my own judgment.',
            'I am becoming more confident every day.'
          ],
          WellnessDomains.socialConnection: [
            'I deserve connection.',
            'Reaching out is brave.',
            'I have something valuable to share.',
            'I am not alone in this world.'
          ],
          WellnessDomains.mindfulnessPeace: [
            'Peace begins with me.',
            'I am present in this moment.',
            'I choose calm over chaos.',
            'Inner peace is my natural state.'
          ],
        }[domain] ??
        [
          'I am strong.',
          'I am worthy.',
          'I am enough.',
          'I am growing every day.'
        ];
  }

  String _getCrisisMessage() {
    return 'Thank you for being honest about how you\'re feeling. '
        'Your courage in sharing this matters deeply. '
        'Please know that you don\'t have to face difficult feelings alone. '
        'Reaching out to someone you trust — a friend, family member, '
        'or mental health professional — can make a real difference.\n\n'
        'If you ever need immediate support:\n'
        '🇮🇳 In India: Call Vandrevala Foundation Helpline at 1860-266-2345 '
        'or iCall at +91-9152987821\n'
        '🇺🇸 In the US: Call or text 988 (Suicide & Crisis Lifeline)\n'
        '🇬🇧 In the UK: Call 111 or Samaritans at 116 123\n'
        '🌍 Worldwide: Find your local crisis helpline at '
        'https://findahelpline.com\n\n'
        'You are not alone, and this moment — no matter how dark — '
        'is not your final chapter. There is hope, and there is help. ❤️';
  }
}
