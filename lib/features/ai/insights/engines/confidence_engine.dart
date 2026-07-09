import 'dart:math';

class ConfidenceEngine {
  double calculate({
    required double dataQuality,
    required double patternStrength,
    required double consistency,
    required double recency,
  }) {
    final score = dataQuality * patternStrength * consistency * recency;
    return score.clamp(0.0, 1.0);
  }

  double scoreDataQuality(int dataPointsCount, int minRequired) {
    if (dataPointsCount >= minRequired) return 1.0;
    if (dataPointsCount <= 0) return 0.0;
    return (dataPointsCount / minRequired).clamp(0.0, 1.0);
  }

  double scorePatternStrength(double effectSize) {
    return effectSize.clamp(0.0, 1.0);
  }

  double scoreConsistency(double consistentRatio) {
    return consistentRatio.clamp(0.0, 1.0);
  }

  double scoreRecency(DateTime lastDataPoint) {
    final hoursSince = DateTime.now().difference(lastDataPoint).inHours;
    if (hoursSince <= 24) return 1.0;
    if (hoursSince <= 72) return 0.8;
    if (hoursSince <= 168) return 0.5;
    if (hoursSince <= 720) return 0.3;
    return 0.1;
  }

  double scoreTrendDirection(List<double> values) {
    if (values.length < 3) return 0.3;
    final first = values.first;
    final last = values.last;
    if (first == last) return 0.5;
    final change = (last - first) / first.abs();
    return (change.abs()).clamp(0.0, 1.0);
  }

  double scoreCorrelation(List<double> xs, List<double> ys) {
    if (xs.length < 3 || ys.length < 3) return 0.0;
    final n = xs.length;
    final sumX = xs.fold(0.0, (a, b) => a + b);
    final sumY = ys.fold(0.0, (a, b) => a + b);
    final sumXY = _zip(xs, ys).fold(0.0, (a, p) => a + p.$1 * p.$2);
    final sumX2 = xs.fold(0.0, (a, b) => a + b * b);
    final sumY2 = ys.fold(0.0, (a, b) => a + b * b);

    final numerator = n * sumXY - sumX * sumY;
    final denom = (n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY);
    if (denom <= 0) return 0.0;
    final r = numerator / sqrt(denom);
    return r.abs().clamp(0.0, 1.0);
  }

  double scoreDayOfWeekPattern(List<int> dayValues) {
    if (dayValues.length < 14) return 0.2;
    final week1 = dayValues.take(7).toList();
    final week2 = dayValues.skip(7).take(7).toList();
    if (week1.length < 7 || week2.length < 7) return 0.2;
    var matchCount = 0;
    for (var i = 0; i < 7; i++) {
      if (week1[i] == week2[i]) matchCount++;
    }
    return (matchCount / 7).clamp(0.0, 1.0);
  }

  double scoreThreshold(int thresholdViolations, int totalObservations) {
    if (totalObservations == 0) return 0.0;
    final ratio = thresholdViolations / totalObservations;
    return (ratio * 2).clamp(0.0, 1.0);
  }

  List<(double, double)> _zip(List<double> a, List<double> b) {
    final len = a.length < b.length ? a.length : b.length;
    final result = <(double, double)>[];
    for (var i = 0; i < len; i++) {
      result.add((a[i], b[i]));
    }
    return result;
  }
}
