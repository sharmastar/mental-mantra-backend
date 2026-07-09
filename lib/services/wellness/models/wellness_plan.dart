import 'habit_recommendation.dart';
import '../../../features/ai/insights/models/ai_insight.dart';

enum TimeOfDayPeriod { morning, afternoon, evening, night }

class WellnessPlan {
  final WellnessScore wellnessScore;
  final DailyFocus focus;
  final List<QuickAction> actions;
  final List<AIInsight> insights;
  final List<HabitRecommendation> habits;
  final MeditationRecommendation meditation;
  final BreathingRecommendation breathing;
  final JournalPromptSuggestion journalPrompt;
  final SleepRecommendation sleep;
  final DailyBriefing briefing;
  final TimeOfDayPeriod currentPeriod;

  const WellnessPlan({
    required this.wellnessScore,
    required this.focus,
    required this.actions,
    required this.insights,
    required this.habits,
    required this.meditation,
    required this.breathing,
    required this.journalPrompt,
    required this.sleep,
    required this.briefing,
    required this.currentPeriod,
  });
}

class WellnessScore {
  final int overall;
  final double mood;
  final double sleep;
  final double journalSentiment;
  final double activity;
  final double meditationConsistency;
  final double hydration;
  final double habits;
  final double streaks;
  final double screenTime;
  final double aiEngagement;
  final List<String> improvements;
  final List<String> needsAttention;

  const WellnessScore({
    required this.overall,
    required this.mood,
    required this.sleep,
    required this.journalSentiment,
    required this.activity,
    required this.meditationConsistency,
    required this.hydration,
    required this.habits,
    required this.streaks,
    required this.screenTime,
    required this.aiEngagement,
    required this.improvements,
    required this.needsAttention,
  });
}

class DailyFocus {
  final String title;
  final String description;
  final String domain;
  final String emoji;

  const DailyFocus({
    required this.title,
    required this.description,
    required this.domain,
    required this.emoji,
  });
}

class QuickAction {
  final String label;
  final String route;
  final IconType icon;
  final String reason;

  const QuickAction({
    required this.label,
    required this.route,
    required this.icon,
    required this.reason,
  });
}

enum IconType {
  chat, journal, meditate, therapy, breathing, music,
  sleep, goals, habits, achievements, streak, timer,
  detox, discover, spiritual, water, walk, read,
}


class MeditationRecommendation {
  final String title;
  final String category;
  final String duration;
  final String reason;

  const MeditationRecommendation({
    required this.title,
    required this.category,
    required this.duration,
    required this.reason,
  });
}

class BreathingRecommendation {
  final String name;
  final String duration;
  final String technique;
  final String reason;

  const BreathingRecommendation({
    required this.name,
    required this.duration,
    required this.technique,
    required this.reason,
  });
}

class JournalPromptSuggestion {
  final String prompt;
  final String context;
  final JournalPromptType type;

  const JournalPromptSuggestion({
    required this.prompt,
    required this.context,
    required this.type,
  });
}

enum JournalPromptType { reflection, gratitude, emotionalCheckin, goalSetting, freeform }

class SleepRecommendation {
  final String tip;
  final int targetHours;
  final String windDownActivity;
  final String reason;

  const SleepRecommendation({
    required this.tip,
    required this.targetHours,
    required this.windDownActivity,
    required this.reason,
  });
}

class DailyBriefing {
  final String greeting;
  final String summary;
  final String morningFocus;
  final String eveningReflection;
  final String? affirmation;

  const DailyBriefing({
    required this.greeting,
    required this.summary,
    required this.morningFocus,
    required this.eveningReflection,
    this.affirmation,
  });
}
