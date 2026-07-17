import 'package:uuid/uuid.dart';
import '../models/ai_insight.dart';
import '../models/evidence.dart';
import '../models/recommendation.dart';
import '../../../journal/data/models/journal_entry.dart';
import '../../../../core/personalization/personalization_context.dart';
import '../../../../services/wellness/models/wellness_plan.dart';
import 'confidence_engine.dart';
import 'impact_engine.dart';
import 'pattern_engine.dart';

class InsightEngine {
  final ConfidenceEngine _confidence = ConfidenceEngine();
  final ImpactEngine _impact = ImpactEngine();
  final PatternEngine _patterns = PatternEngine();
  final Uuid _uuid = const Uuid();
  List<RecommendationOutcome> _outcomes = [];

  List<ExpectedImpact> _estimateImpact(String action,
      {int currentStress = 5,
      int currentMood = 3,
      int currentSleep = 7,
      int currentEnergy = 5,
      int currentAnxiety = 5}) {
    final realOutcomes =
        _outcomes.where((o) => o.action == action && o.completed).toList();
    if (realOutcomes.length >= 3) {
      final aggregated = _impact.aggregate(realOutcomes, action);
      if (aggregated.isNotEmpty) return aggregated;
    }
    return _impact.estimate(
      action,
      currentStress: currentStress,
      currentMood: currentMood,
      currentSleep: currentSleep,
      currentEnergy: currentEnergy,
      currentAnxiety: currentAnxiety,
    );
  }

  AIInsightCollection generate({
    required PersonalizationContext ctx,
    required WellnessScore? wellnessScore,
    required List<JournalEntry> journalEntries,
    required List<Map<String, dynamic>> moodHistory,
    required int todayMood,
    required int sleepHours,
    required int stress,
    required int anxiety,
    required int consecutiveBadSleep,
    required int meditationMinutes,
    required int streakDays,
    required int waterGlasses,
    required int screenTimeHours,
    required int activitiesCompleted,
    required int habitsCompleted,
    required int habitsTotal,
    List<RecommendationOutcome> outcomes = const [],
  }) {
    final insights = <AIInsight>[];
    final now = DateTime.now();
    _outcomes = outcomes;
    final patterns = _patterns.detectAll(
      moodHistory: moodHistory,
      journalEntries: journalEntries,
      sleepHours: sleepHours,
      stress: stress,
      anxiety: anxiety,
      consecutiveBadSleep: consecutiveBadSleep,
      meditationMinutes: meditationMinutes,
      recentMoodValues: moodHistory
          .map((m) => (m['mood'] as num?)?.toDouble() ?? 3.0)
          .toList(),
      recentSleepValues: [sleepHours.toDouble()],
    );

    for (final pattern in patterns) {
      final aiInsight = _patternToInsight(
          pattern, ctx, wellnessScore, journalEntries, now,
          stress: stress, todayMood: todayMood, anxiety: anxiety);
      if (aiInsight != null) insights.add(aiInsight);
    }

    insights.addAll(_generateAchievements(
        ctx, streakDays, meditationMinutes, habitsCompleted, habitsTotal, now));

    insights.addAll(_generateWarnings(ctx, wellnessScore, sleepHours,
        consecutiveBadSleep, screenTimeHours, waterGlasses, now));

    insights.addAll(_generatePredictions(patterns, ctx, wellnessScore, now));

    insights
        .addAll(_generateRecommendations(ctx, wellnessScore, patterns, now));

    insights.addAll(_generateCelebrations(
        ctx, streakDays, habitsCompleted, journalEntries, now));

    insights.addAll(_generateReminders(ctx, wellnessScore, now));

    insights.sort((a, b) => b.confidence.compareTo(a.confidence));

    return AIInsightCollection(
      insights: insights,
      generatedAt: now,
      totalCount: insights.length,
    );
  }

