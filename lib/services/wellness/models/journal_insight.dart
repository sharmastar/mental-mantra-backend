class JournalInsight {
  final String entryId;
  final String content;
  final int mood;
  final DateTime createdAt;
  final EmotionProfile emotions;
  final List<String> dominantThemes;
  final List<Trigger> triggers;
  final List<String> gratitudeItems;
  final List<CognitiveDistortion> distortions;
  final List<String> positiveMoments;
  final double growthScore;

  const JournalInsight({
    required this.entryId,
    required this.content,
    required this.mood,
    required this.createdAt,
    required this.emotions,
    required this.dominantThemes,
    required this.triggers,
    required this.gratitudeItems,
    required this.distortions,
    required this.positiveMoments,
    required this.growthScore,
  });
}

class EmotionProfile {
  final String primaryEmotion;
  final double primaryIntensity;
  final List<String> secondaryEmotions;
  final double sentimentScore;
  final SentimentLabel sentimentLabel;

  const EmotionProfile({
    required this.primaryEmotion,
    required this.primaryIntensity,
    required this.secondaryEmotions,
    required this.sentimentScore,
    required this.sentimentLabel,
  });
}

enum SentimentLabel { veryPositive, positive, neutral, negative, veryNegative }

class TopicFrequency {
  final String topic;
  final int count;
  final double percentage;
  final String trend;

  const TopicFrequency({
    required this.topic,
    required this.count,
    required this.percentage,
    required this.trend,
  });
}

class Trigger {
  final String trigger;
  final String category;
  final int frequency;
  final double intensity;

  const Trigger({
    required this.trigger,
    required this.category,
    required this.frequency,
    required this.intensity,
  });
}

class CognitiveDistortion {
  final String type;
  final String example;
  final String reframe;

  const CognitiveDistortion({
    required this.type,
    required this.example,
    required this.reframe,
  });
}

enum DistortionType {
  allOrNothing,
  overgeneralization,
  mentalFilter,
  disqualifyingPositive,
  jumpingToConclusions,
  magnification,
  emotionalReasoning,
  shouldStatements,
  labeling,
  personalization,
}

class GrowthScore {
  final double overall;
  final double emotionalAwareness;
  final double copingSkills;
  final double resilience;
  final double selfCompassion;
  final String trend;

  const GrowthScore({
    required this.overall,
    required this.emotionalAwareness,
    required this.copingSkills,
    required this.resilience,
    required this.selfCompassion,
    required this.trend,
  });
}

class WeeklySummary {
  final DateTime weekOf;
  final int entryCount;
  final double averageMood;
  final String moodTrend;
  final List<TopicFrequency> topTopics;
  final EmotionProfile averageEmotionProfile;
  final List<String> keyInsights;
  final GrowthScore growth;

  const WeeklySummary({
    required this.weekOf,
    required this.entryCount,
    required this.averageMood,
    required this.moodTrend,
    required this.topTopics,
    required this.averageEmotionProfile,
    required this.keyInsights,
    required this.growth,
  });
}

class MonthlySummary {
  final DateTime monthOf;
  final int entryCount;
  final double averageMood;
  final String moodTrend;
  final List<WeeklySummary> weeks;
  final List<TopicFrequency> topTopics;
  final GrowthScore growth;
  final List<Trigger> mostCommonTriggers;
  final String overallNarrative;

  const MonthlySummary({
    required this.monthOf,
    required this.entryCount,
    required this.averageMood,
    required this.moodTrend,
    required this.weeks,
    required this.topTopics,
    required this.growth,
    required this.mostCommonTriggers,
    required this.overallNarrative,
  });
}
