// lib/services/ai/mood_intelligence_engine.dart
import 'package:flutter/foundation.dart';
import 'package:mental_mantra/core/storage/hive_storage.dart';

/// Detected mood pattern.
class MoodPattern {
  final String label;
  final String description;
  final String icon;
  final String severity; // 'low', 'moderate', 'high'

  const MoodPattern({
    required this.label,
    required this.description,
    required this.icon,
    required this.severity,
  });
}

/// Identified stress or emotion trigger.
class EmotionTrigger {
  final String trigger;
  final String category;
  final int frequency;
  final List<String> associatedMoodValues;

  const EmotionTrigger({
    required this.trigger,
    required this.category,
    required this.frequency,
    required this.associatedMoodValues,
  });
}

/// Heatmap data point for a single day.
class MoodHeatmapPoint {
  final DateTime date;
  final double moodValue; // 1.0 - 5.0
  final String? dominantEmotion;

  const MoodHeatmapPoint({
    required this.date,
    required this.moodValue,
    this.dominantEmotion,
  });
}

/// Full mood intelligence report for a period.
class MoodIntelligenceReport {
  final String periodLabel;
  final double averageMood;
  final double stressIndex; // 0 - 10
  final double stabilityScore; // 0 - 100
  final List<MoodPattern> detectedPatterns;
  final List<EmotionTrigger> triggers;
  final List<MoodHeatmapPoint> heatmapData;
  final List<String> aiSuggestions;
  final List<String> improvements;
  final String summary;
  final DateTime generatedAt;

  const MoodIntelligenceReport({
    required this.periodLabel,
    required this.averageMood,
    required this.stressIndex,
    required this.stabilityScore,
    required this.detectedPatterns,
    required this.triggers,
    required this.heatmapData,
    required this.aiSuggestions,
    required this.improvements,
    required this.summary,
    required this.generatedAt,
  });
}

