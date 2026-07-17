// lib/core/analytics/analytics_service.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static bool _enabled = true;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Logs when a message is sent in the AI Therapist Chatbot
  static Future<void> logMessageSent({
    required String senderType, // 'user' or 'ai'
    required bool hasImage,
    required bool hasVoice,
    required String? mood,
  }) async {
    if (!_enabled) return;
    try {
      await _analytics.logEvent(
        name: 'ai_chat_message_sent',
        parameters: {
          'sender_type': senderType,
          'has_image': hasImage ? 1 : 0,
          'has_voice': hasVoice ? 1 : 0,
          if (mood != null) 'mood_context': mood,
        },
      );
      debugPrint('[Analytics] Logged ai_chat_message_sent (senderType: $senderType)');
    } catch (e) {
      debugPrint('[Analytics] Error logging event: $e');
    }
  }

  /// Logs when a chat session starts
  static Future<void> logSessionStart({required String sessionId}) async {
    if (!_enabled) return;
    try {
      await _analytics.logEvent(
        name: 'ai_chat_session_start',
        parameters: {
          'session_id': sessionId,
        },
      );
      debugPrint('[Analytics] Logged ai_chat_session_start (id: $sessionId)');
    } catch (e) {
      debugPrint('[Analytics] Error logging event: $e');
    }
  }

  /// Logs when a chat session ends and records the duration
  static Future<void> logSessionEnd({
    required String sessionId,
    required int durationSeconds,
    required int totalMessages,
  }) async {
    if (!_enabled) return;
    try {
      await _analytics.logEvent(
        name: 'ai_chat_session_end',
        parameters: {
          'session_id': sessionId,
          'duration_seconds': durationSeconds,
          'total_messages': totalMessages,
        },
      );
      debugPrint('[Analytics] Logged ai_chat_session_end (id: $sessionId, duration: ${durationSeconds}s)');
    } catch (e) {
      debugPrint('[Analytics] Error logging event: $e');
    }
  }

  /// Logs when safety guidelines/moderation block a prompt or response
  static Future<void> logSafetyTrigger({
    required String triggerType, // 'self_harm', 'suicide', 'medication_prescribe', 'prohibited_illness'
    required double confidence,
    required bool isUserMessage,
  }) async {
    if (!_enabled) return;
    try {
      await _analytics.logEvent(
        name: 'ai_chat_safety_trigger',
        parameters: {
          'trigger_type': triggerType,
          'confidence': confidence,
          'is_user_message': isUserMessage ? 1 : 0,
        },
      );
      debugPrint('[Analytics] WARNING: Safety filter triggered for $triggerType (confidence: $confidence)');
    } catch (e) {
      debugPrint('[Analytics] Error logging event: $e');
    }
  }

  /// Logs whenever a conversation is exported to PDF
  static Future<void> logConversationExported({
    required String sessionId,
    required int messageCount,
  }) async {
    if (!_enabled) return;
    try {
      await _analytics.logEvent(
        name: 'ai_chat_export_pdf',
        parameters: {
          'session_id': sessionId,
          'message_count': messageCount,
        },
      );
      debugPrint('[Analytics] Logged ai_chat_export_pdf');
    } catch (e) {
      debugPrint('[Analytics] Error logging event: $e');
    }
  }
}
