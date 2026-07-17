import '../models/habit_recommendation.dart';
import '../../../core/personalization/personalization_context.dart';

class HabitEngine {
  static const _templates = <HabitTemplate>[
    // Stress
    HabitTemplate(
        title: '5-Minute Breathing Break',
        description: 'Take 5 minutes for deep breathing when stressed',
        domain: HabitDomain.stress,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 5,
        estimatedBenefit: 85),
    HabitTemplate(
        title: 'Walk After Lunch',
        description: 'A 10-minute walk after your midday meal',
        domain: HabitDomain.stress,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 10,
        estimatedBenefit: 75),
    HabitTemplate(
        title: 'No Work After 9 PM',
        description: 'Set a firm boundary to stop work at 9 PM',
        domain: HabitDomain.stress,
        difficulty: HabitDifficulty.hard,
        durationMinutes: 0,
        estimatedBenefit: 90),
    HabitTemplate(
        title: 'Progressive Muscle Relaxation',
        description: 'Tense and release each muscle group before bed',
        domain: HabitDomain.stress,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 10,
        estimatedBenefit: 80),
    HabitTemplate(
        title: 'Digital Sunset',
        description: 'Turn off notifications 1 hour before bed',
        domain: HabitDomain.stress,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 0,
        estimatedBenefit: 85),

    // Sleep
    HabitTemplate(
        title: 'Phone Off 30 Min Before Bed',
        description: 'Put your phone away half an hour before sleep',
        domain: HabitDomain.sleep,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 30,
        estimatedBenefit: 90),
    HabitTemplate(
        title: 'Fixed Bedtime',
        description: 'Go to bed at the same time every night',
        domain: HabitDomain.sleep,
        difficulty: HabitDifficulty.hard,
        durationMinutes: 0,
        estimatedBenefit: 95),
    HabitTemplate(
        title: 'Evening Meditation',
        description: 'A short guided meditation before sleep',
        domain: HabitDomain.sleep,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 10,
        estimatedBenefit: 80),
    HabitTemplate(
        title: 'Cool Room Sleep',
        description: 'Keep your bedroom at 16-18°C for optimal sleep',
        domain: HabitDomain.sleep,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 0,
        estimatedBenefit: 70),
    HabitTemplate(
        title: 'No Caffeine After 2 PM',
        description: 'Avoid caffeine in the afternoon for better sleep',
        domain: HabitDomain.sleep,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 0,
        estimatedBenefit: 85),

    // Motivation
    HabitTemplate(
        title: 'One Tiny Task',
        description: 'Complete the smallest task that moves you forward',
        domain: HabitDomain.motivation,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 5,
        estimatedBenefit: 90),
    HabitTemplate(
        title: 'Morning Sunlight',
        description: 'Get 10 minutes of natural light within 30 min of waking',
        domain: HabitDomain.motivation,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 10,
        estimatedBenefit: 85),
    HabitTemplate(
        title: 'Daily Gratitude',
        description: 'Write three things you are grateful for today',
        domain: HabitDomain.motivation,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 5,
        estimatedBenefit: 80),
    HabitTemplate(
        title: 'Win the Morning',
        description: 'Complete one meaningful task before 10 AM',
        domain: HabitDomain.motivation,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 30,
        estimatedBenefit: 85),
    HabitTemplate(
        title: 'Weekly Review',
        description: 'Review your week every Sunday — wins, lessons, focus',
        domain: HabitDomain.motivation,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 15,
        estimatedBenefit: 75),

    // Anxiety
    HabitTemplate(
        title: 'Grounding Check',
        description: 'When anxious, name 3 things you see, hear, and feel',
        domain: HabitDomain.anxiety,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 2,
        estimatedBenefit: 90),
    HabitTemplate(
        title: 'Worry Journal',
        description: 'Write down worries and label them as controllable or not',
        domain: HabitDomain.anxiety,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 10,
        estimatedBenefit: 85),
    HabitTemplate(
        title: 'Box Breathing',
        description: 'Inhale 4-hold 4-exhale 4-hold 4 when anxiety spikes',
        domain: HabitDomain.anxiety,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 4,
        estimatedBenefit: 95),
    HabitTemplate(
        title: 'Daily Check-In',
        description: 'Rate your anxiety 3 times a day to spot patterns',
        domain: HabitDomain.anxiety,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 2,
        estimatedBenefit: 75),

    // Mindfulness
    HabitTemplate(
        title: 'Morning Silence',
        description: '5 minutes of complete silence after waking',
        domain: HabitDomain.mindfulness,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 5,
        estimatedBenefit: 85),
    HabitTemplate(
        title: 'Mindful Eating',
        description: 'Eat one meal a day without any screens or distractions',
        domain: HabitDomain.mindfulness,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 20,
        estimatedBenefit: 75),
    HabitTemplate(
        title: 'Body Scan',
        description: 'A 10-minute body scan meditation',
        domain: HabitDomain.mindfulness,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 10,
        estimatedBenefit: 80),
    HabitTemplate(
        title: 'Single-Tasking',
        description: 'Do one thing at a time for 30 minutes — no multitasking',
        domain: HabitDomain.mindfulness,
        difficulty: HabitDifficulty.hard,
        durationMinutes: 30,
        estimatedBenefit: 80),

    // Energy
    HabitTemplate(
        title: 'Morning Stretch',
        description: '5-minute stretching immediately after waking',
        domain: HabitDomain.energy,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 5,
        estimatedBenefit: 80),
    HabitTemplate(
        title: 'Hydration Start',
        description: 'Drink a full glass of water first thing in the morning',
        domain: HabitDomain.energy,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 1,
        estimatedBenefit: 85),
    HabitTemplate(
        title: 'Midday Walk',
        description: 'A 15-minute walk to reset your energy in the afternoon',
        domain: HabitDomain.energy,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 15,
        estimatedBenefit: 75),
    HabitTemplate(
        title: 'Power Nap',
        description: '15-minute power nap between 1-3 PM',
        domain: HabitDomain.energy,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 15,
        estimatedBenefit: 80),
  ];

