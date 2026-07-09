import 'models/assessment_question.dart';

class AssessmentData {
  AssessmentData._();

  /// The 15 curated onboarding questions — conversational, empathetic, non-judgmental.
  static List<AssessmentQuestion> get questions => [
    // ── Q1: Nickname ──────────────────────────────────────────
    const AssessmentQuestion(
      id: 'nickname',
      question: "What should we call you?",
      type: 'text',
      isOptional: true,
      subtitle: "We want to make this space feel personal 💛",
      encouragementAfter: "Nice to meet you! 💫",
      suggestedNames: ['Sunshine', 'Phoenix', 'Serenity', 'Brave Soul', 'Warrior', 'Dreamer', 'Bloom', 'Hope'],
    ),

    // ── Q2: Age Group ─────────────────────────────────────────
    const AssessmentQuestion(
      id: 'age_group',
      question: 'How old are you?',
      type: 'single_select',
      options: ['Under 18', '18-24', '25-34', '35-44', '45-54', '55+'],
      subtitle: "This helps us tailor content for your life stage.",
      encouragementAfter: "Thanks for sharing! 🙏",
    ),

    // ── Q3: Reasons Joined (Core Domain Classifier) ───────────
    const AssessmentQuestion(
      id: 'reasons_joined',
      question: "What made you join Mental Mantra today?",
      type: 'multi_select',
      options: [
        'Stress or pressure',
        'Anxiety or overthinking',
        'Feeling emotionally low',
        'Loneliness',
        'Relationship difficulties',
        'Family conflicts',
        'Work stress',
        'Academic stress',
        'Sleep problems',
        'Lack of motivation',
        'Low confidence/self-esteem',
        'Addiction or habit control',
        'Anger or emotional control',
        'Emotional burnout',
        'Just exploring mental wellness',
      ],
      subtitle: "Select all that apply — no judgment here.",
      encouragementAfter: "We're glad you're here ❤️",
    ),

    // ── Q4: Challenge Duration ────────────────────────────────
    const AssessmentQuestion(
      id: 'challenge_duration',
      question: "How long have these challenges been affecting you?",
      type: 'single_select',
      options: ['A few days', 'A few weeks', 'A few months', 'More than a year'],
      subtitle: "This helps us understand the depth of what you're going through.",
      encouragementAfter: "You've taken a brave step today 💪",
    ),

    // ── Q5: Affected Areas ────────────────────────────────────
    const AssessmentQuestion(
      id: 'affected_areas',
      question: "Which areas of your life are being affected the most?",
      type: 'multi_select',
      options: [
        'Relationships',
        'Family life',
        'Studies',
        'Work performance',
        'Sleep',
        'Physical health',
        'Confidence',
        'Social interactions',
        'Daily routine',
        'Motivation/productivity',
      ],
      subtitle: "Select all that apply.",
      encouragementAfter: "This helps us personalize your wellness journey 🌿",
    ),

    // ── Q6: Emotional Wellness — Overwhelm ────────────────────
    const AssessmentQuestion(
      id: 'emotional_overwhelm',
      question: "Over the past 2 weeks, how often have you felt mentally overwhelmed?",
      type: 'frequency_scale',
      options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Almost Always'],
      subtitle: "Be honest — there are no right or wrong answers.",
      encouragementAfter: "Thank you for being open 💙",
    ),

    // ── Q7: Emotional Wellness — Worry ────────────────────────
    const AssessmentQuestion(
      id: 'excessive_worry',
      question: "How often have you experienced excessive worrying or overthinking?",
      type: 'frequency_scale',
      options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Almost Always'],
      subtitle: "Over the past 2 weeks.",
    ),

    // ── Q8: Emotional Wellness — Loneliness ───────────────────
    const AssessmentQuestion(
      id: 'feeling_lonely',
      question: "How often have you felt lonely or disconnected?",
      type: 'frequency_scale',
      options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Almost Always'],
      subtitle: "Over the past 2 weeks.",
      encouragementAfter: "You're doing great — we're almost there ✨",
    ),

    // ── Q9: Sleep Hours ───────────────────────────────────────
    const AssessmentQuestion(
      id: 'sleep_hours',
      question: "On average, how many hours do you sleep daily?",
      type: 'single_select',
      options: ['Less than 4', '4-5', '6-7', '7-8', 'More than 8'],
      subtitle: "Sleep is a key part of emotional wellbeing.",
      encouragementAfter: "Thanks for sharing that 🌙",
    ),

    // ── Q10: Sleep Quality ────────────────────────────────────
    const AssessmentQuestion(
      id: 'sleep_quality',
      question: "How would you describe your sleep quality?",
      type: 'single_select',
      options: ['Very good', 'Good', 'Average', 'Poor', 'Very poor'],
      subtitle: "Think about your typical night's sleep.",
    ),

    // ── Q11: Physical Activity ────────────────────────────────
    const AssessmentQuestion(
      id: 'physical_activity',
      question: "How physically active are you?",
      type: 'single_select',
      options: ['Very active', 'Moderately active', 'Slightly active', 'Mostly inactive'],
      subtitle: "Movement and mental health are deeply connected.",
      encouragementAfter: "Every bit of movement counts 🏃",
    ),

    // ── Q12: Emotional Support ────────────────────────────────
    const AssessmentQuestion(
      id: 'emotional_support',
      question: "Do you feel you have someone you can openly talk to emotionally?",
      type: 'single_select',
      options: ['Yes', 'Sometimes', 'No'],
      subtitle: "Having support makes a real difference.",
      isSensitive: true,
    ),

    // ── Q13: Habit Struggles ──────────────────────────────────
    const AssessmentQuestion(
      id: 'habit_struggles',
      question: "Have you struggled with any of these habits becoming difficult to control?",
      type: 'multi_select',
      options: [
        'Social media scrolling',
        'Gaming',
        'Pornography',
        'Betting/Gambling',
        'Alcohol',
        'Smoking',
        'Emotional eating',
        'Binge watching',
        'Shopping/spending',
        'None',
      ],
      subtitle: "This is a safe space — select all that apply.",
      encouragementAfter: "Thank you for trusting us with that 🤝",
      isSensitive: true,
    ),

    // ── Q14: Coping Style ─────────────────────────────────────
    const AssessmentQuestion(
      id: 'coping_style',
      question: "When emotionally stressed, what do you usually do?",
      type: 'multi_select',
      options: [
        'Stay alone',
        'Talk to someone',
        'Sleep',
        'Cry',
        'Exercise',
        'Watch content/videos',
        'Scroll social media',
        'Pray/meditate',
        'Work/study more',
        'Get angry',
        'Eat more',
        'Play games',
      ],
      subtitle: "There's no wrong answer here — we all cope differently.",
      encouragementAfter: "Understanding your patterns helps us help you better 🌱",
    ),

    // ── Q15: Improvement Goals ────────────────────────────────
    const AssessmentQuestion(
      id: 'improvement_goals',
      question: "What would you most like to improve through Mental Mantra?",
      type: 'multi_select',
      options: [
        'Reduce stress',
        'Reduce anxiety',
        'Improve sleep',
        'Build confidence',
        'Improve relationships',
        'Addiction recovery',
        'Better focus/productivity',
        'Emotional balance',
        'Self-discipline',
        'Motivation',
        'Healthier habits',
        'Inner peace',
        'Overall wellbeing',
      ],
      subtitle: "Select the areas most important to you right now.",
      encouragementAfter: "Your personalized plan is being created! 🎯",
    ),
  ];

