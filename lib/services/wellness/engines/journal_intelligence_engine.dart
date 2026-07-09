import '../models/journal_insight.dart';
import '../../../features/journal/data/models/journal_entry.dart';

class JournalIntelligenceEngine {
  static const _positiveWords = [
    'happy', 'grateful', 'peaceful', 'joy', 'love', 'excited', 'hopeful',
    'calm', 'content', 'blessed', 'proud', 'confident', 'motivated',
    'energized', 'relaxed', 'thankful', 'wonderful', 'beautiful', 'amazing',
    'great', 'good', 'better', 'improved', 'strong', 'safe',
  ];

  static const _negativeWords = [
    'sad', 'angry', 'anxious', 'stressed', 'worried', 'scared', 'lonely',
    'hopeless', 'tired', 'exhausted', 'frustrated', 'upset', 'hurt',
    'disappointed', 'depressed', 'overwhelmed', 'nervous', 'afraid',
    'terrible', 'awful', 'bad', 'worst', 'hate', 'pain', 'struggle',
  ];

  static const _themePatterns = {
    'work_stress': ['work', 'boss', 'project', 'deadline', 'office', 'colleague', 'meeting', 'pressure'],
    'relationship': ['partner', 'friend', 'family', 'mother', 'father', 'spouse', 'boyfriend', 'girlfriend', 'relation'],
    'health': ['health', 'exercise', 'workout', 'diet', 'weight', 'doctor', 'pain', 'sick', 'ill'],
    'self_growth': ['learn', 'grow', 'improve', 'progress', 'goal', 'achieve', 'habit', 'discipline'],
    'anxiety': ['worry', 'anxious', 'panic', 'fear', 'nervous', 'overthink', 'racing'],
    'gratitude': ['grateful', 'thankful', 'blessed', 'appreciate', 'fortunate'],
    'sleep': ['sleep', 'tired', 'insomnia', 'rest', 'bed', 'nightmare', 'awake'],
    'social': ['friend', 'party', 'social', 'meet', 'call', 'text', 'message', 'hangout'],
    'recovery': ['urge', 'crave', 'relapse', 'sober', 'clean', 'addiction', 'habit'],
  };

  JournalInsight analyzeEntry(JournalEntry entry) {
    final lower = entry.content.toLowerCase();
    final words = lower.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();

    final positiveCount = words.where((w) => _positiveWords.contains(w)).length;
    final negativeCount = words.where((w) => _negativeWords.contains(w)).length;
    final totalSentimentWords = positiveCount + negativeCount;
    final sentimentScore = totalSentimentWords > 0
        ? (positiveCount - negativeCount) / totalSentimentWords
        : 0.0;

    final sentimentLabel = _classifySentiment(sentimentScore);

    final emotions = <String, int>{};
    for (final word in _positiveWords) {
      if (lower.contains(word)) emotions[word] = (emotions[word] ?? 0) + 1;
    }
    for (final word in _negativeWords) {
      if (lower.contains(word)) emotions[word] = (emotions[word] ?? 0) + 1;
    }
    final sortedEmotions = emotions.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final primaryEmotion = sortedEmotions.isNotEmpty ? sortedEmotions.first.key : 'neutral';
    final primaryIntensity = sortedEmotions.isNotEmpty
        ? (sortedEmotions.first.value / words.length * 10).clamp(1.0, 10.0)
        : 1.0;
    final secondaryEmotions = sortedEmotions.skip(1).take(3).map((e) => e.key).toList();

    final themes = <String>[];
    for (final entry in _themePatterns.entries) {
      if (entry.value.any((w) => lower.contains(w))) {
        themes.add(entry.key);
      }
    }

    final triggers = _extractTriggers(lower);

    final gratitudeItems = _extractGratitude(entry.content);

    final distortions = _detectDistortions(lower, entry.content);

    final positiveMoments = _extractPositiveMoments(entry.content, lower);

    final growthScore = _computeGrowthScore(entry.mood, sentimentScore, themes.length, distortions.length);

    return JournalInsight(
      entryId: entry.id ?? '',
      content: entry.content,
      mood: entry.mood,
      createdAt: entry.createdAt,
      emotions: EmotionProfile(
        primaryEmotion: primaryEmotion,
        primaryIntensity: primaryIntensity,
        secondaryEmotions: secondaryEmotions,
        sentimentScore: sentimentScore,
        sentimentLabel: sentimentLabel,
      ),
      dominantThemes: themes,
      triggers: triggers,
      gratitudeItems: gratitudeItems,
      distortions: distortions,
      positiveMoments: positiveMoments,
      growthScore: growthScore,
    );
  }

