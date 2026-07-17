import '../models/recommendation.dart';

class ImpactEngine {
  static const _defaultImpacts = <String, List<ExpectedImpact>>{
    'breathing': [
      ExpectedImpact(
          metric: 'stress',
          change: 12,
          direction: 'decrease',
          description: 'Reduce stress score'),
      ExpectedImpact(
          metric: 'calm',
          change: 15,
          direction: 'increase',
          description: 'Increase calmness'),
    ],
    'meditation': [
      ExpectedImpact(
          metric: 'mood',
          change: 8,
          direction: 'increase',
          description: 'Improve mood'),
      ExpectedImpact(
          metric: 'anxiety',
          change: 10,
          direction: 'decrease',
          description: 'Reduce anxiety'),
    ],
    'journal': [
      ExpectedImpact(
          metric: 'clarity',
          change: 15,
          direction: 'increase',
          description: 'Improve mental clarity'),
      ExpectedImpact(
          metric: 'mood',
          change: 5,
          direction: 'increase',
          description: 'Lift mood through expression'),
    ],
    'walk': [
      ExpectedImpact(
          metric: 'energy',
          change: 10,
          direction: 'increase',
          description: 'Boost energy'),
      ExpectedImpact(
          metric: 'stress',
          change: 8,
          direction: 'decrease',
          description: 'Reduce stress'),
    ],
    'sleep': [
      ExpectedImpact(
          metric: 'sleep',
          change: 15,
          direction: 'increase',
          description: 'Improve sleep quality'),
      ExpectedImpact(
          metric: 'mood',
          change: 10,
          direction: 'increase',
          description: 'Better mood from rest'),
    ],
    'music': [
      ExpectedImpact(
          metric: 'relaxation',
          change: 12,
          direction: 'increase',
          description: 'Increase relaxation'),
      ExpectedImpact(
          metric: 'anxiety',
          change: 8,
          direction: 'decrease',
          description: 'Calm anxious thoughts'),
    ],
    'hydrate': [
      ExpectedImpact(
          metric: 'energy',
          change: 8,
          direction: 'increase',
          description: 'Improve energy'),
      ExpectedImpact(
          metric: 'focus',
          change: 5,
          direction: 'increase',
          description: 'Sharpen focus'),
    ],
    'gratitude': [
      ExpectedImpact(
          metric: 'mood',
          change: 10,
          direction: 'increase',
          description: 'Elevate mood'),
      ExpectedImpact(
          metric: 'optimism',
          change: 12,
          direction: 'increase',
          description: 'Build optimism'),
    ],
    'goals': [
      ExpectedImpact(
          metric: 'motivation',
          change: 10,
          direction: 'increase',
          description: 'Boost motivation'),
      ExpectedImpact(
          metric: 'confidence',
          change: 8,
          direction: 'increase',
          description: 'Build confidence'),
    ],
    'stretch': [
      ExpectedImpact(
          metric: 'energy',
          change: 8,
          direction: 'increase',
          description: 'Release physical tension'),
      ExpectedImpact(
          metric: 'stress',
          change: 5,
          direction: 'decrease',
          description: 'Ease physical stress'),
    ],
  };

  List<ExpectedImpact> estimate(
    String action, {
    String? domain,
    String? primaryConcern,
    int currentStress = 5,
    int currentMood = 3,
    int currentSleep = 7,
    int currentEnergy = 5,
    int currentAnxiety = 5,
  }) {
    final base = _defaultImpacts[action] ?? _defaultImpacts['meditation']!;

    return base.map((impact) {
      var adjustedChange = impact.change;

      if (impact.metric == 'stress' || impact.direction == 'decrease') {
        if (currentStress >= 7) {
          adjustedChange = (adjustedChange * 1.3).round().toDouble();
        } else if (currentStress >= 5) {
          adjustedChange = (adjustedChange * 1.15).round().toDouble();
        } else if (currentStress <= 3) {
          adjustedChange = (adjustedChange * 0.7).round().toDouble();
        }
      }

      if (impact.metric == 'mood' ||
          impact.metric == 'calm' ||
          impact.metric == 'energy') {
        if (currentMood <= 2) {
          adjustedChange = (adjustedChange * 1.2).round().toDouble();
        } else if (currentMood >= 4) {
          adjustedChange = (adjustedChange * 0.8).round().toDouble();
        }
      }

      if (impact.metric == 'sleep') {
        if (currentSleep <= 5) {
          adjustedChange = (adjustedChange * 1.25).round().toDouble();
        } else if (currentSleep >= 8) {
          adjustedChange = (adjustedChange * 0.6).round().toDouble();
        }
      }

      if (impact.metric == 'energy') {
        if (currentEnergy <= 3) {
          adjustedChange = (adjustedChange * 1.2).round().toDouble();
        }
      }

      if (impact.metric == 'anxiety') {
        if (currentAnxiety >= 7) {
          adjustedChange = (adjustedChange * 1.3).round().toDouble();
        } else if (currentAnxiety <= 3) {
          adjustedChange = (adjustedChange * 0.6).round().toDouble();
        }
      }

      if (domain != null && primaryConcern != null) {
        if (impact.metric == primaryConcern.toLowerCase()) {
          adjustedChange = (adjustedChange * 1.2).round().toDouble();
        }
      }

      return ExpectedImpact(
        metric: impact.metric,
        change: adjustedChange.clamp(1, 40).toDouble(),
        direction: impact.direction,
        description: impact.description,
      );
    }).toList();
  }

  List<ExpectedImpact> aggregate(
      List<RecommendationOutcome> outcomes, String action) {
    final relevant = outcomes.where((o) =>
        o.completed && o.beforeMetrics.isNotEmpty && o.afterMetrics.isNotEmpty);
    if (relevant.isEmpty) return _defaultImpacts[action] ?? [];

    final metricChanges = <String, List<double>>{};
    for (final outcome in relevant) {
      for (final entry in outcome.afterMetrics.entries) {
        final before = outcome.beforeMetrics[entry.key] ?? 0;
        if (before == 0) continue;
        final change = ((entry.value - before) / before * 100).abs();
        metricChanges.putIfAbsent(entry.key, () => []).add(change);
      }
    }

    return metricChanges.entries.map((e) {
      final avg = e.value.fold(0.0, (a, b) => a + b) / e.value.length;
      return ExpectedImpact(
        metric: e.key,
        change: avg.roundToDouble(),
        direction: avg >= 0 ? 'increase' : 'decrease',
        description: 'Based on ${e.value.length} previous outcomes',
      );
    }).toList();
  }
}