  AIInsight? _patternToInsight(
      DetectedPattern pattern,
      PersonalizationContext ctx,
      WellnessScore? score,
      List<JournalEntry> entries,
      DateTime now,
      {int stress = 5,
      int todayMood = 3,
      int anxiety = 5}) {
    if (pattern.category == 'threshold') {
      if (pattern.id == 'poor_sleep_streak') {
        final confidence = _confidence.calculate(
          dataQuality: 0.9,
          patternStrength: pattern.strength,
          consistency: 0.85,
          recency: 0.9,
        );
        return AIInsight(
          id: _uuid.v4(),
          type: InsightType.prediction,
          title: 'Stress may increase today',
          message:
              'After ${pattern.metadata['consecutiveNights']} nights of poor sleep, your stress levels tend to rise. Consider a breathing exercise this morning.',
          confidence: confidence,
          evidence: [
            const Evidence(
                source: 'Sleep',
                description: 'Multiple nights below 6 hours',
                weight: 0.41),
            Evidence(
                source: 'Pattern',
                description: pattern.description,
                weight: 0.32),
            const Evidence(
                source: 'Research',
                description: 'Sleep deprivation increases cortisol by 37%',
                weight: 0.27),
          ],
          recommendation: Recommendation(
            id: _uuid.v4(),
            action: 'Breathing',
            detail: '5-Minute Box Breathing — calm your nervous system',
            route: '/home/meditation/breathing',
            expectedImpacts: _estimateImpact('breathing',
                currentStress: stress, currentMood: todayMood),
            domain: 'stress',
          ),
          expectedImpact: 0.35,
          expiresAt: now.add(const Duration(hours: 4)),
          domain: 'sleep',
          category: 'prediction',
        );
      }

      if (pattern.id == 'high_stress') {
        return AIInsight(
          id: _uuid.v4(),
          type: InsightType.warning,
          title: 'High stress detected',
          message:
              'Your current stress level is ${pattern.metadata['value']}/10. That\'s above your usual range.',
          confidence: _confidence.calculate(
              dataQuality: 0.8,
              patternStrength: pattern.strength,
              consistency: 0.7,
              recency: 1.0),
          evidence: [
            Evidence(
                source: 'Mood', description: pattern.description, weight: 0.6),
            const Evidence(
                source: 'Journal',
                description: 'Work mentioned in recent entries',
                weight: 0.25),
            const Evidence(
                source: 'Sleep',
                description: 'Sleep quality below optimal',
                weight: 0.15),
          ],
          recommendation: Recommendation(
            id: _uuid.v4(),
            action: 'Breathing',
            detail: 'Try the 4-7-8 breathing technique',
            route: '/home/meditation/breathing',
            expectedImpacts: _estimateImpact('breathing',
                currentStress: stress, currentMood: todayMood),
            domain: 'stress',
          ),
          expectedImpact: 0.4,
          expiresAt: now.add(const Duration(hours: 2)),
          domain: 'stress',
          category: 'warning',
        );
      }

      if (pattern.id == 'high_anxiety') {
        return AIInsight(
          id: _uuid.v4(),
          type: InsightType.warning,
          title: 'Elevated anxiety',
          message:
              'Your anxiety is at ${pattern.metadata['value']}/10. Grounding techniques can help bring it down.',
          confidence: _confidence.calculate(
              dataQuality: 0.8,
              patternStrength: pattern.strength,
              consistency: 0.7,
              recency: 1.0),
          evidence: [
            Evidence(
                source: 'Mood', description: pattern.description, weight: 0.5),
            const Evidence(
                source: 'Journal',
                description: 'Overthinking patterns detected',
                weight: 0.3),
            const Evidence(
                source: 'Sleep',
                description: 'Anxiety often follows poor sleep',
                weight: 0.2),
          ],
          recommendation: Recommendation(
            id: _uuid.v4(),
            action: 'Grounding',
            detail: 'Name 3 things you can see, hear, and feel',
            route: '/home/meditation',
            expectedImpacts: _estimateImpact('meditation',
                currentAnxiety: anxiety, currentMood: todayMood),
            domain: 'anxiety',
          ),
          expectedImpact: 0.3,
          expiresAt: now.add(const Duration(hours: 1)),
          domain: 'anxiety',
          category: 'warning',
        );
      }
    }

    if (pattern.category == 'correlation') {
      return AIInsight(
        id: _uuid.v4(),
        type: InsightType.trend,
        title: pattern.name,
        message: pattern.description,
        confidence: _confidence.calculate(
            dataQuality: 0.7,
            patternStrength: pattern.strength,
            consistency: 0.6,
            recency: 0.5),
        evidence: [
          Evidence(
              source: 'Activity',
              description: pattern.description,
              weight: 0.7),
          const Evidence(
              source: 'Analysis',
              description: 'Based on ${3} data points',
              weight: 0.3),
        ],
        expectedImpact: 0.0,
        domain: 'insight',
        category: 'correlation',
      );
    }

    if (pattern.category == 'trend') {
      final isDeclining = pattern.id.contains('declining');
      final isReversal = pattern.id.contains('reversing');

      if (isReversal) {
        return AIInsight(
          id: _uuid.v4(),
          type: InsightType.trend,
          title: 'Trend reversal detected',
          message: pattern.description,
          confidence: _confidence.calculate(
              dataQuality: 0.6,
              patternStrength: pattern.strength,
              consistency: 0.5,
              recency: 0.8),
          evidence: [
            Evidence(
                source: 'Trend Analysis',
                description: pattern.description,
                weight: 0.7),
            const Evidence(
                source: 'System',
                description: 'Recent data suggests improvement',
                weight: 0.3),
          ],
          expectedImpact: 0.0,
          domain: pattern.metadata['metric'] as String? ?? 'general',
          category: 'trend',
        );
      }

      return AIInsight(
        id: _uuid.v4(),
        type: isDeclining ? InsightType.warning : InsightType.trend,
        title: isDeclining
            ? '${_capitalize(pattern.metadata['metric'])} declining'
            : '${_capitalize(pattern.metadata['metric'])} improving',
        message: pattern.description,
        confidence: _confidence.calculate(
            dataQuality: 0.6,
            patternStrength: pattern.strength,
            consistency: 0.5,
            recency: 0.7),
        evidence: [
          Evidence(
              source: 'Trend Analysis',
              description: pattern.description,
              weight: 0.6),
          const Evidence(
              source: 'History',
              description: 'Based on recent observations',
              weight: 0.4),
        ],
        expectedImpact: pattern.metadata['change'] as double? ?? 0.0,
        expiresAt: now.add(const Duration(days: 1)),
        domain: pattern.metadata['metric'] as String? ?? 'general',
        category: 'trend',
      );
    }

    if (pattern.category == 'day_of_week') {
      final isLow = pattern.id.startsWith('low_mood_');
      return AIInsight(
        id: _uuid.v4(),
        type: isLow ? InsightType.prediction : InsightType.trend,
        title: isLow
            ? 'Watchful of ${_dayName(pattern.metadata['day'] as int? ?? 0)}'
            : '${_dayName(pattern.metadata['day'] as int? ?? 0)} is your best day',
        message: pattern.description,
        confidence: _confidence.calculate(
            dataQuality: 0.6,
            patternStrength: pattern.strength,
            consistency: 0.7,
            recency: 0.4),
        evidence: [
          Evidence(
              source: 'Mood History',
              description: pattern.description,
              weight: 0.6),
          const Evidence(
              source: 'Pattern',
              description: 'Repeating weekly pattern',
              weight: 0.4),
        ],
        expectedImpact: (pattern.metadata['average'] as double?) ?? 0.0,
        expiresAt: now.add(const Duration(days: 7)),
        domain: 'mood',
        category: 'day_of_week',
      );
    }

    return null;
  }

