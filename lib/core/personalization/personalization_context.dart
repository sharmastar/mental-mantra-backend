class PersonalizationContext {
  final String? primaryDomain;
  final List<String> secondaryDomains;
  final Map<String, double> domainScores;
  final double confidence;
  final String riskLevel;
  final String? completedAt;
  final int version;

  final double? overallWellnessScore;
  final List<String> primaryConcerns;
  final List<String> strengths;

  final double averageMood;
  final int moodEntryCount;
  final String moodTrend;

  final String? memorySummary;

  final bool spiritualMode;
  final String language;
  final int currentStreak;
  final int totalPoints;
  final int level;

  final bool onboardingCompleted;
  final String? lastMeditationType;

  const PersonalizationContext({
    this.primaryDomain,
    this.secondaryDomains = const [],
    this.domainScores = const {},
    this.confidence = 0.0,
    this.riskLevel = 'low',
    this.completedAt,
    this.version = 0,
    this.overallWellnessScore,
    this.primaryConcerns = const [],
    this.strengths = const [],
    this.averageMood = 3.0,
    this.moodEntryCount = 0,
    this.moodTrend = 'stable',
    this.memorySummary,
    this.spiritualMode = false,
    this.language = 'en',
    this.currentStreak = 0,
    this.totalPoints = 0,
    this.level = 1,
    this.onboardingCompleted = false,
    this.lastMeditationType,
  });

  bool get hasClassification => primaryDomain != null;

  bool get needsCrisisAttention => riskLevel == 'high' || riskLevel == 'critical';

  String get domainGreeting {
    if (!hasClassification) return 'Welcome back. How are you feeling today?';
    switch (primaryDomain) {
      case 'stress_burnout':
        return 'Welcome back. I noticed stress has been your biggest challenge lately. Before we begin, how has today been compared with yesterday?';
      case 'anxiety_overthinking':
        return 'I\'m here with you. What\'s been occupying your mind today?';
      case 'emotional_isolation':
        return 'It\'s good to see you. How are you feeling right now?';
      case 'addiction_recovery':
        return 'Welcome back. Every moment is a fresh start. How are things today?';
      case 'anger_dysregulation':
        return 'I\'m glad you\'re here. Let\'s take a moment to check in — what\'s been coming up for you?';
      case 'low_motivation':
        return 'Great to see you! Remember, progress is still progress no matter how small. What feels manageable today?';
      case 'spiritual_seeking':
        return 'Welcome. Finding meaning is a beautiful journey. What\'s been on your mind?';
      case 'sleep_dysregulation':
        return 'Good evening. Since sleep has been difficult recently, let\'s check in before bed.';
      default:
        return 'Welcome back. How are you feeling today?';
    }
  }

  Map<String, String> get dashboardRecommendations {
    if (!hasClassification) return {};
    switch (primaryDomain) {
      case 'stress_burnout':
        return {
          'Breathing': '/home/meditation/breathing',
          'Meditation': '/home/meditation',
          'Journal': '/home/journal',
        };
      case 'anxiety_overthinking':
        return {
          'Breathing': '/home/meditation/breathing',
          'Music': '/home/music',
          'Journal': '/home/journal',
        };
      case 'emotional_isolation':
        return {
          'Journal': '/home/journal',
          'Meditation': '/home/meditation',
          'Discover': '/home/discover',
        };
      case 'addiction_recovery':
        return {
          'Streak': '/home/recovery',
          'Urge Timer': '/home/recovery/urge-log',
          'Detox': '/home/recovery/detox-timer',
        };
      case 'anger_dysregulation':
        return {
          'Breathing': '/home/meditation/breathing',
          'Meditation': '/home/meditation',
          'Journal': '/home/journal',
        };
      case 'low_motivation':
        return {
          'Goals': '/home/goals',
          'Habits': '/home/habits',
          'Achievements': '/home/achievements',
        };
      case 'spiritual_seeking':
        return {
          'Spiritual': '/home/spiritual',
          'Meditation': '/home/meditation',
          'Journal': '/home/journal',
        };
      case 'sleep_dysregulation':
        return {
          'Sleep': '/home/sleep',
          'Meditation': '/home/meditation',
          'Music': '/home/music',
        };
      default:
        return {};
    }
  }

  String get dashboardTitle {
    if (!hasClassification) return 'Good to see you';
    switch (primaryDomain) {
      case 'stress_burnout':
        return 'Let\'s find some calm';
      case 'anxiety_overthinking':
        return 'One breath at a time';
      case 'emotional_isolation':
        return 'You\'re not alone';
      case 'addiction_recovery':
        return 'Every moment counts';
      case 'anger_dysregulation':
        return 'Finding your center';
      case 'low_motivation':
        return 'Small steps add up';
      case 'spiritual_seeking':
        return 'Your journey continues';
      case 'sleep_dysregulation':
        return 'Rest is healing';
      default:
        return 'Good to see you';
    }
  }
}
