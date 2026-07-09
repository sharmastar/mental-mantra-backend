import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/storage/hive_storage.dart';
import 'package:mental_mantra/services/ai/safety_detector.dart';

class ChatMessage {
  final String messageId;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isStreaming;

  ChatMessage({
    String? messageId,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isStreaming = false,
  })  : messageId = messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? messageId,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isStreaming,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };
}

class AiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isTyping;
  final String? error;
  final Map<String, dynamic>? profile;
  final String? lastFailedMessage;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.error,
    this.profile,
    this.lastFailedMessage,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isTyping,
    String? error,
    Map<String, dynamic>? profile,
    String? lastFailedMessage,
    bool clearError = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: clearError ? null : (error ?? this.error),
      profile: profile ?? this.profile,
      lastFailedMessage: lastFailedMessage ?? this.lastFailedMessage,
    );
  }
}

class _TopicContext {
  String? lastTopic;
  String? lastEmotion;
  int topicRepeatCount = 0;

  void detectFrom(String text) {
    final msg = text.toLowerCase();
    if (msg.contains('sad') || msg.contains('lonely') || msg.contains('depress') || msg.contains('down')) {
      _update('sadness', 'sadness');
    } else if (msg.contains('anx') || msg.contains('worried') || msg.contains('nervous') || msg.contains('overthink') || msg.contains('panic')) {
      _update('anxiety', 'anxiety');
    } else if (msg.contains('stress') || msg.contains('overwhelm') || msg.contains('burnout')) {
      _update('stress', 'stress');
    } else if (msg.contains('angry') || msg.contains('frustrat') || msg.contains('irritat') || msg.contains('annoy')) {
      _update('anger', 'anger');
    } else if (msg.contains('sleep') || msg.contains('insomnia') || msg.contains('tired') || msg.contains('can\'t sleep') || msg.contains('cant sleep')) {
      _update('sleep', 'sleep');
    } else if (msg.contains('motivat') || msg.contains('lazy') || msg.contains('procrastin') || msg.contains('unproductive')) {
      _update('motivation', 'low_motivation');
    } else if (msg.contains('breathe') || msg.contains('breathing') || msg.contains('meditat') || msg.contains('mindful')) {
      _update('mindfulness', 'mindfulness');
    } else if (msg.contains('grateful') || msg.contains('thankful') || msg.contains('appreciate')) {
      _update('gratitude', 'positive');
    } else if (msg.contains('habit') || msg.contains('addict') || msg.contains('urge')) {
      _update('habits', 'habits');
    }
  }

  void _update(String topic, String emotion) {
    if (topic == lastTopic) {
      topicRepeatCount++;
    } else {
      topicRepeatCount = 1;
    }
    lastTopic = topic;
    lastEmotion = emotion;
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  Timer? _streamTimer;
  bool _disposed = false;
  final _context = _TopicContext();
  final _responses = _RuleResponses();

  AiChatNotifier() : super(const AiChatState());

  Future<void> loadHistory() async {
    try {
      final saved = await HiveStorage.getChatHistory();
      if (saved.isNotEmpty) {
        state = state.copyWith(
          messages: saved.map((m) => ChatMessage(
            messageId: m['messageId'] as String?,
            text: m['text'] as String? ?? '',
            isUser: m['isUser'] as bool? ?? false,
            timestamp: DateTime.tryParse(m['timestamp'] as String? ?? '') ?? DateTime.now(),
          )).toList(),
        );
      }
    } catch (_) {}
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _streamTimer?.cancel();

    final userMsg = ChatMessage(text: text.trim(), isUser: true);
    final botPlaceholder = ChatMessage(
      text: '',
      isUser: false,
      isStreaming: true,
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg, botPlaceholder],
      isTyping: true,
      clearError: true,
    );

    _saveHistory();
    _respond(text.trim());
  }

  String _respond(String text) {
    final safety = SafetyDetector.assess(text);

    if (safety.containsCrisisIndicator) {
      _streamResponse(_buildCrisisResponse(safety));
      return '';
    }

    _context.detectFrom(text);
    final reply = _responses.match(text, _context);
    _streamResponse(reply);
    return reply;
  }

