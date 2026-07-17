import '../data/models/onboarding_schema.dart';

enum UserDomain {
  stressBurnout('Stress & Burnout', '🔥'),
  anxietyOverthinking('Anxiety & Overthinking', '🌀'),
  emotionalIsolation('Emotional Isolation', '🏝️'),
  addictionRecovery('Addiction Recovery', '🛤️'),
  angerDysregulation('Anger Dysregulation', '💢'),
  lowMotivation('Low Motivation', '⚡'),
  spiritualSeeking('Spiritual Seeking', '🕉️'),
  sleepDysregulation('Sleep Dysregulation', '🌙');

  final String label;
  final String emoji;
  const UserDomain(this.label, this.emoji);

  static UserDomain fromLabel(String label) =>
      values.firstWhere((d) => d.label == label, orElse: () => stressBurnout);
}

enum RiskLevel { low, moderate, high, critical }

class ClassificationResult {
  final UserDomain primaryDomain;
  final UserDomain? secondaryDomain;
  final Map<UserDomain, double> domainScores;
  final RiskLevel riskLevel;
  final bool requiresEscalation;
  final bool crisisResourcesTriggered;
  final String summary;

  const ClassificationResult({
    required this.primaryDomain,
    this.secondaryDomain,
    required this.domainScores,
    this.riskLevel = RiskLevel.low,
    this.requiresEscalation = false,
    this.crisisResourcesTriggered = false,
    this.summary = '',
  });

  Map<UserDomain, double> get sortedDomains {
    final sorted = domainScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in sorted) e.key: e.value};
  }

  List<UserDomain> get prioritizedDomains {
    final sorted = domainScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }
}

class ClassificationEngine {
  static const _symptomWeights = {
    'feeling_overwhelmed': UserDomain.stressBurnout,
    'nervous_anxious': UserDomain.anxietyOverthinking,
    'difficulty_concentrating': UserDomain.anxietyOverthinking,
    'loss_of_interest': UserDomain.lowMotivation,
    'irritable_angry': UserDomain.angerDysregulation,
    'low_energy': UserDomain.lowMotivation,
    'restless': UserDomain.anxietyOverthinking,
    'hopeless': UserDomain.emotionalIsolation,
    'physical_tension': UserDomain.stressBurnout,
    'avoiding_people': UserDomain.emotionalIsolation,
    'intrusive_thoughts': UserDomain.anxietyOverthinking,
    'emotional_numbness': UserDomain.emotionalIsolation,
  };

  static ClassificationResult classifyUserDomain(OnboardingData data) {
    final scores = <UserDomain, double>{
      for (final d in UserDomain.values) d: 0.0
    };

    _scoreEmotionalCheckin(data.emotionalCheckin, scores);
    _scoreSleepAndEnergy(data.sleepEnergy, scores);
    _scoreNeeds(data.needs, scores);
    _scoreHabits(data.habits, scores);
    _scoreCoping(data.coping, scores);
    _scoreSpiritual(data.spiritual, scores);
    _scoreLifestyle(data.lifestyle, scores);
    _scoreBody(data.body, scores);
    _scoreGoals(data.goals, scores);

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final primary = sorted[0].key;
    final secondary =
        sorted.length > 1 && sorted[1].value > 0 ? sorted[1].key : null;
    final maxScore = sorted.isNotEmpty ? sorted[0].value : 0.0;

    final riskLevel = _computeRiskLevel(data, maxScore);
    final requiresEscalation =
        data.coping.requiresCrisisEscalation || riskLevel == RiskLevel.critical;
    final crisisTriggered = data.coping.selfHarmIdeation == 'Often';

    return ClassificationResult(
      primaryDomain: primary,
      secondaryDomain: secondary,
      domainScores: scores,
      riskLevel: riskLevel,
      requiresEscalation: requiresEscalation,
      crisisResourcesTriggered: crisisTriggered,
      summary: _generateSummary(primary, secondary, riskLevel, data),
    );
  }

  static void _scoreEmotionalCheckin(
      EmotionalCheckinSection section, Map<UserDomain, double> scores) {
    for (final entry in section.symptoms.entries) {
      final domain = _symptomWeights[entry.key];
      if (domain == null) continue;
      final weight = _frequencyWeight(entry.value);
      scores[domain] = (scores[domain] ?? 0) + weight;
    }
  }

