import '../models/wellness_plan.dart';
import '../../../core/personalization/personalization_context.dart';
import '../../../features/journal/data/models/journal_entry.dart';
import '../../../features/ai/insights/engines/insight_engine.dart';
import '../../../features/ai/insights/models/recommendation.dart';
import '../../../features/meditation/data/meditation_catalog.dart';
import 'score_engine.dart';
import 'habit_engine.dart';
import 'journal_intelligence_engine.dart';
import 'briefing_engine.dart';

class WellnessEngine {
  final ScoreEngine _scoreEngine = ScoreEngine();
  final InsightEngine _insightEngine = InsightEngine();
  final HabitEngine _habitEngine = HabitEngine();
  final JournalIntelligenceEngine _journalEngine = JournalIntelligenceEngine();
  final BriefingEngine _briefingEngine = BriefingEngine();

  WellnessPlan generate(
    PersonalizationContext ctx, {
    required List<JournalEntry> recentEntries,
    required List<Map<String, dynamic>> moodHistory,
    required int todayMood,
    required int sleepHours,
    required int waterGlasses,
    required int meditationMinutes,
    required int streakDays,
    required int screenTimeHours,
    required int aiChatCount,
    required int habitsCompleted,
    required int habitsTotal,
    required int? morningAnxiety,
    required int? eveningAnxiety,
    required int? yesterdayMood,
    required int stress,
    required int anxiety,
    required int consecutiveBadSleep,
    required String? userName,
    List<RecommendationOutcome> outcomes = const [],
  }) {
    final journalSentimentAvg = _computeJournalSentiment(recentEntries);
    final period = _currentPeriod();

    final score = _scoreEngine.compute(
      ctx,
      recentEntries: recentEntries,
      todayMood: todayMood,
      sleepHours: sleepHours,
      waterGlasses: waterGlasses,
      meditationMinutes: meditationMinutes,
      streakDays: streakDays,
      screenTimeHours: screenTimeHours,
      aiChatCount: aiChatCount,
      journalSentimentAvg: journalSentimentAvg,
      habitsCompleted: habitsCompleted,
      habitsTotal: habitsTotal,
    );

    final focus = _generateFocus(ctx, score, period);

    final actions = _generateActions(ctx, score, period);

    final insightCollection = _insightEngine.generate(
      ctx: ctx,
      wellnessScore: score,
      journalEntries: recentEntries,
      moodHistory: moodHistory,
      todayMood: todayMood,
      sleepHours: sleepHours,
      stress: stress,
      anxiety: anxiety,
      consecutiveBadSleep: consecutiveBadSleep,
      meditationMinutes: meditationMinutes,
      streakDays: streakDays,
      waterGlasses: waterGlasses,
      screenTimeHours: screenTimeHours,
      activitiesCompleted: habitsCompleted,
      habitsCompleted: habitsCompleted,
      habitsTotal: habitsTotal,
      outcomes: outcomes,
    );
    final insights = insightCollection.all;

    final habits = _habitEngine.generateForDomain(ctx, count: 3);

    final meditation = _recommendMeditation(ctx, period);
    final breathing = _recommendBreathing(ctx, period);
    final journalPrompt = _generateJournalPrompt(ctx, period);
    final sleep = _recommendSleep(ctx, sleepHours);

    final morningBriefing = _briefingEngine.generateMorningBriefing(
      ctx: ctx,
      score: score,
      sleepHours: sleepHours,
      yesterdayMood: yesterdayMood ?? todayMood,
      previousMood: recentEntries.isNotEmpty ? recentEntries.first.mood : null,
      breathingStreak: streakDays,
      journalStreak: streakDays,
      userName: userName,
    );

    final eveningBriefing = _briefingEngine.generateEveningBriefing(
      ctx: ctx,
      score: score,
      activitiesCompleted: habitsCompleted,
      morningAnxiety: morningAnxiety,
      eveningAnxiety: eveningAnxiety,
      userName: userName,
    );

    final isMorning = period == TimeOfDayPeriod.morning ||
        period == TimeOfDayPeriod.afternoon;

    return WellnessPlan(
      wellnessScore: score,
      focus: focus,
      actions: actions,
      insights: insights,
      habits: habits,
      meditation: meditation,
      breathing: breathing,
      journalPrompt: journalPrompt,
      sleep: sleep,
      briefing: isMorning ? morningBriefing : eveningBriefing,
      currentPeriod: period,
    );
  }