  WeeklySummary generateWeeklySummary(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return WeeklySummary(
        weekOf: DateTime.now(),
        entryCount: 0,
        averageMood: 3.0,
        moodTrend: 'stable',
        topTopics: [],
        averageEmotionProfile: const EmotionProfile(
          primaryEmotion: 'neutral', primaryIntensity: 1.0,
          secondaryEmotions: [], sentimentScore: 0.0, sentimentLabel: SentimentLabel.neutral,
        ),
        keyInsights: ['No journal entries this week.'],
        growth: const GrowthScore(overall: 50, emotionalAwareness: 50, copingSkills: 50, resilience: 50, selfCompassion: 50, trend: 'stable'),
      );
    }

    final insights = entries.map(analyzeEntry).toList();
    final avgMood = entries.fold(0.0, (a, e) => a + e.mood) / entries.length;
    final moodTrend = _computeTrend(insights);

    final topicCount = <String, int>{};
    for (final ins in insights) {
      for (final topic in ins.dominantThemes) {
        topicCount[topic] = (topicCount[topic] ?? 0) + 1;
      }
    }
    final sortedTopics = topicCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topTopics = sortedTopics.map((e) => TopicFrequency(
      topic: e.key, count: e.value,
      percentage: (e.value / entries.length * 100),
      trend: 'stable',
    )).toList();

    final avgSentiment = insights.fold(0.0, (a, i) => a + i.emotions.sentimentScore) / insights.length;

    final avgGrowth = insights.fold(0.0, (a, i) => a + i.growthScore) / insights.length;
    final firstGrowth = insights.isNotEmpty ? insights.first.growthScore : 50.0;
    final growthTrend = avgGrowth > firstGrowth ? 'improving' : avgGrowth < firstGrowth ? 'declining' : 'stable';

