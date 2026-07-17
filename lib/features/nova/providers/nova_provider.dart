import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mental_mantra/core/config/app_config.dart';
import 'package:mental_mantra/services/ai/safety_detector.dart';
import 'package:mental_mantra/services/ai/ai_memory_service.dart';
import 'package:mental_mantra/services/ai/ai_context_builder.dart';
import '../data/models/nova_conversation_history.dart';
import '../data/repositories/nova_repository.dart';
import '../data/services/nova_service.dart';

class NovaState {
  final List<NovaMessage> messages;
  final bool isLoading;
  final bool isTyping;
  final String? error;
  final Map<String, dynamic>? profile;
  final String? lastFailedMessage;

  const NovaState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.error,
    this.profile,
    this.lastFailedMessage,
  });

  NovaState copyWith({
    List<NovaMessage>? messages,
    bool? isLoading,
    bool? isTyping,
    String? error,
    Map<String, dynamic>? profile,
    String? lastFailedMessage,
    bool clearError = false,
  }) {
    return NovaState(
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
    if (msg.contains('sad') ||
        msg.contains('lonely') ||
        msg.contains('depress') ||
        msg.contains('down')) {
      _update('sadness', 'sadness');
    } else if (msg.contains('anx') ||
        msg.contains('worried') ||
        msg.contains('nervous') ||
        msg.contains('overthink') ||
        msg.contains('panic')) {
      _update('anxiety', 'anxiety');
    } else if (msg.contains('stress') ||
        msg.contains('overwhelm') ||
        msg.contains('burnout')) {
      _update('stress', 'stress');
    } else if (msg.contains('angry') ||
        msg.contains('frustrat') ||
        msg.contains('irritat') ||
        msg.contains('annoy')) {
      _update('anger', 'anger');
    } else if (msg.contains('sleep') ||
        msg.contains('insomnia') ||
        msg.contains('tired') ||
        msg.contains("can't sleep") ||
        msg.contains('cant sleep')) {
      _update('sleep', 'sleep');
    } else if (msg.contains('motivat') ||
        msg.contains('lazy') ||
        msg.contains('procrastin') ||
        msg.contains('unproductive')) {
      _update('motivation', 'low_motivation');
    } else if (msg.contains('breathe') ||
        msg.contains('breathing') ||
        msg.contains('meditat') ||
        msg.contains('mindful')) {
      _update('mindfulness', 'mindfulness');
    } else if (msg.contains('grateful') ||
        msg.contains('thankful') ||
        msg.contains('appreciate')) {
      _update('gratitude', 'positive');
    } else if (msg.contains('habit') ||
        msg.contains('addict') ||
        msg.contains('urge')) {
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

class _WellnessDetector {
  static WellnessAction? detect(String text) {
    final msg = text.toLowerCase();

    if (msg.contains('panic') ||
        msg.contains('can\'t breathe') ||
        msg.contains('cant breathe') ||
        msg.contains('emergency') ||
        msg.contains('sos')) {
      return const WellnessAction(
        type: WellnessActionType.sos,
        label: '🆘 Launch SOS Mode',
        route: '/safety-plan',
      );
    }

    if (msg.contains('anx') ||
        msg.contains('worried') ||
        msg.contains('nervous')) {
      return const WellnessAction(
        type: WellnessActionType.grounding,
        label: '🧘 Try Grounding Exercise',
        route: '/breathing',
      );
    }

    if (msg.contains('stress') ||
        msg.contains('overwhelm') ||
        msg.contains('burnout')) {
      return const WellnessAction(
        type: WellnessActionType.breathing,
        label: '🌬️ Start Breathing Exercise',
        route: '/breathing',
      );
    }

    if (msg.contains('gaming urge') ||
        msg.contains('trading urge') ||
        msg.contains('urge to gamble') ||
        msg.contains('urge to trade') ||
        msg.contains('urge to game') ||
        msg.contains('relapse')) {
      return const WellnessAction(
        type: WellnessActionType.recoveryPlan,
        label: '🛡️ Open Recovery Plan',
        route: '/craving-sos',
      );
    }

    if (msg.contains('can\'t sleep') ||
        msg.contains('cant sleep') ||
        msg.contains('insomnia') ||
        msg.contains('poor sleep')) {
      return const WellnessAction(
        type: WellnessActionType.sleepSounds,
        label: '🌙 Sleep Meditation & Sounds',
        route: '/sleep',
      );
    }

    if (msg.contains('depress') ||
        msg.contains('hopeless') ||
        msg.contains('no point') ||
        msg.contains('give up')) {
      return const WellnessAction(
        type: WellnessActionType.professionalHelp,
        label: '💙 Explore Support Resources',
        route: '/safety-plan',
      );
    }

    return null;
  }
}

class NovaNotifier extends StateNotifier<NovaState> {
  final NovaRepository _repository;
  final NovaService _service;
  Timer? _streamTimer;
  bool _disposed = false;
  final _context = _TopicContext();
  final _memoryService = AiMemoryService();
  late final AiContextBuilder _contextBuilder;

  static const int _summarizeThreshold = 15;

  NovaNotifier({
    required NovaRepository repository,
    required NovaService service,
  })  : _repository = repository,
        _service = service,
        super(const NovaState()) {
    _contextBuilder = AiContextBuilder(memoryService: _memoryService);
  }

  @override
  void dispose() {
    _disposed = true;
    _streamTimer?.cancel();
    super.dispose();
  }

  Future<void> loadHistory() async {
    try {
      final profile = await _repository.loadWellnessProfile();
      state = state.copyWith(profile: profile);

      final saved = await _repository.loadHistory();
      if (saved.isNotEmpty) {
        state = state.copyWith(messages: saved);
      }
    } catch (e, stack) {
      debugPrint('[NovaNotifier] loadHistory error: $e\n$stack');
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (state.isLoading) {
      debugPrint('[NovaNotifier] sendMessage ignored: already loading');
      return;
    }

    _streamTimer?.cancel();

    final action = _WellnessDetector.detect(trimmed);

    final userMsg = NovaMessage(
      text: trimmed,
      isUser: true,
      wellnessAction: action,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      clearError: true,
      lastFailedMessage: null,
    );
    _saveHistory();

    final safety = SafetyDetector.assess(trimmed);
    if (safety.containsCrisisIndicator) {
      final botMsg = NovaMessage(
        text: '',
        isUser: false,
        isStreaming: true,
      );
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
        isTyping: true,
      );
      _streamResponse(_buildCrisisResponse(safety));
      return;
    }

    try {
      final apiMessages = _buildApiMessages();
      _context.detectFrom(trimmed);

      final systemMessages = await _contextBuilder.buildContext();
      for (final msg in systemMessages.reversed) {
        apiMessages.insert(0, msg);
      }

      String reply;
      if (AppConfig.hasCompletedHealthCheck && !AppConfig.isBackendHealthy) {
        debugPrint('[NovaNotifier] Backend unhealthy, using local fallback.');
        reply = _getLocalFallbackReply(trimmed);
      } else {
        try {
          final response = await _callChatApiWithRetry(apiMessages);
          final responseData = response.data as Map<String, dynamic>?;

          if (responseData == null ||
              responseData['success'] != true ||
              responseData['reply'] == null) {
            throw Exception('Invalid response format from AI assistant');
          }
          reply = responseData['reply'] as String;
        } catch (apiErr) {
          debugPrint('[NovaNotifier] API call failed: $apiErr. Falling back to local response.');
          reply = _getLocalFallbackReply(trimmed);
        }
      }

      final botMsg = NovaMessage(
        text: '',
        isUser: false,
        isStreaming: true,
        wellnessAction: action,
      );
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
        isTyping: true,
      );
      _streamResponse(reply);
    } catch (e, stack) {
      debugPrint('[NovaNotifier] Error sending message: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        isTyping: false,
        error: _getUserFriendlyError(e),
        lastFailedMessage: trimmed,
      );
    }
  }

  List<Map<String, dynamic>> _buildApiMessages() {
    final allMsgs = state.messages
        .where((m) => m.text.isNotEmpty && !m.isStreaming)
        .toList();

    if (allMsgs.length <= _summarizeThreshold) {
      return allMsgs
          .map<Map<String, dynamic>>((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();
    }

    final cutoff = allMsgs.length - 10;
    final oldMessages = allMsgs.sublist(0, cutoff);
    final recentMessages = allMsgs.sublist(cutoff);

    final summaryParts = <String>[];
    for (final m in oldMessages) {
      final role = m.isUser ? 'User' : 'Nova';
      final snippet = m.text.length > 80 ? '${m.text.substring(0, 80)}...' : m.text;
      summaryParts.add('$role: $snippet');
    }

    final summaryText =
        '[Earlier conversation summary]\n${summaryParts.join('\n')}';

    final apiMessages = <Map<String, dynamic>>[
      {'role': 'system', 'content': summaryText},
      ...recentMessages.map<Map<String, dynamic>>((m) => {
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.text,
          }),
    ];

    return apiMessages;
  }

  Future<Response> _callChatApiWithRetry(
      List<Map<String, dynamic>> apiMessages) async {
    const maxRetries = 3;
    const baseDelay = Duration(seconds: 1);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await _service.callChatApi(apiMessages);
      } catch (e) {
        if (attempt == maxRetries - 1) {
          rethrow;
        }
        final delay = baseDelay * (1 << attempt);
        debugPrint(
            '[NovaNotifier] API attempt ${attempt + 1} failed: $e. Retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
      }
    }
    throw Exception('Failed to connect after retries');
  }

  String _getUserFriendlyError(Object error) {
    debugPrint('[NovaNotifier] Converting error: $error');
    String msg = 'Something went wrong. Please try again.';
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        msg = 'Connection timed out. The server may be slow or unreachable.';
      } else if (error.type == DioExceptionType.connectionError) {
        msg = 'Unable to connect to the server. Please ensure the backend is running.';
      } else if (error.response?.statusCode != null) {
        final data = error.response?.data;
        final serverMsg = (data is Map) ? data['message'] : data;
        msg = 'Server error (${error.response!.statusCode}): ${serverMsg ?? "No response content"}';
      } else {
        msg = error.message ?? msg;
      }
    } else {
      msg = error.toString();
    }
    return msg;
  }

  void retryLastFailedMessage() {
    final failed = state.lastFailedMessage;
    if (failed != null && failed.isNotEmpty) {
      state = state.copyWith(lastFailedMessage: null);
      sendMessage(failed);
    }
  }

  void _streamResponse(String text) {
    _streamTimer?.cancel();
    if (_disposed) return;
    var displayed = '';
    final words = text.split(' ');
    var wordIndex = 0;

    _streamTimer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (_disposed || wordIndex >= words.length) {
        timer.cancel();
        if (!_disposed) {
          state = state.copyWith(isTyping: false);
          _saveHistory();
          _persistMemoryInBackground();
        }
        return;
      }
      displayed += '${wordIndex > 0 ? ' ' : ''}${words[wordIndex]}';
      wordIndex++;

      final msgs = [...state.messages];
      if (msgs.isNotEmpty) {
        msgs[msgs.length - 1] = msgs.last.copyWith(
          text: displayed,
          isStreaming: wordIndex < words.length,
        );
        state = state.copyWith(messages: msgs);
      }
    });
  }

  void _persistMemoryInBackground() {
    if (state.messages.isEmpty) return;
    final messages = state.messages
        .where((m) => m.text.isNotEmpty)
        .map((m) => m.toJson())
        .toList();
    final lastUserMsg = state.messages.lastWhere(
        (m) => m.isUser && m.text.isNotEmpty,
        orElse: () => NovaMessage(text: '', isUser: true));
    final tone = _contextBuilder.detectEmotionalTone(lastUserMsg.text);
    _memoryService.saveConversationMemory(
        messages: messages, emotionalTone: tone);
    _memoryService.detectAndSaveGoals(messages);
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

  void submitVoiceInput(String transcribedText) {
    if (transcribedText.trim().isNotEmpty) {
      sendMessage(transcribedText.trim());
    }
  }

  void stopGenerating() {
    _streamTimer?.cancel();
    state = state.copyWith(isTyping: false);
    _saveHistory();
  }

  void regenerateResponse() {
    if (_disposed || state.messages.isEmpty || state.isLoading || state.isTyping) return;

    final msgs = [...state.messages];
    if (msgs.isEmpty) return;

    String? lastUserText;
    if (!msgs.last.isUser) {
      msgs.removeLast();
    }

    if (msgs.isNotEmpty && msgs.last.isUser) {
      lastUserText = msgs.last.text;
      msgs.removeLast();
    }

    if (lastUserText != null) {
      state = state.copyWith(messages: msgs);
      sendMessage(lastUserText);
    }
  }

  Future<void> clearChat() async {
    try {
      _streamTimer?.cancel();
      _context.lastTopic = null;
      _context.lastEmotion = null;
      _context.topicRepeatCount = 0;
      await _repository.clearHistory();
      state = state.copyWith(messages: const [], clearError: true, lastFailedMessage: null);
    } catch (e) {
      debugPrint('[NovaNotifier] clearChat error: $e');
    }
  }

  String _getLocalFallbackReply(String text) {
    final msg = text.toLowerCase();
    if (msg.contains('anx') || msg.contains('worry') || msg.contains('panic') || msg.contains('nervous')) {
      return "I hear how anxious you're feeling right now, and it's okay to feel this way. Let's take a slow breath together. Inhale gently for 4 seconds... hold... and release. You are safe in this moment. Would you like to try a quick grounding exercise?";
    }
    if (msg.contains('sad') || msg.contains('lonely') || msg.contains('depress') || msg.contains('hurt')) {
      return "I'm so sorry you're feeling down and carrying this sadness right now. Your feelings are completely valid, and you don't have to go through this alone. Be gentle with yourself today. What is one small, comforting thing you can do for yourself?";
    }
    if (msg.contains('sleep') || msg.contains('insomnia') || msg.contains("can't sleep")) {
      return "It can be frustrating when sleep feels out of reach. Let's try to let go of the pressure to fall asleep. Close your eyes, soften your shoulders, and focus on the cool air entering your nose and warm air leaving. I'm here if you need to talk.";
    }
    if (msg.contains('urge') || msg.contains('crave') || msg.contains('relapse')) {
      return "I hear the strength of the urge you're facing. Acknowledge the urge without acting on it—it is like a wave that will peak and eventually subside. Breathe through it. Let's redirect your focus. Would you like to open your recovery safety tools?";
    }
    return "Thank you for reaching out and sharing that with me. I'm here to listen and support you. Remember to take it one gentle breath at a time. What's on your mind?";
  }

  void _saveHistory() {
    _repository.saveHistory(state.messages);
  }
}

// Repository & Service providers
final novaRepositoryProvider = Provider<NovaRepository>((ref) => NovaRepository());
final novaServiceProvider = Provider<NovaService>((ref) => NovaService());

// Centralized Nova Provider
final novaProvider = StateNotifierProvider<NovaNotifier, NovaState>((ref) {
  final repo = ref.watch(novaRepositoryProvider);
  final service = ref.watch(novaServiceProvider);
  return NovaNotifier(repository: repo, service: service);
});
