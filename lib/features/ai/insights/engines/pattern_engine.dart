import '../../../journal/data/models/journal_entry.dart';

class DetectedPattern {
  final String id;
  final String name;
  final String description;
  final double strength;
  final String category;
  final Map<String, dynamic> metadata;

  const DetectedPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.strength,
    required this.category,
    this.metadata = const {},
  });
}

class PatternEngine {
  List<DetectedPattern> detectDayOfWeekPatterns(
      List<Map<String, dynamic>> moodHistory) {
    if (moodHistory.length < 7) return [];

    final dayMoods = <int, List<double>>{};
    for (final entry in moodHistory) {
      final ts = entry['timestamp'];
      final mood = (entry['mood'] as num?)?.toDouble();
      if (ts == null || mood == null) continue;
      DateTime dt;
      try {
        dt = (ts as dynamic).toDate();
      } catch (_) {
        dt = DateTime.parse(ts.toString());
      }
      dayMoods.putIfAbsent(dt.weekday, () => []).add(mood);
    }

    if (dayMoods.length < 3) return [];

    final patterns = <DetectedPattern>[];
    for (final entry in dayMoods.entries) {
      final avg = entry.value.fold(0.0, (a, b) => a + b) / entry.value.length;
      final dayName = _dayName(entry.key);
      if (avg <= 2.5) {
        patterns.add(DetectedPattern(
          id: 'low_mood_${entry.key}',
          name: 'Low mood on $dayName',
          description:
              '$dayName consistently shows lower mood (avg ${avg.toStringAsFixed(1)}/5)',
          strength: (1 - avg / 5).clamp(0.0, 1.0),
          category: 'day_of_week',
          metadata: {'day': entry.key, 'average': avg},
        ));
      } else if (avg >= 4.0) {
        patterns.add(DetectedPattern(
          id: 'high_mood_${entry.key}',
          name: 'High mood on $dayName',
          description:
              '$dayName consistently shows elevated mood (avg ${avg.toStringAsFixed(1)}/5)',
          strength: (avg / 5).clamp(0.0, 1.0),
          category: 'day_of_week',
          metadata: {'day': entry.key, 'average': avg},
        ));
      }
    }
    return patterns;
  }