  static double _frequencyWeight(String frequency) {
    switch (frequency) {
      case 'Almost Always':
        return 3.0;
      case 'Often':
        return 2.0;
      case 'Sometimes':
        return 1.0;
      case 'Rarely':
        return 0.5;
      default:
        return 0.0;
    }
  }

  static void _scoreSleepAndEnergy(
      SleepEnergySection section, Map<UserDomain, double> scores) {
    if (['Very poor', 'Poor'].contains(section.sleepQuality)) {
      scores[UserDomain.sleepDysregulation] =
          (scores[UserDomain.sleepDysregulation] ?? 0) + 3.0;
      scores[UserDomain.stressBurnout] =
          (scores[UserDomain.stressBurnout] ?? 0) + 1.0;
    }
    if (['Moderate', 'Severe', 'Extreme'].contains(section.mentalFatigue)) {
      scores[UserDomain.stressBurnout] =
          (scores[UserDomain.stressBurnout] ?? 0) + 2.0;
      scores[UserDomain.lowMotivation] =
          (scores[UserDomain.lowMotivation] ?? 0) + 1.5;
    }
    if (section.nightScreenUse) {
      scores[UserDomain.sleepDysregulation] =
          (scores[UserDomain.sleepDysregulation] ?? 0) + 1.0;
    }
    if (['Tired', 'Exhausted'].contains(section.morningEnergy)) {
      scores[UserDomain.lowMotivation] =
          (scores[UserDomain.lowMotivation] ?? 0) + 2.0;
    }
    final hoursScore = _sleepHoursScore(section.sleepHours);
    if (hoursScore < 0.5) {
      scores[UserDomain.sleepDysregulation] =
          (scores[UserDomain.sleepDysregulation] ?? 0) + 2.0;
    }
  }

  static double _sleepHoursScore(String hours) {
    switch (hours) {
      case 'Less than 4':
        return 0.0;
      case '4-5':
        return 0.25;
      case '6-7':
        return 0.5;
      case '7-8':
        return 0.75;
      case '8+':
        return 1.0;
      default:
        return 0.5;
    }
  }

  static void _scoreNeeds(
      NeedsSection section, Map<UserDomain, double> scores) {
    for (final reason in section.reasonsJoined) {
      switch (reason) {
        case 'Stress':
        case 'Burnout':
          scores[UserDomain.stressBurnout] =
              (scores[UserDomain.stressBurnout] ?? 0) + 2.0;
        case 'Anxiety':
          scores[UserDomain.anxietyOverthinking] =
              (scores[UserDomain.anxietyOverthinking] ?? 0) + 2.0;
        case 'Loneliness':
          scores[UserDomain.emotionalIsolation] =
              (scores[UserDomain.emotionalIsolation] ?? 0) + 2.0;
        case 'Addictions':
          scores[UserDomain.addictionRecovery] =
              (scores[UserDomain.addictionRecovery] ?? 0) + 3.0;
        case 'Anger Management':
          scores[UserDomain.angerDysregulation] =
              (scores[UserDomain.angerDysregulation] ?? 0) + 3.0;
        case 'Low Motivation':
          scores[UserDomain.lowMotivation] =
              (scores[UserDomain.lowMotivation] ?? 0) + 2.0;
        case 'Sleep Issues':
          scores[UserDomain.sleepDysregulation] =
              (scores[UserDomain.sleepDysregulation] ?? 0) + 2.0;
        case 'Self-Improvement':
          scores[UserDomain.spiritualSeeking] =
              (scores[UserDomain.spiritualSeeking] ?? 0) + 1.0;
        case 'Relationship Issues':
          scores[UserDomain.emotionalIsolation] =
              (scores[UserDomain.emotionalIsolation] ?? 0) + 1.5;
      }
    }
    if (section.affectedAreas.contains('Work')) {
      scores[UserDomain.stressBurnout] =
          (scores[UserDomain.stressBurnout] ?? 0) + 1.0;
    }
    if (section.affectedAreas.contains('Relationships')) {
      scores[UserDomain.emotionalIsolation] =
          (scores[UserDomain.emotionalIsolation] ?? 0) + 1.0;
    }
    if (section.affectedAreas.contains('Self-esteem')) {
      scores[UserDomain.lowMotivation] =
          (scores[UserDomain.lowMotivation] ?? 0) + 1.0;
    }
  }