    return WeeklySummary(
      weekOf: DateTime.now(),
      entryCount: entries.length,
      averageMood: avgMood,
      moodTrend: moodTrend,
      topTopics: topTopics,
      averageEmotionProfile: EmotionProfile(
        primaryEmotion: avgSentiment > 0 ? 'positive' : avgSentiment < 0 ? 'negative' : 'neutral',
        primaryIntensity: avgSentiment.abs().clamp(1.0, 10.0),
        secondaryEmotions: [], sentimentScore: avgSentiment,
        sentimentLabel: _classifySentiment(avgSentiment),
      ),
      keyInsights: _generateWeeklyInsights(insights),
      growth: GrowthScore(
        overall: avgGrowth.clamp(0, 100),
        emotionalAwareness: _awarenessScore(insights),
        copingSkills: _copingScore(insights),
        resilience: _resilienceScore(insights),
        selfCompassion: _selfCompassionScore(insights),
        trend: growthTrend,
      ),
    );
  }

  MonthlySummary generateMonthlySummary(List<WeeklySummary> weeks) {
    final totalEntries = weeks.fold(0, (a, w) => a + w.entryCount);
    final avgMood = weeks.fold(0.0, (a, w) => a + w.averageMood) / (weeks.length).clamp(1, 999);

    final topicCount = <String, int>{};
    for (final w in weeks) {
      for (final t in w.topTopics) {
        topicCount[t.topic] = (topicCount[t.topic] ?? 0) + t.count;
      }
    }
    final sortedTopics = topicCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return MonthlySummary(
      monthOf: DateTime.now(),
      entryCount: totalEntries,
      averageMood: avgMood,
      moodTrend: weeks.last.moodTrend,
      weeks: weeks,
      topTopics: sortedTopics.map((e) => TopicFrequency(
        topic: e.key, count: e.value, percentage: (e.value / totalEntries * 100), trend: 'stable',
      )).toList(),
      growth: weeks.isNotEmpty ? weeks.last.growth : const GrowthScore(overall: 50, emotionalAwareness: 50, copingSkills: 50, resilience: 50, selfCompassion: 50, trend: 'stable'),
      mostCommonTriggers: [],
      overallNarrative: _generateMonthlyNarrative(weeks),
    );
  }

  SentimentLabel _classifySentiment(double score) {
    if (score > 0.5) return SentimentLabel.veryPositive;
    if (score > 0.1) return SentimentLabel.positive;
    if (score < -0.5) return SentimentLabel.veryNegative;
    if (score < -0.1) return SentimentLabel.negative;
    return SentimentLabel.neutral;
  }

  List<Trigger> _extractTriggers(String lower) {
    final triggers = <Trigger>[];
    if (lower.contains('work') || lower.contains('boss') || lower.contains('deadline')) {
      triggers.add(const Trigger(trigger: 'Work pressure', category: 'occupational', frequency: 1, intensity: 6.0));
    }
    if (lower.contains('argue') || lower.contains('fight') || lower.contains('conflict')) {
      triggers.add(const Trigger(trigger: 'Conflict', category: 'relational', frequency: 1, intensity: 7.0));
    }
    if (lower.contains('tired') || lower.contains('exhausted') || lower.contains('sleepless')) {
      triggers.add(const Trigger(trigger: 'Fatigue', category: 'physical', frequency: 1, intensity: 5.0));
    }
    if (lower.contains('social') || lower.contains('crowd') || lower.contains('party')) {
      triggers.add(const Trigger(trigger: 'Social situations', category: 'social', frequency: 1, intensity: 4.0));
    }
    if (lower.contains('health') || lower.contains('pain') || lower.contains('sick')) {
      triggers.add(const Trigger(trigger: 'Health concerns', category: 'health', frequency: 1, intensity: 6.0));
    }
    return triggers;
  }

  List<String> _extractGratitude(String content) {
    final lower = content.toLowerCase();
    final items = <String>[];
    if (lower.contains('grateful for') || lower.contains('thankful for')) {
      final sentences = content.split(RegExp(r'[.!?\n]'));
      for (final s in sentences) {
        if (s.toLowerCase().contains('grateful') || s.toLowerCase().contains('thankful')) {
          items.add(s.trim());
        }
      }
    }
    if (items.isEmpty && (lower.contains('grateful') || lower.contains('thankful') || lower.contains('blessed'))) {
      items.add('The user expressed gratitude in their entry.');
    }
    return items;
  }

  List<CognitiveDistortion> _detectDistortions(String lower, String original) {
    final distortions = <CognitiveDistortion>[];
    if (RegExp(r'\b(always|never|everyone|no one|everything|nothing)\b').hasMatch(lower)) {
      final match = RegExp(r'\b(always|never|everyone|no one|everything|nothing)\b').stringMatch(lower);
      distortions.add(CognitiveDistortion(
        type: 'All-or-Nothing Thinking',
        example: 'Using absolutes like "$match"',
        reframe: 'Look for shades of gray rather than extremes.',
      ));
    }
    if (RegExp(r'\bshould\b|\bmust\b|\bhave to\b').hasMatch(lower)) {
      distortions.add(const CognitiveDistortion(
        type: 'Should Statements',
        example: 'Holding rigid rules about how things "should" be',
        reframe: 'Replace "should" with "could" or "would like to."',
      ));
    }
    if (RegExp(r'\b(terrible|awful|horrible|disaster|catastrophe)\b').hasMatch(lower)) {
      distortions.add(const CognitiveDistortion(
        type: 'Catastrophizing',
        example: 'Expecting the worst-case scenario',
        reframe: 'What is the most likely outcome? Is there evidence?',
      ));
    }
    if (RegExp(r"\b(can't|won't|cannot|impossible|hopeless)\b").hasMatch(lower)) {
      distortions.add(const CognitiveDistortion(
        type: 'Fortune Telling',
        example: 'Predicting negative outcomes as facts',
        reframe: 'What evidence suggests things could work out?',
      ));
    }
    if (RegExp(r"\b(my fault|my mistake|i messed up|i failed|i'm not good enough)\b").hasMatch(lower)) {
      distortions.add(const CognitiveDistortion(
        type: 'Personalization',
        example: 'Taking blame for things outside your control',
        reframe: 'What factors beyond you contributed to the situation?',
      ));
    }
    return distortions;
  }

  List<String> _extractPositiveMoments(String original, String lower) {
    final moments = <String>[];
    final sentences = original.split(RegExp(r'[.!?\n]'));
    for (final s in sentences) {
      final sl = s.toLowerCase();
      final positiveWordCount = _positiveWords.where((w) => sl.contains(w)).length;
      if (positiveWordCount >= 2 && sl.length > 15) {
        moments.add(s.trim());
      }
    }
    return moments;
  }

  double _computeGrowthScore(int mood, double sentiment, int themesCount, int distortionCount) {
    final moodScore = (mood / 5 * 30);
    final sentimentScore = ((sentiment + 1) / 2 * 30);
    final awarenessScore = (themesCount / 5 * 20).clamp(0, 20);
    final challengeScore = (1 - distortionCount / 5) * 20;
    return (moodScore + sentimentScore + awarenessScore + challengeScore).clamp(0, 100);
  }

  String _computeTrend(List<JournalInsight> insights) {
    if (insights.length < 2) return 'stable';
    final first = insights.last.mood;
    final last = insights.first.mood;
    final diff = last - first;
    if (diff > 0.5) return 'improving';
    if (diff < -0.5) return 'declining';
    return 'stable';
  }

  double _awarenessScore(List<JournalInsight> insights) {
    final avgThemes = insights.fold(0.0, (a, i) => a + i.dominantThemes.length) / insights.length;
    return (avgThemes / 5 * 100).clamp(0, 100).roundToDouble();
  }

  double _copingScore(List<JournalInsight> insights) {
    final withDistortions = insights.where((i) => i.distortions.isEmpty).length;
    return (withDistortions / insights.length * 100).roundToDouble();
  }

  double _resilienceScore(List<JournalInsight> insights) {
    final positiveEndings = insights.where((i) => i.emotions.sentimentScore >= 0).length;
    return (positiveEndings / insights.length * 100).roundToDouble();
  }

  double _selfCompassionScore(List<JournalInsight> insights) {
    final withGratitude = insights.where((i) => i.gratitudeItems.isNotEmpty).length;
    final gratitudeRatio = withGratitude / insights.length;
    final avgMood = insights.fold(0.0, (a, i) => a + i.mood) / insights.length;
    return ((gratitudeRatio * 50) + (avgMood / 5 * 50)).roundToDouble();
  }

  List<String> _generateWeeklyInsights(List<JournalInsight> insights) {
    final list = <String>[];
    final avgMood = insights.fold(0.0, (a, i) => a + i.mood) / insights.length;
    if (avgMood >= 4.0) {
      list.add('Consistently positive mood throughout the week.');
    } else if (avgMood <= 2.0) {
      list.add('Mood has been low this week. Consider additional support.');
    } else {
      list.add('Your mood has been moderate this week with room for improvement.');
    }

    final allTopics = insights.expand((i) => i.dominantThemes).toList();
    if (allTopics.isNotEmpty) {
      final top = _mode(allTopics);
      list.add('Dominant theme: "$top" appeared frequently in your entries.');
    }

    final distortions = insights.expand((i) => i.distortions).toList();
    if (distortions.isNotEmpty) {
      list.add('${distortions.length} cognitive distortion patterns detected this week.');
    }
    return list;
  }

  String _generateMonthlyNarrative(List<WeeklySummary> weeks) {
    if (weeks.isEmpty) return 'No data available for this month.';
    final avgMood = weeks.fold(0.0, (a, w) => a + w.averageMood) / weeks.length;
    final totalEntries = weeks.fold(0, (a, w) => a + w.entryCount);
    final trend = weeks.length >= 2 && weeks.last.averageMood > weeks.first.averageMood
        ? 'improving' : 'stable';
    return 'You wrote $totalEntries journal entries this month. '
        'Average mood: ${avgMood.toStringAsFixed(1)}/5. '
        'Overall trend: $trend. '
        'Your top focus areas this month were: ${_topFocusAreas(weeks)}.';
  }

  String _topFocusAreas(List<WeeklySummary> weeks) {
    final topics = <String, int>{};
    for (final w in weeks) {
      for (final t in w.topTopics) {
        topics[t.topic] = (topics[t.topic] ?? 0) + t.count;
      }
    }
    final sorted = topics.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key.replaceAll('_', ' ')).join(', ');
  }

  String? _mode(List<String> items) {
    final counts = <String, int>{};
    for (final item in items) {
      counts[item] = (counts[item] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.isNotEmpty ? sorted.first.key : null;
  }
}