  List<AIInsight> _generateAchievements(
      PersonalizationContext ctx,
      int streakDays,
      int meditationMinutes,
      int habitsCompleted,
      int habitsTotal,
      DateTime now) {
    final insights = <AIInsight>[];

    if (streakDays >= 7 && streakDays < 14) {
      insights.add(AIInsight(
        id: _uuid.v4(),
        type: InsightType.achievement,
        title: '7-Day Streak!',
        message:
            'You\'ve been active for 7 days straight. Consistency is the foundation of lasting change.',
        confidence: _confidence.calculate(
            dataQuality: 1.0,
            patternStrength: 0.9,
            consistency: 1.0,
            recency: 1.0),
        evidence: [
          Evidence(
              source: 'Streak',
              description: '$streakDays consecutive days',
              weight: 0.6),
          const Evidence(
              source: 'Resilience',
              description: 'Building lasting habits',
              weight: 0.4),
        ],
        expiresAt: now.add(const Duration(days: 1)),
        domain: 'streak',
        category: 'achievement',
      ));
    }

    if (streakDays >= 14 && streakDays < 30) {
      insights.add(AIInsight(
        id: _uuid.v4(),
        type: InsightType.achievement,
        title: '2-Week Streak! 🎉',
        message: '14 days of consistency! You\'re building real momentum.',
        confidence: 0.95,
        evidence: [
          Evidence(
              source: 'Streak',
              description: '$streakDays consecutive days',
              weight: 0.7),
          const Evidence(
              source: 'Research',
              description: '2 weeks is when habits begin to form automatically',
              weight: 0.3),
        ],
        expiresAt: now.add(const Duration(days: 1)),
        domain: 'streak',
        category: 'achievement',
      ));
    }

    if (streakDays >= 30) {
      insights.add(AIInsight(
        id: _uuid.v4(),
        type: InsightType.celebration,
        title: '30-Day Milestone! 🏆',
        message: 'A full month of wellness. This is extraordinary commitment.',
        confidence: 0.98,
        evidence: [
          Evidence(
              source: 'Streak',
              description: '$streakDays consecutive days',
              weight: 0.8),
          const Evidence(
              source: 'Science',
              description: '30 days is enough to rewire neural pathways',
              weight: 0.2),
        ],
        expiresAt: now.add(const Duration(days: 1)),
        domain: 'streak',
        category: 'milestone',
      ));
    }

    return insights;
  }