  static void _scoreHabits(
      HabitsSection section, Map<UserDomain, double> scores) {
    if (section.hasAddictions) {
      scores[UserDomain.addictionRecovery] =
          (scores[UserDomain.addictionRecovery] ?? 0) +
              (section.addictionSeverity == 'Severe'
                  ? 4.0
                  : section.addictionSeverity == 'Moderate'
                      ? 3.0
                      : 2.0);
    }
  }

  static void _scoreCoping(
      CopingSection section, Map<UserDomain, double> scores) {
    final unhealthyCoping = [
      'Substance use',
      'Self-harm',
      'Withdrawal / Isolation',
    ];
    for (final coping in section.copingMechanisms) {
      if (unhealthyCoping.contains(coping)) {
        scores[UserDomain.emotionalIsolation] =
            (scores[UserDomain.emotionalIsolation] ?? 0) + 2.0;
      }
    }
    if (section.selfHarmIdeation != 'Never') {
      scores[UserDomain.emotionalIsolation] =
          (scores[UserDomain.emotionalIsolation] ?? 0) +
              (section.selfHarmIdeation == 'Often' ? 4.0 : 2.0);
      scores[UserDomain.anxietyOverthinking] =
          (scores[UserDomain.anxietyOverthinking] ?? 0) + 1.0;
    }
    if (!section.emotionallySafe) {
      scores[UserDomain.anxietyOverthinking] =
          (scores[UserDomain.anxietyOverthinking] ?? 0) + 1.5;
    }
    if (section.copingMechanisms.contains('Meditation / Prayer')) {
      scores[UserDomain.spiritualSeeking] =
          (scores[UserDomain.spiritualSeeking] ?? 0) + 1.0;
    }
  }

  static void _scoreSpiritual(
      SpiritualSection section, Map<UserDomain, double> scores) {
    if (section.interestInSpiritualContent || section.spiritualOrReligious) {
      scores[UserDomain.spiritualSeeking] =
          (scores[UserDomain.spiritualSeeking] ?? 0) + 2.0;
    }
    if (section.meaningAndPurpose == 'Essential' ||
        section.meaningAndPurpose == 'Very important') {
      scores[UserDomain.spiritualSeeking] =
          (scores[UserDomain.spiritualSeeking] ?? 0) + 1.5;
    }
  }

  static void _scoreLifestyle(
      LifestyleSection section, Map<UserDomain, double> scores) {
    if (section.physicalActivity == 'None') {
      scores[UserDomain.lowMotivation] =
          (scores[UserDomain.lowMotivation] ?? 0) + 1.5;
      scores[UserDomain.stressBurnout] =
          (scores[UserDomain.stressBurnout] ?? 0) + 0.5;
    }
    if (section.emotionalSupport == 'None') {
      scores[UserDomain.emotionalIsolation] =
          (scores[UserDomain.emotionalIsolation] ?? 0) + 2.0;
    }
    if (section.screenTime == '7+ hours') {
      scores[UserDomain.stressBurnout] =
          (scores[UserDomain.stressBurnout] ?? 0) + 1.0;
    }
    if (section.workLifeBalance == 'Very poor' ||
        section.workLifeBalance == 'Poor') {
      scores[UserDomain.stressBurnout] =
          (scores[UserDomain.stressBurnout] ?? 0) + 2.0;
    }
    if (section.socialInteractions == 'Very limited' ||
        section.socialInteractions == 'Limited') {
      scores[UserDomain.emotionalIsolation] =
          (scores[UserDomain.emotionalIsolation] ?? 0) + 1.5;
    }
  }

  static void _scoreBody(BodySection section, Map<UserDomain, double> scores) {
    if (section.eatingHabits == 'Very unhealthy' ||
        section.eatingHabits == 'Mostly unhealthy') {
      scores[UserDomain.lowMotivation] =
          (scores[UserDomain.lowMotivation] ?? 0) + 1.0;
      scores[UserDomain.stressBurnout] =
          (scores[UserDomain.stressBurnout] ?? 0) + 0.5;
    }
    if (section.bodyImageConcerns == 'Very' ||
        section.bodyImageConcerns == 'Extremely') {
      scores[UserDomain.anxietyOverthinking] =
          (scores[UserDomain.anxietyOverthinking] ?? 0) + 1.5;
    }
  }

