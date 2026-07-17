// lib/services/ai/weekly_summary_engine.dart
import 'package:flutter/foundation.dart';
import 'package:mental_mantra/core/storage/hive_storage.dart';

/// Model representing a generated weekly wellness summary.
class WeeklySummary {
  final String weekLabel;
  final double avgMoodScore;
  final String moodTrend;
  final int meditationSessions;
  final int journalEntries;
  final int moodCheckIns;
  final List<String> topInsights;
  final List<String> improvementSuggestions;
  final String overallAssessment;
  final DateTime generatedAt;

  const WeeklySummary({
    required this.weekLabel,
    required this.avgMoodScore,
    required this.moodTrend,
    required this.meditationSessions,
    required this.journalEntries,
    required this.moodCheckIns,
    required this.topInsights,
    required this.improvementSuggestions,
    required this.overallAssessment,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'weekLabel': weekLabel,
        'avgMoodScore': avgMoodScore,
        'moodTrend': moodTrend,
        'meditationSessions': meditationSessions,
        'journalEntries': journalEntries,
        'moodCheckIns': moodCheckIns,
        'topInsights': topInsights,
        'improvementSuggestions': improvementSuggestions,
        'overallAssessment': overallAssessment,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory WeeklySummary.fromJson(Map<String, dynamic> json) => WeeklySummary(
        weekLabel: json['weekLabel'] as String? ?? '',
        avgMoodScore: (json['avgMoodScore'] as num?)?.toDouble() ?? 3.0,
        moodTrend: json['moodTrend'] as String? ?? 'stable',
        meditationSessions: json['meditationSessions'] as int? ?? 0,
        journalEntries: json['journalEntries'] as int? ?? 0,
        moodCheckIns: json['moodCheckIns'] as int? ?? 0,
        topInsights: List<String>.from(json['topInsights'] as List? ?? []),
        improvementSuggestions:
            List<String>.from(json['improvementSuggestions'] as List? ?? []),
        overallAssessment: json['overallAssessment'] as String? ?? '',
        generatedAt: DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

/// Generates local weekly wellness summaries from stored data.
/// Does not require network access — works fully offline.
class WeeklySummaryEngine {
  static const String _boxName = 'weekly_summaries_box';
  static const String _summariesKey = 'summaries';

  /// Generate and persist the weekly summary for the current week.
  Future<WeeklySummary> generateCurrentWeekSummary() async {
    try {
      final moods = await HiveStorage.getRecentMoods(days: 7);
      final meditationBox =
          await HiveStorage.openBox(HiveStorage.meditationBoxName);
      final journalBox = await HiveStorage.openBox(HiveStorage.journalBoxName);

      // Mood analysis
      final moodValues = moods
          .map((m) =>
              (m['mood'] as num?)?.toDouble() ??
              (m['value'] as num?)?.toDouble() ??
              3.0)
          .toList();
      final avgMood = moodValues.isEmpty
          ? 3.0
          : moodValues.reduce((a, b) => a + b) / moodValues.length;
      final moodTrend = _computeTrend(moodValues);

      // Activity counts (approximate from box lengths - entries added this week)
      final meditationCount = meditationBox.length.clamp(0, 999);
      final journalCount = journalBox.length.clamp(0, 999);

      final insights = _generateInsights(
          avgMood, moodTrend, meditationCount, journalCount, moods.length);
      final suggestions = _generateSuggestions(
          avgMood, meditationCount, journalCount, moods.length);
      final assessment =
          _generateAssessment(avgMood, moodTrend, meditationCount);

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final summary = WeeklySummary(
        weekLabel: 'Week of ${_formatDate(weekStart)}',
        avgMoodScore: avgMood,
        moodTrend: moodTrend,
        meditationSessions: meditationCount,
        journalEntries: journalCount,
        moodCheckIns: moods.length,
        topInsights: insights,
        improvementSuggestions: suggestions,
        overallAssessment: assessment,
        generatedAt: now,
      );

      await _saveSummary(summary);
      return summary;
    } catch (e) {
      debugPrint('[WeeklySummaryEngine] generateCurrentWeekSummary error: $e');
      return WeeklySummary(
        weekLabel: 'This Week',
        avgMoodScore: 3.0,
        moodTrend: 'stable',
        meditationSessions: 0,
        journalEntries: 0,
        moodCheckIns: 0,
        topInsights: ['Keep tracking your mood to get personalized insights.'],
        improvementSuggestions: [
          'Try logging your mood daily for better pattern detection.'
        ],
        overallAssessment:
            'Start your wellness journey by tracking your mood every day.',
        generatedAt: DateTime.now(),
      );
    }
  }

  /// Load the most recent saved weekly summaries.
  Future<List<WeeklySummary>> getRecentSummaries({int count = 4}) async {
    try {
      final box = await HiveStorage.openBox(_boxName);
      final raw = box.get(_summariesKey);
      if (raw == null) return [];
      final list = raw as List? ?? [];
      return list
          .map((e) =>
              WeeklySummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .take(count)
          .toList();
    } catch (e) {
      debugPrint('[WeeklySummaryEngine] getRecentSummaries error: $e');
      return [];
    }
  }

  Future<void> _saveSummary(WeeklySummary summary) async {
    final box = await HiveStorage.openBox(_boxName);
    final existing = (box.get(_summariesKey) as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    existing.insert(0, summary.toJson());
    if (existing.length > 12) existing.removeRange(12, existing.length);
    await box.put(_summariesKey, existing);
  }

  String _computeTrend(List<double> values) {
    if (values.length < 2) return 'stable';
    final first = values.first;
    final last = values.last;
    if (last - first > 0.5) return 'improving';
    if (first - last > 0.5) return 'declining';
    return 'stable';
  }

  List<String> _generateInsights(
    double avgMood,
    String trend,
    int meditationCount,
    int journalCount,
    int moodCheckIns,
  ) {
    final insights = <String>[];
    if (avgMood >= 4.0) {
      insights.add(
          'Great week! Your average mood was above 4/5. Keep up the positive momentum.');
    } else if (avgMood >= 3.0) {
      insights.add(
          'Moderate week with an average mood of ${avgMood.toStringAsFixed(1)}/5. Room for improvement!');
    } else {
      insights.add(
          'This was a challenging week. Your mood averaged ${avgMood.toStringAsFixed(1)}/5. Be gentle with yourself.');
    }
    if (trend == 'improving') {
      insights.add(
          'Your mood trend is improving — you\'re heading in the right direction!');
    } else if (trend == 'declining') {
      insights.add(
          'Your mood has been declining this week. It might be time to check in with Nova for support.');
    }
    if (meditationCount >= 5) {
      insights.add(
          'Excellent meditation consistency! $meditationCount sessions this week.');
    } else if (meditationCount == 0) {
      insights.add(
          'No meditation sessions logged this week. Even 5 minutes a day can make a big difference.');
    }
    if (journalCount >= 3) {
      insights.add(
          'Great journaling habit! Writing $journalCount entries helps process emotions effectively.');
    }
    if (moodCheckIns >= 5) {
      insights.add(
          'Excellent mood tracking — $moodCheckIns check-ins this week gives great self-awareness data.');
    }
    return insights.isEmpty
        ? ['Keep using Mental Mantra daily to unlock personalized insights!']
        : insights;
  }

  List<String> _generateSuggestions(
      double avgMood, int meditationCount, int journalCount, int moodCheckIns) {
    final suggestions = <String>[];
    if (meditationCount < 3) {
      suggestions.add(
          'Try to complete at least 3 meditation sessions next week for stress relief.');
    }
    if (journalCount < 2) {
      suggestions.add(
          'Aim for 2-3 journal entries next week to deepen self-reflection.');
    }
    if (moodCheckIns < 5) {
      suggestions.add(
          'Log your mood at least once a day next week for better pattern analysis.');
    }
    if (avgMood < 3.0) {
      suggestions.add(
          'Practice the 4-7-8 breathing technique when you feel low — it\'s available in the Breathing Trainer.');
      suggestions.add(
          'Consider talking to Nova about what\'s been weighing on you this week.');
    }
    return suggestions.isEmpty
        ? ['You\'re doing great! Keep your current routine going.']
        : suggestions;
  }

  String _generateAssessment(
      double avgMood, String trend, int meditationCount) {
    if (avgMood >= 4.0 && trend != 'declining') {
      return 'You had a strong week! Your mood and consistency are both positive. Keep building on this foundation.';
    }
    if (avgMood >= 3.0 && meditationCount >= 3) {
      return 'A solid week with consistent mindfulness practice. Your mood was stable — great foundation to build on.';
    }
    if (avgMood < 3.0) {
      return 'It was a tough week, but you showed up and tracked your wellness. That takes courage. '
          'Nova is here to support you — don\'t hesitate to reach out.';
    }
    return 'Every week is a new opportunity for growth. Keep showing up for your mental wellness journey.';
  }

  String _formatDate(DateTime date) => '${_monthName(date.month)} ${date.day}';

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month.clamp(1, 12)];
  }
}
