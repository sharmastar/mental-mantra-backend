import '../models/wellness_plan.dart';
import '../../../core/personalization/personalization_context.dart';

class BriefingEngine {
  DailyBriefing generateMorningBriefing({
    required PersonalizationContext ctx,
    required WellnessScore score,
    required int sleepHours,
    required int yesterdayMood,
    required int? previousMood,
    required int breathingStreak,
    required int journalStreak,
    required String? userName,
  }) {
    final name = (userName?.isNotEmpty == true) ? userName! : 'there';
    final greeting = _morningGreeting(ctx, name);

    final yesterdaySummary = _yesterdaySummary(sleepHours, yesterdayMood, previousMood, breathingStreak);
    final todayFocus = _todayFocus(ctx, score);

    final reflection = _eveningReflection(score);

    final affirmation = _getAffirmation(ctx.primaryDomain);

    return DailyBriefing(
      greeting: greeting,
      summary: yesterdaySummary,
      morningFocus: todayFocus,
      eveningReflection: reflection,
      affirmation: affirmation,
    );
  }

  DailyBriefing generateEveningBriefing({
    required PersonalizationContext ctx,
    required WellnessScore score,
    required int activitiesCompleted,
    required int? morningAnxiety,
    required int? eveningAnxiety,
    required String? userName,
  }) {
    final name = (userName?.isNotEmpty == true) ? userName! : 'there';

    final completionSummary = _eveningCompletionSummary(activitiesCompleted, morningAnxiety, eveningAnxiety, score);
    _windDownRecommendation(ctx);
    final reflection = _eveningReflection(score);

    return DailyBriefing(
      greeting: 'Good evening, $name.',
      summary: completionSummary,
      morningFocus: '',
      eveningReflection: reflection,
      affirmation: _getAffirmation(ctx.primaryDomain),
    );
  }

  String _morningGreeting(PersonalizationContext ctx, String name) {
    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    if (!ctx.hasClassification) return '$timeGreeting, $name.';

    switch (ctx.primaryDomain) {
      case 'stress_burnout':
        return '$timeGreeting, $name. Let today be about peace, not pressure.';
      case 'anxiety_overthinking':
        return '$timeGreeting, $name. One breath at a time — you\'ve got this.';
      case 'emotional_isolation':
        return '$timeGreeting, $name. You are not alone in this journey.';
      case 'addiction_recovery':
        return '$timeGreeting, $name. Every morning is a fresh start. You are stronger than any urge.';
      case 'anger_dysregulation':
        return '$timeGreeting, $name. Today, choose calm over chaos.';
      case 'low_motivation':
        return '$timeGreeting, $name. Small steps lead to big changes.';
      case 'spiritual_seeking':
        return '$timeGreeting, $name. Your journey of discovery continues today.';
      case 'sleep_dysregulation':
        return '$timeGreeting, $name. Let today set the foundation for great sleep tonight.';
      default:
        return '$timeGreeting, $name. Ready for a great day?';
    }
  }

  String _yesterdaySummary(int sleepHours, int yesterdayMood, int? previousMood, int breathingStreak) {
    final parts = <String>[];
    parts.add('Yesterday you slept $sleepHours hours.');

    if (previousMood != null && yesterdayMood != previousMood) {
      final direction = yesterdayMood > previousMood ? 'improved' : 'declined';
      parts.add('Your mood $direction slightly.');
    } else {
      parts.add('Your mood remained stable.');
    }

    if (breathingStreak > 0) {
      parts.add('You\'ve maintained a $breathingStreak-day breathing streak.');
    }

    return parts.join(' ');
  }

  String _todayFocus(PersonalizationContext ctx, WellnessScore score) {
    final domain = ctx.primaryDomain ?? 'general';

    if (score.needsAttention.isNotEmpty) {
      final top = score.needsAttention.first;
      return "Let's focus on gently supporting your $top today.";
    }

    switch (domain) {
      case 'stress_burnout':
        return 'Let\'s practice shifting tension with a brief Box Breathing session.';
      case 'anxiety_overthinking':
        return 'Let\'s anchor your thoughts by naming three things you can sense around you.';
      case 'sleep_dysregulation':
        return 'Today, let\'s try putting away screens thirty minutes before resting.';
      case 'low_motivation':
        return 'You\'ve taken a small step today, and those often become the biggest changes over time.';
      case 'addiction_recovery':
        return 'If an urge arises today, try observing it with curiosity for ten minutes before acting.';
      case 'emotional_isolation':
        return 'Today, consider reaching out to someone. A simple hello is enough.';
      case 'anger_dysregulation':
        return 'Let\'s pause and take a single slow breath before responding today.';
      default:
        return 'Take a quiet moment to set one simple intention for your day.';
    }
  }

  String _eveningCompletionSummary(int completed, int? morningAnxiety, int? eveningAnxiety, WellnessScore score) {
    final parts = <String>[];
    parts.add('You completed $completed wellness activities today.');

    if (morningAnxiety != null && eveningAnxiety != null && eveningAnxiety < morningAnxiety) {
      parts.add('Your anxiety rating decreased from $morningAnxiety to $eveningAnxiety.');
    }

    if (score.improvements.isNotEmpty) {
      parts.add(score.improvements.take(2).join('. '));
    }

    return parts.join(' ');
  }

  String _windDownRecommendation(PersonalizationContext ctx) {
    final domain = ctx.primaryDomain ?? '';
    if (domain.contains('sleep')) {
      return 'Wind down with the Sleep Calm meditation and phone-off routine.';
    }
    if (domain.contains('anxiety') || domain.contains('stress')) {
      return 'Try a 10-minute body scan meditation before bed.';
    }
    if (domain.contains('motivat')) {
      return 'Reflect on three things that went well today.';
    }
    return 'End your day with a short reflection and gratitude practice.';
  }

  String _eveningReflection(WellnessScore score) {
    if (score.overall >= 70) {
      return 'Acknowledge the steps you took today. Now is the time to rest and let go.';
    }
    if (score.overall >= 40) {
      return 'If today felt heavy, remember that rest is progress too. Be gentle with yourself tonight.';
    }
    return 'Let go of today. Tomorrow is a new beginning. Sleep well.';
  }

  String _getAffirmation(String? domain) {
    switch (domain) {
      case 'stress_burnout': return 'I release what I cannot control.';
      case 'anxiety_overthinking': return 'I am safe in this moment.';
      case 'emotional_isolation': return 'I am worthy of connection.';
      case 'addiction_recovery': return 'I am stronger than any urge.';
      case 'anger_dysregulation': return 'I choose peace over reaction.';
      case 'low_motivation': return 'Small steps lead to big changes.';
      case 'spiritual_seeking': return 'I am exactly where I need to be.';
      case 'sleep_dysregulation': return 'Rest is healing. I welcome deep sleep.';
      default: return 'I am enough, exactly as I am.';
    }
  }
}