  TimeOfDayPeriod _currentPeriod() {
    final hour = DateTime.now().hour;
    if (hour < 12) return TimeOfDayPeriod.morning;
    if (hour < 17) return TimeOfDayPeriod.afternoon;
    if (hour < 21) return TimeOfDayPeriod.evening;
    return TimeOfDayPeriod.night;
  }

  DailyFocus _generateFocus(
      PersonalizationContext ctx, WellnessScore score, TimeOfDayPeriod period) {
    final domain = ctx.primaryDomain ?? 'general';

    String title;
    String description;

    switch (period) {
      case TimeOfDayPeriod.morning:
        title = _morningFocusTitle(domain, score);
        description = _morningFocusDescription(domain, score);
      case TimeOfDayPeriod.afternoon:
        title = _afternoonFocusTitle(domain);
        description = _afternoonFocusDescription(domain);
      case TimeOfDayPeriod.evening:
        title = _eveningFocusTitle(domain);
        description = _eveningFocusDescription(domain);
      case TimeOfDayPeriod.night:
        title = _nightFocusTitle(domain);
        description = _nightFocusDescription(domain);
    }

    final emoji = _domainEmoji(domain);

    return DailyFocus(
      title: title,
      description: description,
      domain: domain,
      emoji: emoji,
    );
  }

  String _morningFocusTitle(String domain, WellnessScore score) {
    if (score.needsAttention.contains('Sleep')) return 'Start fresh today';
    if (score.needsAttention.contains('Screen time')) {
      return 'Digital detox today';
    }
    switch (domain) {
      case 'stress_burnout':
        return 'Find your calm';
      case 'anxiety_overthinking':
        return 'Stay grounded';
      case 'sleep_dysregulation':
        return 'Build sleep momentum';
      case 'low_motivation':
        return 'One step forward';
      case 'addiction_recovery':
        return 'Every moment counts';
      case 'emotional_isolation':
        return 'Connect today';
      case 'anger_dysregulation':
        return 'Choose peace';
      case 'spiritual_seeking':
        return 'Your journey continues';
      default:
        return 'Set your intention';
    }
  }

  String _morningFocusDescription(String domain, WellnessScore score) {
    if (score.needsAttention.isNotEmpty) {
      return "Let's work on ${score.needsAttention.first.toLowerCase()} today.";
    }
    switch (domain) {
      case 'stress_burnout':
        return 'Begin with a 5-minute breathing exercise.';
      case 'anxiety_overthinking':
        return 'Try a grounding check-in now.';
      case 'sleep_dysregulation':
        return 'Set your bedtime goal for tonight.';
      case 'low_motivation':
        return 'What is the one tiny task you can do today?';
      case 'addiction_recovery':
        return 'Affirm your commitment to yourself.';
      default:
        return 'Take a moment to set a positive intention.';
    }
  }

  String _afternoonFocusTitle(String domain) {
    if (domain.contains('stress')) return 'Reset your energy';
    if (domain.contains('sleep')) return 'Avoid caffeine';
    if (domain.contains('motivat')) return 'Keep momentum';
    return 'Midday check-in';
  }

  String _afternoonFocusDescription(String domain) {
    if (domain.contains('stress')) return 'Take a 5-minute walk to reset.';
    if (domain.contains('anxiety')) {
      return 'Check your anxiety level. Pause. Breathe.';
    }
    if (domain.contains('sleep')) return 'No caffeine after 2 PM today.';
    if (domain.contains('motivat')) {
      return 'Complete one more small task before the day ends.';
    }
    return 'Stretch, hydrate, and reset your focus.';
  }

  String _eveningFocusTitle(String domain) {
    if (domain.contains('sleep')) return 'Wind down';
    if (domain.contains('stress') || domain.contains('anxiety')) {
      return 'Release the day';
    }
    if (domain.contains('motivat')) return 'Reflect on today';
    return 'Prepare for rest';
  }

