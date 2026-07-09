import '../models/wellness_plan.dart';
import '../../../features/journal/data/models/journal_entry.dart' as journal;
import '../../../core/personalization/personalization_context.dart';

class ScoreEngine {
  static const _targetWaterGlasses = 8;

  WellnessScore compute(PersonalizationContext ctx, {
    required List<journal.JournalEntry> recentEntries,
    required int todayMood,
    required int sleepHours,
    required int waterGlasses,
    required int meditationMinutes,
    required int streakDays,
    required int screenTimeHours,
    required int aiChatCount,
    required double journalSentimentAvg,
    required int habitsCompleted,
    required int habitsTotal,
  }) {
    final moodScore = _scoreMood(todayMood, recentEntries);
    final sleepScore = _scoreSleep(sleepHours);
    final sentimentScore = _scoreJournalSentiment(journalSentimentAvg);
    final activityScore = _scoreActivity(ctx.currentStreak);
    final meditationScore = _scoreMeditation(meditationMinutes, streakDays);
    final hydrationScore = _scoreHydration(waterGlasses);
    final habitsScore = _scoreHabits(habitsCompleted, habitsTotal);
    final streaksScore = _scoreStreaks(streakDays);
    final screenScore = _scoreScreenTime(screenTimeHours);
    final engagementScore = _scoreAiEngagement(aiChatCount);

    final components = [moodScore, sleepScore, sentimentScore, activityScore,
      meditationScore, hydrationScore, habitsScore, streaksScore,
      screenScore, engagementScore];
    final overall = (components.fold(0.0, (a, b) => a + b) / components.length).round().clamp(0, 100);

    final improvements = <String>[];
    final needsAttention = <String>[];
    if (sleepScore < 60) needsAttention.add('Sleep');
    if (sleepScore >= 60 && sleepScore < 80) improvements.add('Sleep improving');
    if (moodScore < 60) needsAttention.add('Mood');
    if (moodScore >= 60) improvements.add('Mood stable');
    if (streaksScore >= 70) improvements.add('Meditation streak +$streakDays');
    if (hydrationScore < 50) needsAttention.add('Water intake');
    if (screenScore < 50) needsAttention.add('Screen time');
    if (meditationScore >= 60) improvements.add('Consistent meditation');
    if (habitsScore >= 70) improvements.add('Habits on track');

    return WellnessScore(
      overall: overall,
      mood: moodScore,
      sleep: sleepScore,
      journalSentiment: sentimentScore,
      activity: activityScore,
      meditationConsistency: meditationScore,
      hydration: hydrationScore,
      habits: habitsScore,
      streaks: streaksScore,
      screenTime: screenScore,
      aiEngagement: engagementScore,
      improvements: improvements,
      needsAttention: needsAttention,
    );
  }

  double _scoreMood(int todayMood, List<journal.JournalEntry> recent) {
    final recentAvg = recent.isEmpty
        ? todayMood.toDouble()
        : recent.map((e) => e.mood.toDouble()).reduce((a, b) => a + b) / recent.length;
    final weighted = (todayMood * 0.6 + recentAvg * 0.4);
    return ((weighted - 1) / 4 * 100).clamp(0, 100);
  }

  double _scoreSleep(int hours) {
    if (hours >= 7 && hours <= 9) return 100;
    if (hours >= 6 && hours <= 10) return 70;
    if (hours >= 5 && hours <= 11) return 40;
    return 20;
  }

  double _scoreJournalSentiment(double avg) {
    return ((avg + 1) / 2 * 100).clamp(0, 100);
  }

  double _scoreActivity(int streak) {
    return (streak / 30 * 100).clamp(0, 100).roundToDouble();
  }

  double _scoreMeditation(int minutes, int streak) {
    final consistency = (streak / 30 * 50);
    final volume = (minutes / 60 * 50);
    return (consistency + volume).clamp(0, 100).roundToDouble();
  }

  double _scoreHydration(int glasses) {
    return (glasses / _targetWaterGlasses * 100).clamp(0, 100).roundToDouble();
  }

  double _scoreHabits(int completed, int total) {
    if (total == 0) return 50;
    return (completed / total * 100).clamp(0, 100).roundToDouble();
  }

  double _scoreStreaks(int days) {
    if (days >= 30) return 100;
    if (days >= 14) return 80;
    if (days >= 7) return 60;
    if (days >= 3) return 40;
    return (days * 15).clamp(0, 100).roundToDouble();
  }

  double _scoreScreenTime(int hours) {
    if (hours <= 3) return 100;
    if (hours <= 5) return 70;
    if (hours <= 7) return 40;
    return 20;
  }

  double _scoreAiEngagement(int chatCount) {
    if (chatCount >= 5) return 100;
    if (chatCount >= 3) return 70;
    if (chatCount >= 1) return 40;
    return 10;
  }
}