  List<DetectedPattern> detectCorrelations({
    required List<Map<String, dynamic>> moodHistory,
    required List<JournalEntry> entries,
    required int meditationMinutes,
  }) {
    final patterns = <DetectedPattern>[];
    if (entries.length < 3 || moodHistory.length < 3) return patterns;

    final meditationDays = <DateTime>[];
    if (meditationMinutes > 0) {
      for (final entry in entries) {
        final day = DateTime(
            entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
        meditationDays.add(day);
      }
    }

    if (meditationDays.isNotEmpty) {
      final afterMeditationMoods = moodHistory
          .where((m) {
            final ts = m['timestamp'];
            if (ts == null) return false;
            DateTime dt;
            try {
              dt = (ts as dynamic).toDate();
            } catch (_) {
              dt = DateTime.parse(ts.toString());
            }
            return meditationDays
                .any((d) => dt.isAfter(d) && dt.difference(d).inHours <= 48);
          })
          .map((m) => (m['mood'] as num?)?.toDouble() ?? 3.0)
          .toList();

      if (afterMeditationMoods.isNotEmpty) {
        final allMoods = moodHistory
            .map((m) => (m['mood'] as num?)?.toDouble() ?? 3.0)
            .toList();
        final avgAfter = afterMeditationMoods.fold(0.0, (a, b) => a + b) /
            afterMeditationMoods.length;
        final avgAll = allMoods.fold(0.0, (a, b) => a + b) / allMoods.length;
        if (avgAfter > avgAll) {
          patterns.add(DetectedPattern(
            id: 'meditation_improves_mood',
            name: 'Meditation improves mood',
            description:
                'Mood averages ${avgAfter.toStringAsFixed(1)}/5 after meditation vs $avgAll/5 overall',
            strength: ((avgAfter - avgAll) / 5).clamp(0.0, 1.0),
            category: 'correlation',
            metadata: {'afterAverage': avgAfter, 'overallAverage': avgAll},
          ));
        }
      }
    }

    return patterns;
  }

  List<DetectedPattern> detectThresholdViolations({
    required int sleepHours,
    required int stress,
    required int anxiety,
    required int consecutiveBadSleep,
  }) {
    final patterns = <DetectedPattern>[];

    if (consecutiveBadSleep >= 3) {
      patterns.add(DetectedPattern(
        id: 'poor_sleep_streak',
        name: 'Multiple nights of poor sleep',
        description: '$consecutiveBadSleep consecutive nights below 6 hours',
        strength: (consecutiveBadSleep / 7).clamp(0.0, 1.0),
        category: 'threshold',
        metadata: {'consecutiveNights': consecutiveBadSleep, 'threshold': 3},
      ));
    }

    if (stress >= 8) {
      patterns.add(DetectedPattern(
        id: 'high_stress',
        name: 'Elevated stress detected',
        description: 'Current stress level is $stress/10',
        strength: (stress / 10).clamp(0.0, 1.0),
        category: 'threshold',
        metadata: {'value': stress, 'threshold': 8},
      ));
    }

    if (anxiety >= 7) {
      patterns.add(DetectedPattern(
        id: 'high_anxiety',
        name: 'High anxiety level',
        description: 'Current anxiety is $anxiety/10',
        strength: (anxiety / 10).clamp(0.0, 1.0),
        category: 'threshold',
        metadata: {'value': anxiety, 'threshold': 7},
      ));
    }

    return patterns;
  }

  List<DetectedPattern> detectTrends({
    required List<double> recentValues,
    required String metric,
    required int minPoints,
  }) {
    if (recentValues.length < minPoints) return [];

    final first = recentValues.first;
    final last = recentValues.last;
    final mid = recentValues[recentValues.length ~/ 2];

    final patterns = <DetectedPattern>[];
    final diff = last - first;

    if (diff > 0.5) {
      patterns.add(DetectedPattern(
        id: '${metric}_improving',
        name: '$metric improving',
        description: '$metric has been trending upward',
        strength: (diff / 5).clamp(0.0, 1.0),
        category: 'trend',
        metadata: {'metric': metric, 'change': diff, 'direction': 'up'},
      ));
    } else if (diff < -0.5) {
      patterns.add(DetectedPattern(
        id: '${metric}_declining',
        name: '$metric declining',
        description: '$metric has been trending downward',
        strength: (diff.abs() / 5).clamp(0.0, 1.0),
        category: 'trend',
        metadata: {'metric': metric, 'change': diff.abs(), 'direction': 'down'},
      ));
    }

    final recentSlope = last - mid;
    if (diff < -0.3 && recentSlope > 0) {
      patterns.add(DetectedPattern(
        id: '${metric}_reversing',
        name: '$metric showing signs of reversal',
        description:
            '$metric was declining but recent data suggests improvement',
        strength: (recentSlope / 5).clamp(0.0, 1.0),
        category: 'trend',
        metadata: {
          'metric': metric,
          'overallChange': diff,
          'recentChange': recentSlope
        },
      ));
    }

    return patterns;
  }

  List<DetectedPattern> detectAll({
    required List<Map<String, dynamic>> moodHistory,
    required List<JournalEntry> journalEntries,
    required int sleepHours,
    required int stress,
    required int anxiety,
    required int consecutiveBadSleep,
    required int meditationMinutes,
    required List<double> recentMoodValues,
    required List<double> recentSleepValues,
  }) {
    return [
      ...detectDayOfWeekPatterns(moodHistory),
      ...detectCorrelations(
        moodHistory: moodHistory,
        entries: journalEntries,
        meditationMinutes: meditationMinutes,
      ),
      ...detectThresholdViolations(
        sleepHours: sleepHours,
        stress: stress,
        anxiety: anxiety,
        consecutiveBadSleep: consecutiveBadSleep,
      ),
      ...detectTrends(
          recentValues: recentMoodValues, metric: 'mood', minPoints: 3),
      ...detectTrends(
          recentValues: recentSleepValues, metric: 'sleep', minPoints: 3),
    ];
  }

  String _dayName(int weekday) {
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
}