  static void _scoreGoals(
      GoalsSection section, Map<UserDomain, double> scores) {
    for (final goal in section.goals) {
      switch (goal) {
        case 'Reduce stress and anxiety':
          scores[UserDomain.stressBurnout] =
              (scores[UserDomain.stressBurnout] ?? 0) + 1.0;
          scores[UserDomain.anxietyOverthinking] =
              (scores[UserDomain.anxietyOverthinking] ?? 0) + 1.0;
        case 'Improve sleep':
          scores[UserDomain.sleepDysregulation] =
              (scores[UserDomain.sleepDysregulation] ?? 0) + 1.5;
        case 'Build healthier habits':
          scores[UserDomain.lowMotivation] =
              (scores[UserDomain.lowMotivation] ?? 0) + 1.0;
        case 'Quit an addiction':
          scores[UserDomain.addictionRecovery] =
              (scores[UserDomain.addictionRecovery] ?? 0) + 2.0;
        case 'Improve relationships':
          scores[UserDomain.emotionalIsolation] =
              (scores[UserDomain.emotionalIsolation] ?? 0) + 1.5;
        case 'Find purpose and meaning':
          scores[UserDomain.spiritualSeeking] =
              (scores[UserDomain.spiritualSeeking] ?? 0) + 2.0;
        case 'Manage anger':
          scores[UserDomain.angerDysregulation] =
              (scores[UserDomain.angerDysregulation] ?? 0) + 2.5;
        case 'Boost confidence':
          scores[UserDomain.lowMotivation] =
              (scores[UserDomain.lowMotivation] ?? 0) + 1.5;
        case 'Practice mindfulness':
          scores[UserDomain.spiritualSeeking] =
              (scores[UserDomain.spiritualSeeking] ?? 0) + 1.0;
      }
    }
  }

  static RiskLevel _computeRiskLevel(OnboardingData data, double maxScore) {
    if (data.coping.selfHarmIdeation == 'Often') return RiskLevel.critical;
    if (data.coping.selfHarmIdeation == 'Sometimes') return RiskLevel.high;
    if (!data.coping.emotionallySafe) return RiskLevel.high;
    if (maxScore >= 8) return RiskLevel.moderate;
    if (maxScore >= 5) return RiskLevel.low;
    return RiskLevel.low;
  }

  static String _generateSummary(
    UserDomain primary,
    UserDomain? secondary,
    RiskLevel risk,
    OnboardingData data,
  ) {
    final parts = <String>[];
    final greeting = data.basicInfo.nickname.isNotEmpty
        ? 'Hi ${data.basicInfo.nickname}, '
        : '';

    switch (primary) {
      case UserDomain.stressBurnout:
        parts.add(
            "${greeting}we can see you've been carrying a lot. Let's work on easing that load together.");
      case UserDomain.anxietyOverthinking:
        parts.add(
            "${greeting}your mind seems to be working overtime. We'll help you find some calm.");
      case UserDomain.emotionalIsolation:
        parts.add(
            "${greeting}you're not alone in this. We'll help you feel more connected.");
      case UserDomain.addictionRecovery:
        parts.add(
            "${greeting}taking this step shows real strength. We're here to support your journey.");
      case UserDomain.angerDysregulation:
        parts.add(
            "${greeting}let's work on channeling that energy in ways that feel good to you.");
      case UserDomain.lowMotivation:
        parts.add(
            "${greeting}we'll help you find your spark again, one small step at a time.");
      case UserDomain.spiritualSeeking:
        parts.add(
            "${greeting}we'll explore meaning and purpose together, at your own pace.");
      case UserDomain.sleepDysregulation:
        parts.add(
            "${greeting}restorative sleep is key — we'll help you build better sleep habits.");
    }

    if (secondary != null) {
      parts.add(
          "We'll also focus on ${secondary.label.toLowerCase()} as a supporting area.");
    }

    return parts.join(' ');
  }
}
