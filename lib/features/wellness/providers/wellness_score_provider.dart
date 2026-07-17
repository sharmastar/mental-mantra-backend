import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../mood/presentation/providers/mood_provider.dart';
import '../../mood/data/models/mood_entry.dart';
import '../../sleep/presentation/providers/sleep_provider.dart';
import '../../sleep/data/models/sleep_record.dart';
import '../../journal/presentation/providers/journal_provider.dart';
import '../../journal/data/models/journal_entry.dart';
import '../../recovery/presentation/providers/recovery_provider.dart';
import '../../auth/providers/auth_provider.dart';

class DailyWellnessScore {
  final int overall;
  final int mood;
  final int sleep;
  final int mindfulness;
  final int journal;
  final int recovery;
  final int streak;
  final int moodCount;
  final int sleepCount;
  final int meditationMinutes;
  final int journalCount;
  final int urgesResisted;
  final String? topAdvice;
  final List<String> strengths;
  final List<String> improvements;

  const DailyWellnessScore({
    required this.overall,
    required this.mood,
    required this.sleep,
    required this.mindfulness,
    required this.journal,
    required this.recovery,
    required this.streak,
    this.moodCount = 0,
    this.sleepCount = 0,
    this.meditationMinutes = 0,
    this.journalCount = 0,
    this.urgesResisted = 0,
    this.topAdvice,
    this.strengths = const [],
    this.improvements = const [],
  });

  String get grade {
    if (overall >= 90) return 'A+';
    if (overall >= 80) return 'A';
    if (overall >= 70) return 'B';
    if (overall >= 60) return 'C';
    if (overall >= 40) return 'D';
    return 'F';
  }

  String get label {
    if (overall >= 90) return 'Excellent';
    if (overall >= 80) return 'Great';
    if (overall >= 70) return 'Good';
    if (overall >= 60) return 'Fair';
    if (overall >= 40) return 'Needs Work';
    return 'Needs Attention';
  }
}

class WellnessScoreNotifier extends StateNotifier<DailyWellnessScore> {
  WellnessScoreNotifier()
      : super(const DailyWellnessScore(
            overall: 0,
            mood: 0,
            sleep: 0,
            mindfulness: 0,
            journal: 0,
            recovery: 0,
            streak: 0));

  void compute({
    required List<MoodEntry> moods,
    required List<SleepRecord> sleeps,
    required int meditationMinutes,
    required List<JournalEntry> journals,
    required int urgesResisted,
    required int streak,
  }) {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    final todayMoods = moods.where((m) {
      final d = m.createdAt;
      return '${d.year}-${d.month}-${d.day}' == todayStr;
    }).toList();

    final todaySleeps = sleeps.where((s) {
      final d = s.date;
      return '${d.year}-${d.month}-${d.day}' == todayStr;
    }).toList();

    final todayJournals = journals.where((j) {
      final d = j.createdAt;
      return '${d.year}-${d.month}-${d.day}' == todayStr;
    }).toList();

    final moodScore = _calcMood(todayMoods);
    final sleepScore = _calcSleep(todaySleeps);
    final mindfulnessScore = _calcMindfulness(meditationMinutes);
    final journalScore = _calcJournal(todayJournals, moods);
    final recoveryScore = _calcRecovery(urgesResisted);
    final streakScore = _calcStreak(streak);

    final overall = ((moodScore * 0.25) +
            (sleepScore * 0.20) +
            (mindfulnessScore * 0.20) +
            (journalScore * 0.15) +
            (recoveryScore * 0.10) +
            (streakScore * 0.10))
        .round()
        .clamp(0, 100);

    final strengths = <String>[];
    final improvements = <String>[];

    if (moodScore >= 70) {
      strengths.add('Mood');
    } else if (moodScore < 50) {
      improvements.add('Log your mood regularly');
    }

    if (sleepScore >= 70) {
      strengths.add('Sleep');
    } else if (sleepScore < 50) {
      improvements.add('Try to get 7-9 hours of sleep');
    }

    if (mindfulnessScore >= 70) {
      strengths.add('Mindfulness');
    } else if (mindfulnessScore < 50) {
      improvements.add('Meditate for at least 5 minutes daily');
    }

    if (journalScore >= 70) {
      strengths.add('Journaling');
    } else if (journalScore < 50) {
      improvements.add('Write a journal entry to reflect');
    }

    if (recoveryScore >= 70) {
      strengths.add('Recovery');
    }

    if (streakScore >= 70) {
      strengths.add('Consistency');
    }

    String? topAdvice;
    if (improvements.isNotEmpty) {
      topAdvice = improvements.first;
    } else if (strengths.isNotEmpty) {
      topAdvice = 'Keep up the great work!';
    }

    state = DailyWellnessScore(
      overall: overall,
      mood: moodScore,
      sleep: sleepScore,
      mindfulness: mindfulnessScore,
      journal: journalScore,
      recovery: recoveryScore,
      streak: streakScore,
      moodCount: todayMoods.length,
      sleepCount: todaySleeps.length,
      meditationMinutes: meditationMinutes,
      journalCount: todayJournals.length,
      urgesResisted: urgesResisted,
      topAdvice: topAdvice,
      strengths: strengths,
      improvements: improvements,
    );
  }

