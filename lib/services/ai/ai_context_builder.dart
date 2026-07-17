// lib/services/ai/ai_context_builder.dart
import 'package:flutter/foundation.dart';
import 'package:mental_mantra/core/storage/hive_storage.dart';
import 'ai_memory_service.dart';

/// Builds a rich, structured context string injected into every AI chat request.
/// Replaces the simple inline `systemContext` that was hardcoded in AiChatNotifier.
class AiContextBuilder {
  final AiMemoryService _memoryService;

  /// Approximate max tokens for the system context (~4 chars per token).
  /// ~2000 tokens = ~8000 chars. Keeps context from dominating the context window.
  static const int _maxContextChars = 8000;

  AiContextBuilder({AiMemoryService? memoryService})
      : _memoryService = memoryService ?? AiMemoryService();

  /// Returns a list of context messages to prepend to the API call.
  /// Format: [{'role': 'system', 'content': '...'}]
  Future<List<Map<String, dynamic>>> buildContext() async {
    try {
      final memory = await _memoryService.loadContext();
      final profile = await HiveStorage.getWellnessProfile();
      final buffer = StringBuffer();

      // 1. Core persona
      buffer.writeln(
        'You are Nova, a compassionate and empathetic AI mental wellness companion. '
        'You are trained in evidence-based techniques including Cognitive Behavioral Therapy (CBT), '
        'mindfulness, and positive psychology. You provide supportive, non-judgmental guidance. '
        'You are NOT a medical professional and always recommend professional help for serious issues. '
        'Keep responses warm, concise, and actionable — ideally 2-4 short paragraphs.',
      );

      // 2. Wellness profile context
      if (profile.isNotEmpty) {
        final score = profile['overallScore'] ?? 50;
        final level = profile['riskLevel'] ?? 'low';
        final concerns = (profile['primaryConcerns'] as List?)?.join(', ') ??
            'general support';
        buffer.writeln(
          '\nUser Wellness Profile:'
          '\n- Overall wellness score: $score/100'
          '\n- Risk level: $level'
          '\n- Primary concerns: $concerns',
        );
      }

      // 3. Mood summary
      if (memory.moodSummary.isNotEmpty) {
        final avg = memory.moodSummary['avgMood'];
        final trend = memory.moodSummary['trend'];
        final count = memory.moodSummary['entryCount'];
        buffer.writeln(
          '\nRecent Mood Pattern (last 7 days):'
          '\n- Average mood: $avg/5'
          '\n- Trend: $trend'
          '\n- Total check-ins: $count',
        );
      }

      // 4. Dominant topics from memory
      if (memory.dominantTopics.isNotEmpty) {
        buffer.writeln(
          '\nRecurring themes in our conversations: ${memory.dominantTopics.join(', ')}.',
        );
      }

      // 5. Active user goals
      if (memory.activeGoals.isNotEmpty) {
        final goalList =
            memory.activeGoals.take(4).map((g) => '- ${g.goal}').join('\n');
        buffer.writeln('\nUser\'s stated wellness goals:\n$goalList');
      }

      // 6. Last session summary
      if (memory.lastSessionSummary != null &&
          memory.lastSessionSummary!.isNotEmpty) {
        buffer.writeln(
            '\nLast conversation summary: "${memory.lastSessionSummary}"');
      }

      // 7. Memory highlights (recent entries)
      if (memory.recentMemories.isNotEmpty) {
        final highlights = memory.recentMemories
            .take(3)
            .map((m) => '- [${m.emotionalTone}] ${m.summary}')
            .join('\n');
        buffer.writeln('\nRecent conversation highlights:\n$highlights');
      }

      // 8. Meditation and journal stats
      if ((memory.meditationSummary['totalSessions'] as int? ?? 0) > 0) {
        buffer.writeln(
          '\nMeditation: ${memory.meditationSummary['totalSessions']} sessions completed.',
        );
      }
      if ((memory.journalThemes['totalEntries'] as int? ?? 0) > 0) {
        buffer.writeln(
          'Journal: ${memory.journalThemes['totalEntries']} entries written.',
        );
      }

      // 9. Overall emotional tone
      if (memory.overallEmotionalTone.isNotEmpty &&
          memory.overallEmotionalTone != 'neutral') {
        buffer.writeln(
          '\nOverall emotional tone from recent sessions: ${memory.overallEmotionalTone}. '
          'Adapt your tone accordingly — be especially gentle and validating.',
        );
      }

      buffer.writeln(
        '\nIMPORTANT: Use the above context to personalize your response. '
        'Reference the user\'s specific concerns and goals when relevant. '
        'Suggest exercises proactively when appropriate (meditation, breathing, journaling). '
        'Always check in about the user\'s current state before diving into advice.',
      );

      // Enforce token budget — truncate oldest (least important) sections first
      var contextStr = buffer.toString();
      if (contextStr.length > _maxContextChars) {
        contextStr = contextStr.substring(0, _maxContextChars);
        // Snap to last complete line to avoid cutting mid-sentence
        final lastNewline = contextStr.lastIndexOf('\n');
        if (lastNewline > _maxContextChars * 0.6) {
          contextStr = contextStr.substring(0, lastNewline);
        }
      }

      return [
        {'role': 'system', 'content': contextStr},
      ];
    } catch (e) {
      debugPrint('[AiContextBuilder] buildContext error: $e');
      return [
        {
          'role': 'system',
          'content': 'You are Nova, a compassionate AI mental wellness companion. '
              'Provide warm, supportive, evidence-based guidance. '
              'You are not a medical professional — always recommend professional help when needed.',
        }
      ];
    }
  }

  /// Detects the emotional tone of a user message for memory storage.
  String detectEmotionalTone(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('happy') ||
        msg.contains('great') ||
        msg.contains('amazing') ||
        msg.contains('wonderful')) {
      return 'positive';
    }
    if (msg.contains('sad') ||
        msg.contains('depress') ||
        msg.contains('hopeless') ||
        msg.contains('lonely')) {
      return 'sad';
    }
    if (msg.contains('anx') ||
        msg.contains('worried') ||
        msg.contains('panic') ||
        msg.contains('fear')) {
      return 'anxious';
    }
    if (msg.contains('angry') ||
        msg.contains('frustrat') ||
        msg.contains('irritat')) {
      return 'angry';
    }
    if (msg.contains('stress') ||
        msg.contains('overwhelm') ||
        msg.contains('burnout')) {
      return 'stressed';
    }
    if (msg.contains('tired') ||
        msg.contains('exhaust') ||
        msg.contains('drained')) {
      return 'fatigued';
    }
    return 'neutral';
  }
}
