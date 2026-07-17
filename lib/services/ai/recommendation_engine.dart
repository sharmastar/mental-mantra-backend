import 'package:mental_mantra/services/wellness/data/quotes_catalog.dart';

class ContentCurator {
  ContentCurator._();

  static String getJournalPrompt(Map<String, dynamic> profile) {
    final concerns = List<String>.from(profile['primaryConcerns'] ?? []);
    if (concerns.contains('Stress Management')) {
      return 'What is the biggest source of stress in your life right now? What is one small thing you can do to reduce it?';
    }
    if (concerns.contains('Anxiety')) {
      return 'Write about a moment today when you felt anxious. What happened? How did you cope? What would you tell a friend in the same situation?';
    }
    if (concerns.contains('Sleep Quality')) {
      return 'Describe your ideal bedtime routine. What helps you relax before sleep? What keeps you awake?';
    }
    if (concerns.contains('Mood')) {
      return 'Think of three things that went well today — no matter how small. How did they make you feel?';
    }
    return 'How are you feeling right now? Take a moment to check in with yourself and write whatever comes to mind.';
  }

  static Map<String, String> getDailyQuote(Map<String, dynamic> profile) {
    return QuotesCatalog.getDailyQuote();
  }

  static List<String> getAffirmations(Map<String, dynamic> profile) {
    final concerns = List<String>.from(profile['primaryConcerns'] ?? []);
    final all = <String>[
      'I am capable of handling whatever comes my way.',
      'My feelings are valid and I allow myself to feel them.',
      'I am enough, exactly as I am.',
      'Every breath I take fills me with peace and calm.',
      'I choose to focus on what I can control.',
      'I am stronger than I think.',
      'Today, I choose progress over perfection.',
      'My mind is calm. My heart is open. My soul is at peace.',
      'I deserve love, happiness, and peace.',
      'I release what I cannot change and embrace what I can.',
    ];
    if (concerns.contains('Anxiety')) {
      all.insertAll(
          0, ['I am safe in this moment.', 'This feeling will pass.']);
    }
    if (concerns.contains('Sleep Quality')) {
      all.insertAll(0, [
        'I release the day and welcome rest.',
        'Sleep restores my mind and body.'
      ]);
    }
    if (concerns.contains('Motivation')) {
      all.insertAll(0, [
        'Small steps lead to big changes.',
        'I have the power to create change.'
      ]);
    }
    return all;
  }
}
