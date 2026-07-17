import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  TtsService._();

  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isPlaying = false;
  static String? _currentPlayingMessageId;
  static final ValueNotifier<String?> speakingIdNotifier = ValueNotifier<String?>(null);

  static Future<void> init() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Warm, friendly, supportive pace
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        speakingIdNotifier.value = _currentPlayingMessageId;
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        _currentPlayingMessageId = null;
        speakingIdNotifier.value = null;
      });

      _flutterTts.setErrorHandler((msg) {
        _isPlaying = false;
        _currentPlayingMessageId = null;
        speakingIdNotifier.value = null;
        debugPrint('[TTS] Error: $msg');
      });
    } catch (e) {
      debugPrint('[TTS] Init failed: $e');
    }
  }

  static bool isSpeaking(String messageId) =>
      _isPlaying && _currentPlayingMessageId == messageId;

  static Future<void> speak(String messageId, String text) async {
    if (isSpeaking(messageId)) {
      await stop();
      return;
    }
    await stop();
    _currentPlayingMessageId = messageId;

    // Remove markdown symbols before reading to keep speech clean
    final cleanText = text
        .replaceAll(RegExp(r'[\*\#\_`~>]'), '')
        .replaceAll(RegExp(r'\[.*\]\(.*\)'), '');

    try {
      await _flutterTts.speak(cleanText);
    } catch (e) {
      debugPrint('[TTS] Speak error: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
      _currentPlayingMessageId = null;
      speakingIdNotifier.value = null;
    } catch (e) {
      debugPrint('[TTS] Stop error: $e');
    }
  }
}