  List<AIInsight> _generateWarnings(
      PersonalizationContext ctx,
      WellnessScore? score,
      int sleepHours,
      int consecutiveBadSleep,
      int screenTimeHours,
      int waterGlasses,
      DateTime now) {
    final insights = <AIInsight>[];

    if (screenTimeHours > 7) {
      insights.add(AIInsight(
        id: _uuid.v4(),
        type: InsightType.warning,
        title: 'High screen time',
        message:
            'You\'ve been on screens for $screenTimeHours hours. Consider taking a digital detox break.',
        confidence: _confidence.calculate(
            dataQuality: 0.9,
            patternStrength: screenTimeHours / 12,
            consistency: 0.7,
            recency: 1.0),
        evidence: [
          Evidence(
              source: 'Screen Time',
              description: '$screenTimeHours hours today',
              weight: 0.6),
          const Evidence(
              source: 'Research',
              description: 'Excessive screen time linked to increased anxiety',
              weight: 0.4),
        ],
        recommendation: Recommendation(
          id: _uuid.v4(),
          action: 'Walk',
          detail: 'Take a 10-minute screen-free walk',
          route: '/home/yoga',
          expectedImpacts:
              _estimateImpact('walk', currentEnergy: 5, currentStress: 5),
          domain: 'screen_time',
        ),
        expectedImpact: 0.3,
        expiresAt: now.add(const Duration(hours: 3)),
        domain: 'screen_time',
        category: 'warning',
      ));
    }

    if (waterGlasses < 4) {
      insights.add(AIInsight(
        id: _uuid.v4(),
        type: InsightType.reminder,
        title: 'Hydration check',
        message:
            'You\'ve only had $waterGlasses glasses of water today. Aim for 8.',
        confidence: _confidence.calculate(
            dataQuality: 0.9,
            patternStrength: 0.6,
            consistency: 0.5,
            recency: 1.0),
        evidence: [
          Evidence(
              source: 'Water Intake',
              description: '$waterGlasses glasses today',
              weight: 0.7),
          const Evidence(
              source: 'Health',
              description: 'Dehydration causes fatigue and brain fog',
              weight: 0.3),
        ],
        recommendation: Recommendation(
          id: _uuid.v4(),
          action: 'Hydrate',
          detail: 'Drink a glass of water now',
          route: '/home/nutrition',
          expectedImpacts: _estimateImpact('hydrate', currentEnergy: 5),
          domain: 'hydration',
        ),
        expectedImpact: 0.2,
        expiresAt: now.add(const Duration(hours: 2)),
        domain: 'hydration',
        category: 'reminder',
      ));
    }

    return insights;
  }