  void _streamResponse(String text) {
    _streamTimer?.cancel();
    var displayed = '';
    final words = text.split(' ');
    var wordIndex = 0;

    _streamTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (_disposed || wordIndex >= words.length) {
        timer.cancel();
        state = state.copyWith(isTyping: false);
        _saveHistory();
        return;
      }
      displayed += '${wordIndex > 0 ? ' ' : ''}${words[wordIndex]}';
      wordIndex++;

      final msgs = [...state.messages];
      msgs[msgs.length - 1] = msgs.last.copyWith(
        text: displayed,
        isStreaming: wordIndex < words.length,
      );
      state = state.copyWith(messages: msgs);
    });
  }

  String _buildCrisisResponse(SafetyAssessment safety) {
    final base = safety.suggestedResponse ?? "I'm here for you.";
    return '$base\n\n'
        'Please reach out for support:\n'
        '• AASRA (India, 24x7): +91-9820466726\n'
        '• iCall: 9152987821 (Mon-Sat 10am-8pm)\n'
        '• Vandrevala Foundation: 9999666555\n'
        '• US: 988 Suicide & Crisis Lifeline\n'
        '• International: findahelpline.com';
  }

  void startVoiceInput() {
    sendMessage('[Voice input placeholder]');
  }

  void clearChat() {
    _streamTimer?.cancel();
    _context.lastTopic = null;
    _context.lastEmotion = null;
    _context.topicRepeatCount = 0;
    state = state.copyWith(
      messages: [],
      isTyping: false,
      clearError: true,
    );
    HiveStorage.clearChatHistory();
  }

  void _saveHistory() {
    HiveStorage.saveChatHistory(
      state.messages.map((m) => m.toJson()).toList(),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _streamTimer?.cancel();
    super.dispose();
  }
}

class _RuleResponses {
  final _responses = <_Rule>[
    _Rule(
      patterns: ['hello', 'hi ', 'hey', 'good morning', 'good evening', 'good afternoon'],
      reply: _reply('Hi there! I\'m Nova, your wellness companion. How are you feeling today?'),
    ),
    _Rule(
      patterns: ['how are you', 'how\'s it going', 'how do you do', 'how are you doing'],
      reply: _reply('I\'m here and ready to help! More importantly, how are you doing today?'),
    ),
    _Rule(
      patterns: ['thank', 'thanks', 'grateful', 'appreciate', 'that helps', 'that helped'],
      reply: _reply('You\'re welcome! Gratitude is a wonderful practice. Would you like to write a quick gratitude entry in your journal to capture this moment?'),
    ),
    _Rule(
      patterns: ['sad', 'lonely', 'depress', 'down', 'crying', 'cry', 'heart', 'broken', 'empty'],
      reply: _ctxReply('sadness', 'I hear you, and it\'s okay to feel this way. You don\'t have to go through it alone. Would you like to try a short breathing exercise together, or would talking more about what\'s on your mind help?'),
    ),
    _Rule(
      patterns: ['anx', 'worried', 'nervous', 'overthink', 'panic', 'racing', 'fear', 'scared', 'anxiety'],
      reply: _ctxReply('anxiety', 'Anxiety can feel overwhelming, but you\'re handling it by reaching out. Let\'s try grounding: take a slow breath in for 4 counts, hold for 4, breathe out for 4. Would you like to try a guided breathing exercise from the Meditation section?'),
    ),
    _Rule(
      patterns: ['stress', 'overwhelm', 'burnout', 'too much', 'can\'t cope', 'cant cope', 'pressure'],
      reply: _ctxReply('stress', 'It sounds like you\'re carrying a lot right now. Remember to be kind to yourself — even 2 minutes of deep breathing can lower your stress levels. Want me to suggest a quick relaxation technique you can do right now?'),
    ),
    _Rule(
      patterns: ['angry', 'frustrat', 'irritat', 'annoy', 'rage', 'mad', 'pissed'],
      reply: _ctxReply('anger', 'Anger is a natural emotion, and it\'s okay to feel it. Before reacting, try taking 3 deep breaths. Would you like to try a short guided exercise to help release some of that tension?'),
    ),
    _Rule(
      patterns: ['sleep', 'insomnia', 'can\'t sleep', 'cant sleep', 'tired', 'exhausted', 'awake', 'restless', 'dream', 'nightmare'],
      reply: _ctxReply('sleep', 'Sleep difficulties can really affect how we feel. Try dimming the lights, putting your phone away, and doing a gentle body scan. Would you like to try a sleep meditation from the app?'),
    ),
    _Rule(
      patterns: ['motivat', 'lazy', 'procrastin', 'unproductive', 'no energy', 'sluggish', 'stuck'],
      reply: _ctxReply('motivation', 'Struggling with motivation is something many of us face. The key is to start small — just 2 minutes of something is better than nothing. What\'s one tiny step you can take right now?'),
    ),
    _Rule(
      patterns: ['breathe', 'breathing', 'meditat', 'mindful', 'focus', 'calm', 'relax', 'peace'],
      reply: _reply('Mindfulness is a great tool! Try this: sit comfortably, close your eyes, and focus on your breath flowing in and out. Start with just 1 minute. You can find more guided sessions in the Meditation section of the app.'),
    ),
    _Rule(
      patterns: ['help', 'what can you do', 'capabilities', 'features', 'what do you do'],
      reply: _reply('I\'m here to support your wellness journey! I can help with stress, anxiety, motivation, sleep, and more. Try asking me about breathing exercises, journaling prompts, or just tell me what\'s on your mind. You can also check out the Meditations, Yoga, and Music sections for more support.'),
    ),
    _Rule(
      patterns: ['journal', 'write', 'diary', 'reflect', 'reflection'],
      reply: _reply('Journaling can be incredibly therapeutic. Start by writing whatever comes to mind — no judgment. Here\'s a prompt: "Right now, I feel..." Would you like to try that?'),
    ),
    _Rule(
      patterns: ['habit', 'addict', 'urge', 'craving', 'quit', 'relapse', 'recovery'],
      reply: _ctxReply('habits', 'Building new habits takes time and patience. What\'s one small healthy habit you\'d like to work on today? Remember, the Habit Tracker and Recovery sections in the app are here to support you.'),
    ),
    _Rule(
      patterns: ['workout', 'exercise', 'yoga', 'stretch', 'run', 'walk', 'move', 'activity'],
      reply: _reply('Movement is great for mental health! Even a 5-minute stretch or walk can boost your mood. Check out the Yoga section for guided sessions tailored to how you\'re feeling.'),
    ),
    _Rule(
      patterns: ['music', 'song', 'sound', 'nature', 'rain', 'ocean', 'melody'],
      reply: _reply('Music and nature sounds can be very calming. Check out the Music section in the app — we have relaxing tracks, focus music, nature sounds, and more to match your mood.'),
    ),
    _Rule(
      patterns: ['eating', 'food', 'hungry', 'appetite', 'meal', 'diet', 'nutrition'],
      reply: _reply('Nourishing your body is an important part of wellness. Try to eat something wholesome, stay hydrated, and listen to what your body needs. Would you like a reminder to drink water?'),
    ),
    _Rule(
      patterns: ['friend', 'relationship', 'partner', 'alone', 'people', 'social', 'family'],
      reply: _reply('Relationships and connection are important for our wellbeing. It\'s okay to reach out to someone you trust. Want to talk through what\'s happening?'),
    ),
    _Rule(
      patterns: ['work', 'job', 'career', 'boss', 'colleague', 'office', 'study', 'exam'],
      reply: _reply('Work and studies can be a big source of stress. Remember to take short breaks, breathe, and separate your self-worth from your productivity. What\'s the most challenging part right now?'),
    ),
  ];