  // ── Adaptive Follow-ups (triggered by certain answers) ──────
  static final Map<String, AssessmentQuestion> _followUpQuestions = {
    'addiction_severity': const AssessmentQuestion(
      id: 'addiction_severity',
      question: 'How strongly do these habits affect your daily life or emotional wellbeing?',
      type: 'single_select',
      options: ['Not at all', 'Mildly', 'Moderately', 'Severely'],
      subtitle: "This helps us recommend the right level of support.",
    ),
    'stress_sources': const AssessmentQuestion(
      id: 'stress_sources',
      question: 'What is contributing most to your stress right now?',
      type: 'multi_select',
      options: ['Work pressure', 'Financial concerns', 'Relationship issues', 'Health problems', 'Family responsibilities', 'Major life changes', 'Academic pressure'],
    ),
    'sleep_improvement': const AssessmentQuestion(
      id: 'sleep_improvement',
      question: 'Would you like help improving your sleep?',
      type: 'single_select',
      options: ['Yes, please', 'Maybe later', 'No thanks'],
      isOptional: true,
    ),
  };

  static AssessmentQuestion? getAdaptiveQuestion(String id) => _followUpQuestions[id];

  static List<String> getAdaptiveFollowUps(Map<String, dynamic> answers) {
    final followUps = <String>[];

    // If user selected addiction-related habits (not "None"), ask about severity
    if (answers['habit_struggles'] is List) {
      final habits = List<String>.from(answers['habit_struggles']);
      if (habits.isNotEmpty && !habits.contains('None')) {
        followUps.add('addiction_severity');
      }
    }

    // If user selected stress-related reasons, ask about stress sources
    if (answers['reasons_joined'] is List) {
      final reasons = List<String>.from(answers['reasons_joined']);
      if (reasons.contains('Stress or pressure') || reasons.contains('Work stress') || reasons.contains('Academic stress')) {
        followUps.add('stress_sources');
      }
    }

    // If sleep quality is poor, offer sleep help
    if (answers['sleep_quality'] == 'Poor' || answers['sleep_quality'] == 'Very poor') {
      followUps.add('sleep_improvement');
    }

    return followUps;
  }
}