  String _eveningFocusDescription(String domain) {
    if (domain.contains('sleep')) {
      return 'Begin your phone-off wind-down routine.';
    }
    if (domain.contains('stress')) {
      return 'Write down three things you accomplished today.';
    }
    if (domain.contains('anxiety')) {
      return 'Do a brain dump — write everything on your mind.';
    }
    if (domain.contains('motivat')) {
      return 'What went well today? Celebrate the small wins.';
    }
    return 'Take 5 minutes to reflect on today with gratitude.';
  }

  String _nightFocusTitle(String domain) {
    return 'Rest & restore';
  }

  String _nightFocusDescription(String domain) {
    if (domain.contains('sleep')) {
      return 'Follow your bedtime routine for deep sleep.';
    }
    return 'Release today. Tomorrow is a fresh start.';
  }

  List<QuickAction> _generateActions(
      PersonalizationContext ctx, WellnessScore score, TimeOfDayPeriod period) {
    final actions = <QuickAction>[];
    final domain = ctx.primaryDomain ?? '';

    switch (period) {
      case TimeOfDayPeriod.morning:
        actions.addAll(_morningActions(domain, score));
      case TimeOfDayPeriod.afternoon:
        actions.addAll(_afternoonActions(domain, score));
      case TimeOfDayPeriod.evening:
        actions.addAll(_eveningActions(domain, score));
      case TimeOfDayPeriod.night:
        actions.addAll(_nightActions(domain));
    }

    actions.sort((a, b) {
      final priority = [
        'Breathing',
        'Meditation',
        'Journal',
        'Hydration',
        'Walk',
        'Chat'
      ];
      final ai = priority.indexOf(a.label);
      final bi = priority.indexOf(b.label);
      if (ai != -1 && bi != -1) return ai.compareTo(bi);
      if (ai != -1) return -1;
      if (bi != -1) return 1;
      return 0;
    });

    return actions.take(4).toList();
  }

  List<QuickAction> _morningActions(String domain, WellnessScore score) {
    final list = <QuickAction>[
      const QuickAction(
          label: 'AI Chat',
          route: '/home/ai-chat',
          icon: IconType.chat,
          reason: 'Check in with Nova'),
      const QuickAction(
          label: 'Journal',
          route: '/home/journal',
          icon: IconType.journal,
          reason: 'Set your intention'),
    ];

    if (domain.contains('stress') || domain.contains('anxiety')) {
      list.insert(
          0,
          const QuickAction(
              label: 'Breathing',
              route: '/home/meditation/breathing',
              icon: IconType.breathing,
              reason: 'Start with calm'));
    }
    if (domain.contains('sleep')) {
      list.add(const QuickAction(
          label: 'Sleep',
          route: '/home/sleep',
          icon: IconType.sleep,
          reason: 'Set bedtime goal'));
    }
    if (domain.contains('motivat')) {
      list.insert(
          1,
          const QuickAction(
              label: 'Goals',
              route: '/home/goals',
              icon: IconType.goals,
              reason: 'Plan your day'));
    }
    if (domain.contains('addiction') || domain.contains('recovery')) {
      list.insert(
          0,
          const QuickAction(
              label: 'Streak',
              route: '/home/recovery',
              icon: IconType.streak,
              reason: 'Protect your streak'));
    }
    if (score.hydration < 60) {
      list.add(const QuickAction(
          label: 'Hydration',
          route: '/home/nutrition',
          icon: IconType.water,
          reason: 'Drink water'));
    }

    return list;
  }

  List<QuickAction> _afternoonActions(String domain, WellnessScore score) {
    return [
      if (domain.contains('stress') || domain.contains('anxiety'))
        const QuickAction(
            label: 'Breathing',
            route: '/home/meditation/breathing',
            icon: IconType.breathing,
            reason: 'Stress reset'),
      const QuickAction(
          label: 'Hydration',
          route: '/home/nutrition',
          icon: IconType.water,
          reason: 'Drink water'),
      const QuickAction(
          label: 'Walk',
          route: '/home/yoga',
          icon: IconType.walk,
          reason: 'Stretch your legs'),
      if (score.screenTime < 50)
        const QuickAction(
            label: 'Focus Timer',
            route: '/home/meditation',
            icon: IconType.timer,
            reason: 'Focus session'),
    ];
  }