  List<AIInsight> _generatePredictions(List<DetectedPattern> patterns,
      PersonalizationContext ctx, WellnessScore? score, DateTime now) {
    final insights = <AIInsight>[];

    final hasSleepPattern = patterns
        .any((p) => p.category == 'threshold' && p.id == 'poor_sleep_streak');
    final hasEveningStressPattern = patterns.any((p) =>
        p.category == 'day_of_week' &&
        p.id.contains('low_mood') &&
        ((p.metadata['day'] as int?) == DateTime.now().weekday));

    if (!hasSleepPattern && ctx.moodTrend == 'declining') {
      final moodDeclineConfidence = _confidence.calculate(
          dataQuality: 0.6,
          patternStrength: 0.7,
          consistency: 0.6,
          recency: 0.8);
      if (moodDeclineConfidence > 0.3) {
        insights.add(AIInsight(
          id: _uuid.v4(),
          type: InsightType.prediction,
          title: 'Mood may continue declining without intervention',
          message:
              'Your mood has been trending downward. Early intervention with meditation or journaling could reverse this.',
          confidence: moodDeclineConfidence,
          evidence: [
            const Evidence(
                source: 'Mood Trend',
                description: 'Mood decreasing over recent entries',
                weight: 0.45),
            const Evidence(
                source: 'History',
                description: 'Previous declines reversed with mindfulness',
                weight: 0.35),
            const Evidence(
                source: 'Journal',
                description: 'Negative patterns detected',
                weight: 0.2),
          ],
          recommendation: Recommendation(
            id: _uuid.v4(),
            action: 'Journal',
            detail: 'Write a gratitude entry to shift perspective',
            route: '/home/journal',
            expectedImpacts: _estimateImpact('gratitude',
                currentMood: score?.mood.round() ?? 3),
            domain: 'mood',
          ),
          expectedImpact: 0.25,
          expiresAt: now.add(const Duration(hours: 6)),
          domain: 'mood',
          category: 'prediction',
        ));
      }
    }

    if (hasEveningStressPattern) {
      insights.add(AIInsight(
        id: _uuid.v4(),
        type: InsightType.prediction,
        title: 'Evening stress expected',
        message:
            'Your stress typically increases on ${_dayName(DateTime.now().weekday)} evenings. Consider a preemptive breathing session.',
        confidence: _confidence.calculate(
            dataQuality: 0.7,
            patternStrength: 0.8,
            consistency: 0.75,
            recency: 0.5),
        evidence: [
          const Evidence(
              source: 'Historical Pattern',
              description: 'Stress peaks weekly on this day',
              weight: 0.5),
          const Evidence(
              source: 'Mood',
              description: 'Average mood lower on this day',
              weight: 0.3),
          const Evidence(
              source: 'Recommendation',
              description: 'Previous breathing sessions have helped',
              weight: 0.2),
        ],
        recommendation: Recommendation(
          id: _uuid.v4(),
          action: 'Breathing',
          detail: 'Schedule a 5-minute Box Breathing at 6 PM',
          route: '/home/meditation/breathing',
          expectedImpacts:
              _estimateImpact('breathing', currentStress: 7, currentMood: 3),
          domain: 'stress',
        ),
        expectedImpact: 0.3,
        expiresAt: DateTime(now.year, now.month, now.day, 20),
        domain: 'stress',
        category: 'prediction',
      ));
    }

    return insights;
  }

  List<AIInsight> _generateRecommendations(PersonalizationContext ctx,
      WellnessScore? score, List<DetectedPattern> patterns, DateTime now) {
    final insights = <AIInsight>[];
    final domain = ctx.primaryDomain ?? '';

    if (domain.contains('stress') || domain.contains('anxiety')) {
      const timeSinceLastBreathing = 24;
      if (timeSinceLastBreathing > 4) {
        insights.add(AIInsight(
          id: _uuid.v4(),
          type: InsightType.recommendation,
          title: 'Time for a breathing break',
          message:
              'Your primary domain is stress management. A quick breathing exercise can lower cortisol in minutes.',
          confidence: _confidence.calculate(
              dataQuality: 0.8,
              patternStrength: 0.7,
              consistency: 0.6,
              recency: 0.9),
          evidence: [
            const Evidence(
                source: 'Domain',
                description: 'Stress is your primary wellness concern',
                weight: 0.4),
            const Evidence(
                source: 'Effectiveness',
                description:
                    'Breathing exercises reduce stress by 30% on average',
                weight: 0.35),
            const Evidence(
                source: 'Recency',
                description:
                    'Last breathing session was over $timeSinceLastBreathing hours ago',
                weight: 0.25),
          ],
          recommendation: Recommendation(
            id: _uuid.v4(),
            action: 'Breathing',
            detail: '5-Minute Box Breathing',
            route: '/home/meditation/breathing',
            expectedImpacts: _estimateImpact('breathing',
                currentStress: score?.mood.round() ?? 5),
            domain: 'stress',
          ),
          expectedImpact: 0.35,
          expiresAt: now.add(const Duration(hours: 2)),
          domain: 'stress',
          category: 'recommendation',
        ));
      }
    }

    if (ctx.moodEntryCount >= 3) {
      insights.add(AIInsight(
        id: _uuid.v4(),
        type: InsightType.recommendation,
        title: 'Journal to process your week',
        message:
            'With several mood entries logged, a journal entry could help you identify patterns.',
        confidence: _confidence.calculate(
            dataQuality: 0.7,
            patternStrength: 0.6,
            consistency: 0.5,
            recency: 0.8),
        evidence: [
          Evidence(
              source: 'Mood History',
              description: '${ctx.moodEntryCount} mood entries logged',
              weight: 0.5),
          const Evidence(
              source: 'Journal',
              description: 'Journaling improves emotional processing',
              weight: 0.3),
          Evidence(
              source: 'Trend',
              description: ctx.moodTrend == 'declining'
                  ? 'Mood declining — journaling can help'
                  : 'Consistent logging shows engagement',
              weight: 0.2),
        ],
        recommendation: Recommendation(
          id: _uuid.v4(),
          action: 'Journal',
          detail: ctx.moodTrend == 'declining'
              ? 'Try a gratitude entry to shift perspective'
              : 'Write a free-form reflection',
          route: '/home/journal',
          expectedImpacts:
              _estimateImpact('journal', currentMood: score?.mood.round() ?? 3),
          domain: 'journal',
        ),
        expectedImpact: 0.25,
        expiresAt: now.add(const Duration(days: 1)),
        domain: 'journal',
        category: 'recommendation',
      ));
    }

    return insights;
  }