  int _calcMood(List<MoodEntry> moods) {
    if (moods.isEmpty) return 0;
    final avg =
        moods.map((m) => m.moodValue).reduce((a, b) => a + b) / moods.length;
    return ((avg - 1) / 4 * 100).round().clamp(0, 100);
  }

  int _calcSleep(List<SleepRecord> sleeps) {
    if (sleeps.isEmpty) return 40;
    final best = sleeps.first;
    if (best.durationMinutes >= 420 && best.durationMinutes <= 540) return 100;
    if (best.durationMinutes >= 360 && best.durationMinutes <= 600) return 75;
    if (best.durationMinutes >= 300) return 50;
    return 25;
  }

  int _calcMindfulness(int minutes) {
    if (minutes >= 30) return 100;
    if (minutes >= 20) return 80;
    if (minutes >= 10) return 60;
    if (minutes >= 5) return 40;
    if (minutes >= 1) return 20;
    return 0;
  }

  int _calcJournal(List<JournalEntry> todayJournals, List<MoodEntry> allMoods) {
    int score = 0;
    if (todayJournals.isNotEmpty) score += 40;
    if (allMoods.length >= 3) score += 30;
    if (allMoods.length >= 7) score += 30;
    return score.clamp(0, 100);
  }

  int _calcRecovery(int urgesResisted) {
    if (urgesResisted >= 5) return 100;
    if (urgesResisted >= 3) return 75;
    if (urgesResisted >= 1) return 50;
    return 30;
  }

  int _calcStreak(int streak) {
    if (streak >= 30) return 100;
    if (streak >= 14) return 85;
    if (streak >= 7) return 70;
    if (streak >= 3) return 50;
    return streak * 15;
  }
}

final wellnessScoreProvider =
    StateNotifierProvider<WellnessScoreNotifier, DailyWellnessScore>((ref) {
  return WellnessScoreNotifier();
});

final wellnessScoreUpdaterProvider = Provider<void>((ref) {
  void updateScore() {
    final moods = ref.read(moodListProvider);
    final sleepState = ref.read(sleepProvider);
    final user = ref.read(currentUserProvider);
    final recoveryState = ref.read(recoveryProvider);
    final journalsAsync = ref.read(journalListProvider(user?.uid ?? ''));

    ref.read(wellnessScoreProvider.notifier).compute(
          moods: moods,
          sleeps: sleepState.records,
          meditationMinutes: 0,
          journals: journalsAsync.valueOrNull ?? [],
          urgesResisted: recoveryState.stats.urgesResisted,
          streak: user?.streakDays ?? 0,
        );
  }

  // Set up listeners to update when they change
  ref.listen(moodListProvider, (_, __) => updateScore());
  ref.listen(sleepProvider, (_, __) => updateScore());
  ref.listen(currentUserProvider, (_, __) => updateScore());
  ref.listen(recoveryProvider, (_, __) => updateScore());
  
  final user = ref.watch(currentUserProvider);
  ref.listen(journalListProvider(user?.uid ?? ''), (_, __) => updateScore());

  // Perform initial calculation safely after construction
  Future.microtask(() => updateScore());
});