  List<QuickAction> _eveningActions(String domain, WellnessScore score) {
    return [
      const QuickAction(
          label: 'Reflection',
          route: '/home/journal',
          icon: IconType.journal,
          reason: 'Reflect on today'),
      if (domain.contains('sleep'))
        const QuickAction(
            label: 'Sleep',
            route: '/home/sleep',
            icon: IconType.sleep,
            reason: 'Wind down'),
      const QuickAction(
          label: 'Meditation',
          route: '/home/meditation',
          icon: IconType.meditate,
          reason: 'Evening meditation'),
    ];
  }

  List<QuickAction> _nightActions(String domain) {
    return [
      const QuickAction(
          label: 'Sleep',
          route: '/home/sleep',
          icon: IconType.sleep,
          reason: 'Time to rest'),
      const QuickAction(
          label: 'Meditation',
          route: '/home/meditate',
          icon: IconType.meditate,
          reason: 'Sleep meditation'),
      const QuickAction(
          label: 'Music',
          route: '/home/music',
          icon: IconType.music,
          reason: 'Sleep sounds'),
    ];
  }

  MeditationRecommendation _recommendMeditation(
      PersonalizationContext ctx, TimeOfDayPeriod period) {
    final domain = ctx.primaryDomain ?? '';
    final isEvening =
        period == TimeOfDayPeriod.evening || period == TimeOfDayPeriod.night;

    String category = 'mindfulness';
    String reason = 'A brief pause to center yourself.';

    if (isEvening) {
      category = 'sleep';
      reason = 'Prepare your body and mind for restful sleep.';
    } else {
      switch (domain) {
        case 'stress_burnout':
          category = 'stress';
          reason = 'Lower cortisol and calm the nervous system.';
          break;
        case 'anxiety_overthinking':
          category = 'anxiety';
          reason = 'Anchor yourself in the present moment.';
          break;
        case 'sleep_dysregulation':
          category = 'sleep';
          reason = 'Prepare your body for restorative cycles.';
          break;
        case 'low_motivation':
          category = 'productivity';
          reason = 'Build internal motivation and self-belief.';
          break;
        case 'emotional_isolation':
          category = 'self_love';
          reason = 'Connect with warmth and compassion for yourself.';
          break;
        case 'addiction_recovery':
          category = 'healing';
          reason = 'Strengthen your neural resolve and find calm.';
          break;
        case 'spiritual_seeking':
          category = 'spiritual';
          reason = 'Connect with your higher self and inner wisdom.';
          break;
        default:
          category = 'mindfulness';
          reason = 'A mindful moment to build presence.';
      }
    }

    final matching = MeditationCatalog.allSessions
        .where((s) => s.id.startsWith(category.substring(0, 3)))
        .toList();

    final session = matching.isNotEmpty
        ? matching[DateTime.now().day % matching.length]
        : MeditationCatalog.allSessions.first;

    return MeditationRecommendation(
      title: session.title,
      category: category,
      duration: session.durationLabel,
      reason: reason,
    );
  }

  BreathingRecommendation _recommendBreathing(
      PersonalizationContext ctx, TimeOfDayPeriod period) {
    final domain = ctx.primaryDomain ?? '';
    final isEvening =
        period == TimeOfDayPeriod.evening || period == TimeOfDayPeriod.night;

    if (isEvening) {
      return const BreathingRecommendation(
        name: '4-7-8 Breathing',
        duration: '4 min',
        technique: 'Inhale 4s — Hold 7s — Exhale 8s',
        reason: 'Activates the relaxation response for sleep preparation.',
      );
    }

    if (domain.contains('stress') ||
        domain.contains('anxiety') ||
        domain.contains('anger')) {
      return const BreathingRecommendation(
        name: 'Anxiety Relief',
        duration: '5 min',
        technique: 'Inhale 4s — Hold 2s — Exhale 6s — Hold 2s',
        reason:
            'Specifically structured to lower heart rate and reduce physical panic.',
      );
    }

    if (domain.contains('motivat')) {
      return const BreathingRecommendation(
        name: 'Energizing Breath',
        duration: '3 min',
        technique: 'Sharp inhales, relaxed exhales — 20 cycles',
        reason: 'Increases alertness and mental clarity.',
      );
    }

    return const BreathingRecommendation(
      name: 'Alternate Nostril',
      duration: '4 min',
      technique: 'Inhale Left — Hold — Exhale Right — Hold',
      reason: 'Balances the left and right hemispheres of the brain for focus.',
    );
  }