  List<AIInsight> _generateCelebrations(
      PersonalizationContext ctx,
      int streakDays,
      int habitsCompleted,
      List<JournalEntry> entries,
      DateTime now) {
    final insights = <AIInsight>[];

    if (habitsCompleted >= 4) {
      insights.add(AIInsight(
        id: _uuid.v4(),
        type: InsightType.celebration,
        title: 'Great habit day!',
        message:
            'You\'ve completed $habitsCompleted habits today. That\'s impressive consistency.',
        confidence: _confidence.calculate(
            dataQuality: 1.0,
            patternStrength: 0.8,
            consistency: 0.9,
            recency: 1.0),
        evidence: [
          Evidence(
              source: 'Habits',
              description: '$habitsCompleted habits completed today',
              weight: 0.6),
          const Evidence(
              source: 'Impact',
              description: 'Daily habits compound into lasting change',
              weight: 0.4),
        ],
        expiresAt: now.add(const Duration(hours: 6)),
        domain: 'habits',
        category: 'celebration',
      ));
    }

    return insights;
  }

  List<AIInsight> _generateReminders(
      PersonalizationContext ctx, WellnessScore? score, DateTime now) {
    final insights = <AIInsight>[];
    final hour = now.hour;

    final sleepScore = score?.sleep;
    if (hour >= 20 && sleepScore != null && sleepScore < 60) {
      insights.add(AIInsight(
        id: _uuid.v4(),
        type: InsightType.reminder,
        title: 'Time to wind down',
        message:
            'It\'s getting late. Starting your wind-down routine now will improve your sleep quality.',
        confidence: _confidence.calculate(
            dataQuality: 0.9,
            patternStrength: 0.7,
            consistency: 0.6,
            recency: 1.0),
        evidence: [
          Evidence(
              source: 'Time',
              description: 'Current time is $hour:00',
              weight: 0.4),
          Evidence(
              source: 'Sleep Score',
              description: 'Sleep score is ${sleepScore.round()}/100',
              weight: 0.35),
          const Evidence(
              source: 'Circadian Rhythm',
              description: 'Consistent bedtime improves sleep quality',
              weight: 0.25),
        ],
        recommendation: Recommendation(
          id: _uuid.v4(),
          action: 'Sleep',
          detail: 'Start your wind-down: phone away, dim lights, meditate',
          route: '/home/sleep',
          expectedImpacts:
              _estimateImpact('sleep', currentSleep: sleepScore.round()),
          domain: 'sleep',
        ),
        expectedImpact: 0.3,
        expiresAt: DateTime(now.year, now.month, now.day, 23),
        domain: 'sleep',
        category: 'reminder',
      ));
    }

    return insights;
  }

  String _dayName(int? weekday) {
    if (weekday == null) return 'Today';
    const names = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return names[weekday.clamp(1, 7)];
  }

  String _capitalize(dynamic value) {
    final s = value?.toString() ?? '';
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