  List<HabitRecommendation> generateForDomain(PersonalizationContext ctx,
      {int count = 3}) {
    final domain = _mapDomain(ctx.primaryDomain);
    final filtered = _templates.where((t) => t.domain == domain).toList();

    if (filtered.isEmpty) {
      return _defaultHabits().take(count).toList();
    }

    filtered.shuffle();
    return filtered
        .take(count)
        .map((t) => HabitRecommendation(
              title: t.title,
              description: t.description,
              domain: t.domain,
              difficulty: t.difficulty,
              durationMinutes: t.durationMinutes,
              estimatedBenefit: t.estimatedBenefit,
              aiRationale: _rationale(t, ctx),
              category: t.domain.name,
            ))
        .toList();
  }

  List<HabitRecommendation> generateAll({int count = 5}) {
    final shuffled = List<HabitTemplate>.from(_templates);
    shuffled.shuffle();
    return shuffled
        .take(count)
        .map((t) => HabitRecommendation(
              title: t.title,
              description: t.description,
              domain: t.domain,
              difficulty: t.difficulty,
              durationMinutes: t.durationMinutes,
              estimatedBenefit: t.estimatedBenefit,
              aiRationale: '',
              category: t.domain.name,
            ))
        .toList();
  }

  List<HabitRecommendation> _defaultHabits() {
    return [
      const HabitRecommendation(
        title: 'Morning Mindfulness',
        description: 'Start your day with 2 minutes of deep breathing',
        domain: HabitDomain.mindfulness,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 2,
        estimatedBenefit: 80,
        aiRationale: 'A gentle start builds consistency.',
        category: 'mindfulness',
      ),
      const HabitRecommendation(
        title: 'Evening Reflection',
        description: 'Write one thing you learned today',
        domain: HabitDomain.motivation,
        difficulty: HabitDifficulty.easy,
        durationMinutes: 5,
        estimatedBenefit: 75,
        aiRationale: 'Reflection reinforces growth.',
        category: 'motivation',
      ),
      const HabitRecommendation(
        title: 'Hydration Reminder',
        description: 'Drink 8 glasses of water throughout the day',
        domain: HabitDomain.energy,
        difficulty: HabitDifficulty.medium,
        durationMinutes: 0,
        estimatedBenefit: 85,
        aiRationale: 'Hydration directly impacts mood and focus.',
        category: 'energy',
      ),
    ];
  }

  String _rationale(HabitTemplate t, PersonalizationContext ctx) {
    final domain = ctx.primaryDomain ?? '';
    switch (t.title) {
      case '5-Minute Breathing Break':
        return 'Helps lower cortisol when stress builds up.';
      case 'Walk After Lunch':
        return 'A midday reset improves afternoon focus and reduces stress.';
      case 'No Work After 9 PM':
        return 'Creates a boundary that protects your rest.';
      case 'Phone Off 30 Min Before Bed':
        return 'Blue light suppression improves melatonin production.';
      case 'Fixed Bedtime':
        return 'Consistency trains your circadian rhythm for deeper sleep.';
      case 'Evening Meditation':
        return 'Activates the parasympathetic nervous system for rest.';
      case 'One Tiny Task':
        return 'Dopamine from small wins builds momentum for bigger tasks.';
      case 'Morning Sunlight':
        return 'Morning light exposure sets your circadian clock for the day.';
      case 'Daily Gratitude':
        return 'Gratitude rewires the brain for positive pattern recognition.';
      case 'Grounding Check':
        return 'Interrupts the anxiety loop by engaging the senses.';
      case 'Box Breathing':
        return 'The most effective technique to activate the vagus nerve.';
      case 'Worry Journal':
        return 'Externalizing worries reduces their emotional weight.';
      case 'Morning Silence':
        return 'Creates a calm起始 tone for the nervous system.';
      case 'Hydration Start':
        return 'Rehydrates after sleep and kickstarts metabolism.';
      default:
        return domain.contains('stress') || domain.contains('anxiety')
            ? 'Directly addresses your primary wellness domain.'
            : 'Supports your overall wellness journey.';
    }
  }

  HabitDomain _mapDomain(String? domain) {
    switch (domain) {
      case 'stress_burnout':
        return HabitDomain.stress;
      case 'anxiety_overthinking':
        return HabitDomain.anxiety;
      case 'emotional_isolation':
        return HabitDomain.social;
      case 'addiction_recovery':
        return HabitDomain.recovery;
      case 'anger_dysregulation':
        return HabitDomain.stress;
      case 'low_motivation':
        return HabitDomain.motivation;
      case 'spiritual_seeking':
        return HabitDomain.mindfulness;
      case 'sleep_dysregulation':
        return HabitDomain.sleep;
      default:
        if (domain?.contains('stress') == true) return HabitDomain.stress;
        if (domain?.contains('anxiety') == true) return HabitDomain.anxiety;
        if (domain?.contains('sleep') == true) return HabitDomain.sleep;
        if (domain?.contains('motivat') == true) return HabitDomain.motivation;
        return HabitDomain.mindfulness;
    }
  }
}