/// Analyzes mood history to detect patterns, triggers, and generate AI insights.
/// Runs locally on-device — no network required.
class MoodIntelligenceEngine {
  /// Generate a report from the last [days] days of mood data.
  Future<MoodIntelligenceReport> generateReport({int days = 30}) async {
    try {
      final moods = await HiveStorage.getRecentMoods(days: days);
      final periodLabel = days == 7
          ? 'Last 7 Days'
          : days == 30
              ? 'Last 30 Days'
              : 'Last $days Days';

      if (moods.isEmpty) {
        return _emptyReport(periodLabel);
      }

      final moodValues = moods
          .map((m) =>
              (m['mood'] as num?)?.toDouble() ??
              (m['value'] as num?)?.toDouble() ??
              3.0)
          .toList();

      final avgMood = moodValues.reduce((a, b) => a + b) / moodValues.length;
      final stressIndex = _computeStressIndex(moods);
      final stability = _computeStability(moodValues);
      final patterns = _detectPatterns(moodValues, moods);
      final triggers = _extractTriggers(moods);
      final heatmap = _buildHeatmap(moods);
      final suggestions =
          _generateSuggestions(avgMood, stressIndex, stability, patterns);
      final improvements = _detectImprovements(moodValues);
      final summary =
          _generateSummary(avgMood, stressIndex, stability, patterns);

      return MoodIntelligenceReport(
        periodLabel: periodLabel,
        averageMood: avgMood,
        stressIndex: stressIndex,
        stabilityScore: stability,
        detectedPatterns: patterns,
        triggers: triggers,
        heatmapData: heatmap,
        aiSuggestions: suggestions,
        improvements: improvements,
        summary: summary,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[MoodIntelligenceEngine] generateReport error: $e');
      return _emptyReport('Report');
    }
  }

  // ── Private Analysis Methods ────────────────────────────────────────

  double _computeStressIndex(List<Map<String, dynamic>> moods) {
    if (moods.isEmpty) return 5.0;
    // Stress index derived from stress_level field if present; else infer from low moods
    final stressValues = moods
        .map((m) =>
            (m['stressLevel'] as num?)?.toDouble() ??
            (m['stress_level'] as num?)?.toDouble())
        .whereType<double>()
        .toList();
    if (stressValues.isNotEmpty) {
      return stressValues.reduce((a, b) => a + b) / stressValues.length;
    }
    // Infer: low mood (1-2) correlates with high stress
    final moodVals = moods
        .map((m) =>
            (m['mood'] as num?)?.toDouble() ??
            (m['value'] as num?)?.toDouble() ??
            3.0)
        .toList();
    final avgMood = moodVals.reduce((a, b) => a + b) / moodVals.length;
    return ((5.0 - avgMood) * 2.0).clamp(0.0, 10.0);
  }

  double _computeStability(List<double> values) {
    if (values.length < 2) return 80.0;
    // Stability = 100 minus the average day-to-day variation scaled to 0-100
    double totalVariation = 0;
    for (int i = 1; i < values.length; i++) {
      totalVariation += (values[i] - values[i - 1]).abs();
    }
    final avgVariation = totalVariation / (values.length - 1);
    return (100 - (avgVariation * 25)).clamp(0.0, 100.0);
  }

  List<MoodPattern> _detectPatterns(
      List<double> values, List<Map<String, dynamic>> moods) {
    final patterns = <MoodPattern>[];

    if (values.isEmpty) return patterns;

    final lowCount = values.where((v) => v <= 2).length;
    final highCount = values.where((v) => v >= 4).length;

    // Detect persistent low mood
    if (lowCount >= values.length * 0.5) {
      patterns.add(const MoodPattern(
        label: 'Persistent Low Mood',
        description:
            'More than half of your logged moods this period were low. This may signal burnout or depression.',
        icon: '📉',
        severity: 'high',
      ));
    }

    // Detect high volatility
    final stability = _computeStability(values);
    if (stability < 40) {
      patterns.add(const MoodPattern(
        label: 'Emotional Volatility',
        description:
            'Your mood has been fluctuating significantly. This can be a sign of stress or poor sleep.',
        icon: '📊',
        severity: 'moderate',
      ));
    }

    // Detect improving trend
    if (values.length >= 5) {
      final firstHalf = values.sublist(0, values.length ~/ 2);
      final secondHalf = values.sublist(values.length ~/ 2);
      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
      if (secondAvg - firstAvg > 0.7) {
        patterns.add(const MoodPattern(
          label: 'Improving Trend',
          description:
              'Your mood has been steadily improving. Your wellness practices are working!',
          icon: '📈',
          severity: 'low',
        ));
      } else if (firstAvg - secondAvg > 0.7) {
        patterns.add(const MoodPattern(
          label: 'Declining Trend',
          description:
              'Your mood has been declining recently. Consider reaching out to Nova for support.',
          icon: '⬇️',
          severity: 'moderate',
        ));
      }
    }

    // Detect consistently positive mood
    if (highCount >= values.length * 0.7) {
      patterns.add(const MoodPattern(
        label: 'Consistently Positive',
        description:
            'Most of your moods this period were positive — excellent mental wellness!',
        icon: '✨',
        severity: 'low',
      ));
    }

    // Detect stress pattern from tags
    final stressTags = moods
        .expand((m) => List<String>.from(m['tags'] as List? ?? []))
        .where((t) =>
            t.toLowerCase().contains('work') ||
            t.toLowerCase().contains('stress'))
        .length;
    if (stressTags > moods.length * 0.4) {
      patterns.add(const MoodPattern(
        label: 'Work-Related Stress',
        description:
            'Work and stress tags appear frequently in your low-mood entries. Consider work-life balance strategies.',
        icon: '💼',
        severity: 'moderate',
      ));
    }

    return patterns;
  }

  List<EmotionTrigger> _extractTriggers(List<Map<String, dynamic>> moods) {
    // Aggregate tags from low-mood entries to identify triggers
    final tagCounts = <String, int>{};
    for (final mood in moods) {
      final moodVal = (mood['mood'] as num?)?.toDouble() ??
          (mood['value'] as num?)?.toDouble() ??
          3.0;
      if (moodVal <= 2.5) {
        final tags = List<String>.from(mood['tags'] as List? ?? []);
        for (final tag in tags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
    }
    final sorted = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) {
      return EmotionTrigger(
        trigger: e.key,
        category: _categorizeTag(e.key),
        frequency: e.value,
        associatedMoodValues: ['Low', 'Very Low'],
      );
    }).toList();
  }

  String _categorizeTag(String tag) {
    final t = tag.toLowerCase();
    if (t.contains('work') || t.contains('career')) return 'Work';
    if (t.contains('family') || t.contains('relation')) return 'Relationships';
    if (t.contains('sleep') || t.contains('tired')) return 'Sleep';
    if (t.contains('health') || t.contains('pain')) return 'Health';
    if (t.contains('money') || t.contains('finance')) return 'Finance';
    if (t.contains('social') || t.contains('friend')) return 'Social';
    return 'General';
  }

  List<MoodHeatmapPoint> _buildHeatmap(List<Map<String, dynamic>> moods) {
    return moods.map((m) {
      final dateStr = m['date'] as String? ?? m['timestamp'] as String? ?? '';
      final date = DateTime.tryParse(dateStr) ?? DateTime.now();
      final value = (m['mood'] as num?)?.toDouble() ??
          (m['value'] as num?)?.toDouble() ??
          3.0;
      final tags = List<String>.from(m['tags'] as List? ?? []);
      return MoodHeatmapPoint(
        date: date,
        moodValue: value,
        dominantEmotion: tags.isNotEmpty ? tags.first : null,
      );
    }).toList();
  }

  List<String> _generateSuggestions(
    double avgMood,
    double stressIndex,
    double stability,
    List<MoodPattern> patterns,
  ) {
    final suggestions = <String>[];
    if (avgMood < 2.5) {
      suggestions.add(
          'Consider talking to a mental health professional. Nova can help you find resources.');
      suggestions.add(
          'Try the 5-4-3-2-1 grounding exercise when feeling overwhelmed (available in Emergency Mode).');
    } else if (avgMood < 3.5) {
      suggestions.add(
          'Incorporate a 10-minute morning meditation to set a positive tone for each day.');
      suggestions.add(
          'Journal your thoughts before bed to process the day\'s emotions.');
    }
    if (stressIndex > 6) {
      suggestions.add(
          'Your stress index is elevated. Try Box Breathing (4-4-4-4) when stress peaks.');
      suggestions.add(
          'Schedule "worry time" — a 15-minute window to address concerns, then let them go.');
    }
    if (stability < 50) {
      suggestions.add(
          'Try maintaining a consistent sleep schedule to stabilize your mood patterns.');
    }
    final hasLowPattern = patterns.any((p) => p.label == 'Persistent Low Mood');
    if (hasLowPattern) {
      suggestions.add(
          'Reach out to Nova for a supportive conversation — you don\'t have to face this alone.');
    }
    return suggestions.isEmpty
        ? [
            'You\'re maintaining good emotional balance. Keep up your current wellness practices!'
          ]
        : suggestions;
  }

  List<String> _detectImprovements(List<double> values) {
    if (values.length < 7) return [];
    final improvements = <String>[];
    final recentAvg = values.take(3).reduce((a, b) => a + b) / 3;
    final olderAvg = values.skip(values.length - 3).reduce((a, b) => a + b) / 3;
    if (recentAvg > olderAvg + 0.5) {
      improvements.add(
          'Your mood has improved by ${(recentAvg - olderAvg).toStringAsFixed(1)} points compared to the start of this period!');
    }
    return improvements;
  }

  String _generateSummary(double avgMood, double stressIndex, double stability,
      List<MoodPattern> patterns) {
    final moodLabel = avgMood >= 4.0
        ? 'excellent'
        : avgMood >= 3.0
            ? 'moderate'
            : 'challenging';
    final stressLabel = stressIndex >= 7
        ? 'high'
        : stressIndex >= 4
            ? 'moderate'
            : 'low';
    return 'Your emotional wellbeing this period has been $moodLabel, '
        'with a $stressLabel stress level and ${stability.toStringAsFixed(0)}% mood stability. '
        '${patterns.isEmpty ? 'No critical patterns detected.' : '${patterns.length} pattern(s) identified requiring attention.'}';
  }

  MoodIntelligenceReport _emptyReport(String label) => MoodIntelligenceReport(
        periodLabel: label,
        averageMood: 3.0,
        stressIndex: 5.0,
        stabilityScore: 80.0,
        detectedPatterns: [],
        triggers: [],
        heatmapData: [],
        aiSuggestions: [
          'Start logging your mood daily to unlock personalized AI insights.',
          'Even a 10-second mood check-in creates valuable data over time.',
        ],
        improvements: [],
        summary:
            'No mood data available for this period. Start your daily mood tracking to see insights here!',
        generatedAt: DateTime.now(),
      );
}