  JournalPromptSuggestion _generateJournalPrompt(
      PersonalizationContext ctx, TimeOfDayPeriod period) {
    final domain = ctx.primaryDomain ?? '';

    if (period == TimeOfDayPeriod.evening || period == TimeOfDayPeriod.night) {
      return const JournalPromptSuggestion(
        prompt:
            'What went well today? What would you like to release before sleep?',
        context: 'Evening reflection',
        type: JournalPromptType.reflection,
      );
    }

    switch (domain) {
      case 'stress_burnout':
        return const JournalPromptSuggestion(
          prompt:
              'What is the biggest source of stress right now? What is one small thing you can do about it?',
          context: 'Stress management',
          type: JournalPromptType.emotionalCheckin,
        );
      case 'anxiety_overthinking':
        return const JournalPromptSuggestion(
          prompt:
              'What thoughts are occupying your mind? Which ones are facts vs fears?',
          context: 'Anxiety check-in',
          type: JournalPromptType.emotionalCheckin,
        );
      case 'low_motivation':
        return const JournalPromptSuggestion(
          prompt:
              'What is one thing you could do today that your future self would thank you for?',
          context: 'Motivation boost',
          type: JournalPromptType.goalSetting,
        );
      case 'sleep_dysregulation':
        return const JournalPromptSuggestion(
          prompt:
              'Describe your ideal morning after a perfect night of sleep. What needs to happen before bed?',
          context: 'Sleep preparation',
          type: JournalPromptType.reflection,
        );
      case 'emotional_isolation':
        return const JournalPromptSuggestion(
          prompt:
              'Write a letter to yourself from the perspective of someone who loves you unconditionally.',
          context: 'Self-compassion practice',
          type: JournalPromptType.gratitude,
        );
      case 'spiritual_seeking':
        return const JournalPromptSuggestion(
          prompt:
              'What does inner peace mean to you? When was the last time you felt truly connected?',
          context: 'Spiritual exploration',
          type: JournalPromptType.reflection,
        );
      default:
        return const JournalPromptSuggestion(
          prompt:
              'How are you feeling right now? Take a moment to check in with yourself.',
          context: 'Daily check-in',
          type: JournalPromptType.freeform,
        );
    }
  }

  SleepRecommendation _recommendSleep(
      PersonalizationContext ctx, int sleepHours) {
    final domain = ctx.primaryDomain ?? '';
    final targetHours = sleepHours >= 7 ? sleepHours : 8;

    if (domain.contains('sleep')) {
      return SleepRecommendation(
        tip: 'Phone off 30 minutes before bed. Consistent bedtime is key.',
        targetHours: targetHours,
        windDownActivity: 'Try the Deep Sleep Body Scan meditation',
        reason: 'Your sleep quality is your primary focus area.',
      );
    }

    if (sleepHours < 7) {
      return const SleepRecommendation(
        tip: 'Try going to bed 30 minutes earlier tonight.',
        targetHours: 8,
        windDownActivity: 'Wind down with calming music',
        reason: 'Quality sleep improves mood, focus, and resilience.',
      );
    }

    return SleepRecommendation(
      tip: 'Maintain your consistent sleep schedule.',
      targetHours: targetHours,
      windDownActivity: 'Evening reflection and gratitude',
      reason: 'Consistent sleep reinforces your wellbeing foundation.',
    );
  }

  double _computeJournalSentiment(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0.0;
    final insights =
        entries.take(5).map((e) => _journalEngine.analyzeEntry(e)).toList();
    return insights.fold(0.0, (a, i) => a + i.emotions.sentimentScore) /
        insights.length;
  }

  String _domainEmoji(String domain) {
    switch (domain) {
      case 'stress_burnout':
        return '🔥';
      case 'anxiety_overthinking':
        return '🌀';
      case 'emotional_isolation':
        return '🏝️';
      case 'addiction_recovery':
        return '🛤️';
      case 'anger_dysregulation':
        return '💢';
      case 'low_motivation':
        return '⚡';
      case 'spiritual_seeking':
        return '🕉️';
      case 'sleep_dysregulation':
        return '🌙';
      default:
        return '🧘';
    }
  }
}