  String match(String text, _TopicContext ctx) {
    final lowered = text.toLowerCase().trim();

    for (final rule in _responses) {
      if (rule.anyMatch(lowered)) {
        return rule.reply(ctx);
      }
    }

    if (lowered.length < 5) {
      return 'I\'m here for you. Could you tell me a bit more about what\'s on your mind?';
    }

    if (ctx.topicRepeatCount >= 2 && ctx.lastTopic != null) {
      return _deepFollowUp(ctx.lastTopic!);
    }

    return 'Thank you for sharing that with me. I want to make sure I understand — could you tell me a little more so I can help you better? You can also check out the Meditations, Breathing Exercises, or Journal sections for more support.';
  }

  String _deepFollowUp(String topic) {
    return switch (topic) {
      'sadness' => 'I really want you to know that what you\'re feeling matters. Sometimes just sitting with the feeling and breathing into it can help. Would you like to try a guided self-compassion exercise?',
      'anxiety' => 'Anxiety often convinces us something bad will happen. Try naming 3 things you can see right now. That\'s a simple grounding technique that can help bring you back to the present moment. Want to try it together?',
      'stress' => 'When stress builds up, your body holds tension without you realizing it. Try slowly rolling your shoulders back and taking a deep breath. Can you feel the release?',
      'anger' => 'Behind anger is often hurt or fear. Try writing down what you\'re feeling right now without filtering yourself — you can even tear it up after. Would that help?',
      'sleep' => 'A consistent wind-down routine trains your brain to recognize it\'s time to rest. Try the same 3 things every night: dim lights, no screens, and a short meditation. Would you like me to suggest a bedtime routine?',
      'motivation' => 'Sometimes "lack of motivation" is really overwhelm in disguise. Can you pick the single smallest thing you\'d feel good about accomplishing? Start there, nothing else.',
      'habits' => 'Change isn\'t linear — what matters is that you keep coming back. Every moment is a fresh start. What\'s one small win you can aim for in the next hour?',
      _ => 'I hear you. Let\'s take this one step at a time. What feels most important to focus on right now?',
    };
  }
}

class _Rule {
  final List<RegExp> _compiled;
  final String Function(_TopicContext ctx) reply;

  _Rule({required List<String> patterns, required this.reply})
      : _compiled = patterns.map((p) => RegExp(p, caseSensitive: false)).toList();

  bool anyMatch(String input) => _compiled.any((re) => re.hasMatch(input));
}

String Function(_TopicContext) _reply(String text) => (_) => text;

String Function(_TopicContext) _ctxReply(String topic, String text) =>
    (ctx) {
      if (ctx.topicRepeatCount >= 2 && ctx.lastTopic == topic) {
        return text;
      }
      return text;
    };

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier();
});
