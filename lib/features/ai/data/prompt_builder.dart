import 'package:mental_mantra/core/personalization/personalization_context.dart';

class PromptBuilder {
  static String buildSystemPrompt(PersonalizationContext ctx) {
    final parts = <String>[
      _systemIdentity(),
      if (ctx.hasClassification) _domainContext(ctx),
      if (ctx.overallWellnessScore != null) _wellnessContext(ctx),
      if (ctx.moodEntryCount > 0) _moodContext(ctx),
      if (ctx.memorySummary != null) _memoryContext(ctx),
      _preferenceContext(ctx),
      _behaviorGuidelines(),
    ];

    return parts.where((p) => p.isNotEmpty).join('\n\n');
  }

  static String _systemIdentity() {
    return '''You are Mental Mantra AI, a supportive and empathetic mental wellness assistant. Greet the user naturally using their context below. Never say "Based on your profile..." — weave it in organically.
Your personality is:
• Friendly
• Calm
• Supportive
• Professional
• Positive''';
  }

  static String _domainContext(PersonalizationContext ctx) {
    final buf = StringBuffer("USER'S WELLNESS CONTEXT:\n");
    buf.writeln("- Primary domain: ${ctx.primaryDomain}");
    if (ctx.secondaryDomains.isNotEmpty) {
      buf.writeln("- Secondary domains: ${ctx.secondaryDomains.join(', ')}");
    }
    if (ctx.domainScores.isNotEmpty) {
      final sorted = ctx.domainScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      buf.writeln(
          "- Domain scores: ${sorted.map((e) => '${e.key}: ${e.value.toStringAsFixed(0)}/10').join(', ')}");
    }
    buf.writeln(
        '- Classification confidence: ${(ctx.confidence * 100).toStringAsFixed(0)}%');
    if (ctx.needsCrisisAttention) {
      buf.writeln(
          '- Risk level: ${ctx.riskLevel} — monitor for safety concerns.');
    }
    buf.writeln(
        'Use this context to tailor your responses. Do NOT explicitly mention the classification.');
    return buf.toString();
  }

  static String _wellnessContext(PersonalizationContext ctx) {
    final buf = StringBuffer("WELLNESS PROFILE:\n");
    buf.writeln(
        '- Overall score: ${ctx.overallWellnessScore?.toStringAsFixed(0)}/100');
    if (ctx.primaryConcerns.isNotEmpty) {
      buf.writeln('- Concerns: ${ctx.primaryConcerns.join(", ")}');
    }
    if (ctx.strengths.isNotEmpty) {
      buf.writeln('- Strengths: ${ctx.strengths.join(", ")}');
    }
    return buf.toString();
  }

  static String _moodContext(PersonalizationContext ctx) {
    return "RECENT MOOD DATA:\n"
        "- Average mood (${ctx.moodEntryCount} entries): ${ctx.averageMood.toStringAsFixed(1)}/5\n"
        "- Trend: ${ctx.moodTrend}\n";
  }

  static String _memoryContext(PersonalizationContext ctx) {
    return 'CONVERSATION MEMORY SUMMARY:\n${ctx.memorySummary}\n\nUse this for continuity. Update after each session.';
  }

  static String _preferenceContext(PersonalizationContext ctx) {
    final buf = StringBuffer("USER PREFERENCES:\n");
    buf.writeln("- Language: ${ctx.language}");
    buf.writeln(
        "- Spiritual mode: ${ctx.spiritualMode ? 'enabled' : 'disabled'}");
    buf.writeln("- Level: ${ctx.level} | Streak: ${ctx.currentStreak} days");
    buf.writeln("- Onboarding completed: ${ctx.onboardingCompleted}");
    return buf.toString();
  }

  static String _behaviorGuidelines() {
    return '''RESPONSE GUIDELINES & RULES:
1. Speak naturally.
2. Never judge the user.
3. Keep answers short unless asked for detail.
4. Suggest breathing or mindfulness when someone feels stressed.
5. Help with anxiety, overthinking, confidence, habits, and motivation.
6. Help users journal their thoughts.
7. Do not diagnose mental illnesses.
8. Do not prescribe medication.
9. If someone expresses thoughts of self-harm or being in immediate danger, encourage them to contact local emergency services or a trusted person and seek professional help.
10. Respond in the user's language (English or Hindi).
11. Use emojis only when they fit naturally.
12. End long answers with one small actionable step.''';
  }
}
