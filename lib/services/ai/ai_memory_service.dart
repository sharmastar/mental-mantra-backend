// lib/services/ai/ai_memory_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mental_mantra/core/storage/hive_storage.dart';

/// Represents a compressed memory entry stored about the AI conversation context.
class MemoryEntry {
  final String id;
  final String summary;
  final List<String> topics;
  final String emotionalTone;
  final DateTime createdAt;
  final Map<String, dynamic> extras;

  const MemoryEntry({
    required this.id,
    required this.summary,
    required this.topics,
    required this.emotionalTone,
    required this.createdAt,
    this.extras = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'summary': summary,
        'topics': topics,
        'emotionalTone': emotionalTone,
        'createdAt': createdAt.toIso8601String(),
        'extras': extras,
      };

  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
        id: json['id'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        topics: List<String>.from(json['topics'] as List? ?? []),
        emotionalTone: json['emotionalTone'] as String? ?? 'neutral',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        extras: Map<String, dynamic>.from(json['extras'] as Map? ?? {}),
      );
}

/// Stores user goals detected from conversation.
class UserGoal {
  final String id;
  final String goal;
  final String category;
  final DateTime detectedAt;
  final bool isActive;

  const UserGoal({
    required this.id,
    required this.goal,
    required this.category,
    required this.detectedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'goal': goal,
        'category': category,
        'detectedAt': detectedAt.toIso8601String(),
        'isActive': isActive,
      };

  factory UserGoal.fromJson(Map<String, dynamic> json) => UserGoal(
        id: json['id'] as String? ?? '',
        goal: json['goal'] as String? ?? '',
        category: json['category'] as String? ?? 'general',
        detectedAt: DateTime.tryParse(json['detectedAt'] as String? ?? '') ??
            DateTime.now(),
        isActive: json['isActive'] as bool? ?? true,
      );
}

/// Complete AI memory context loaded for each conversation turn.
class AiMemoryContext {
  final List<MemoryEntry> recentMemories;
  final List<UserGoal> activeGoals;
  final List<String> dominantTopics;
  final String overallEmotionalTone;
  final Map<String, dynamic> moodSummary;
  final Map<String, dynamic> meditationSummary;
  final Map<String, dynamic> journalThemes;
  final String? lastSessionSummary;

  const AiMemoryContext({
    required this.recentMemories,
    required this.activeGoals,
    required this.dominantTopics,
    required this.overallEmotionalTone,
    required this.moodSummary,
    required this.meditationSummary,
    required this.journalThemes,
    this.lastSessionSummary,
  });
}

/// Service responsible for persisting, retrieving, and summarizing AI conversation memory.
/// All data is stored locally in a dedicated Hive box for privacy.
class AiMemoryService {
  static const String _boxName = 'ai_memory_box';
  static const String _memoriesKey = 'memories';
  static const String _goalsKey = 'goals';
  static const String _lastSessionKey = 'last_session_summary';
  static const int _maxMemoryEntries = 30;
  static const int _maxGoalsStored = 20;

  // ── Public API ─────────────────────────────────────────────────────

  /// Saves a conversation summary to memory after each session.
  Future<void> saveConversationMemory({
    required List<Map<String, dynamic>> messages,
    required String emotionalTone,
  }) async {
    try {
      if (messages.isEmpty) return;
      final topics = _extractTopics(messages);
      final summary = _summarizeConversation(messages);
      final entry = MemoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        summary: summary,
        topics: topics,
        emotionalTone: emotionalTone,
        createdAt: DateTime.now(),
      );
      final existing = await _loadMemories();
      final updated = [entry, ...existing];
      if (updated.length > _maxMemoryEntries) {
        updated.removeRange(_maxMemoryEntries, updated.length);
      }
      await _saveMemories(updated);
      await _saveLastSessionSummary(summary);
      debugPrint(
          '[AiMemory] Saved conversation memory. Total entries: ${updated.length}');
    } catch (e) {
      debugPrint('[AiMemory] saveConversationMemory error: $e');
    }
  }

  /// Detects and saves user goals mentioned in the conversation.
  Future<void> detectAndSaveGoals(List<Map<String, dynamic>> messages) async {
    try {
      final userMessages = messages
          .where((m) => m['isUser'] == true)
          .map((m) => m['text'] as String? ?? '')
          .join(' ')
          .toLowerCase();

      final detected = <UserGoal>[];
      final goalPatterns = _goalPatterns();
      for (final entry in goalPatterns.entries) {
        if (entry.value.any((kw) => userMessages.contains(kw))) {
          detected.add(UserGoal(
            id: '${entry.key}_${DateTime.now().millisecondsSinceEpoch}',
            goal: _goalLabel(entry.key),
            category: entry.key,
            detectedAt: DateTime.now(),
          ));
        }
      }
      if (detected.isEmpty) return;

      final existing = await _loadGoals();
      final existingCategories = existing.map((g) => g.category).toSet();
      final newGoals = detected
          .where((g) => !existingCategories.contains(g.category))
          .toList();
      if (newGoals.isEmpty) return;

      final updated = [...newGoals, ...existing];
      if (updated.length > _maxGoalsStored) {
        updated.removeRange(_maxGoalsStored, updated.length);
      }
      await _saveGoals(updated);
      debugPrint('[AiMemory] Saved ${newGoals.length} new goals.');
    } catch (e) {
      debugPrint('[AiMemory] detectAndSaveGoals error: $e');
    }
  }

  /// Loads a rich memory context for use in AI prompts.
  Future<AiMemoryContext> loadContext() async {
    try {
      final memories = await _loadMemories();
      final goals = await _loadGoals();
      final recentMoods = await HiveStorage.getRecentMoods(days: 7);
      final lastSession = await _loadLastSessionSummary();

      final dominantTopics = _aggregateTopics(memories.take(10).toList());
      final overallTone = _computeOverallTone(memories.take(7).toList());
      final moodSummary = _summarizeMoods(recentMoods);

      return AiMemoryContext(
        recentMemories: memories.take(5).toList(),
        activeGoals: goals.where((g) => g.isActive).toList(),
        dominantTopics: dominantTopics,
        overallEmotionalTone: overallTone,
        moodSummary: moodSummary,
        meditationSummary: await _getMeditationSummary(),
        journalThemes: await _getJournalThemes(),
        lastSessionSummary: lastSession,
      );
    } catch (e) {
      debugPrint('[AiMemory] loadContext error: $e');
      return const AiMemoryContext(
        recentMemories: [],
        activeGoals: [],
        dominantTopics: [],
        overallEmotionalTone: 'neutral',
        moodSummary: {},
        meditationSummary: {},
        journalThemes: {},
      );
    }
  }

  /// Clears all stored memory (e.g., on account deletion or user request).
  Future<void> clearAllMemory() async {
    try {
      final box = await HiveStorage.openBox(_boxName);
      await box.clear();
      debugPrint('[AiMemory] All memory cleared.');
    } catch (e) {
      debugPrint('[AiMemory] clearAllMemory error: $e');
    }
  }

  // ── Private helpers ────────────────────────────────────────────────

  Future<List<MemoryEntry>> _loadMemories() async {
    try {
      final box = await HiveStorage.openBox(_boxName);
      final raw = box.get(_memoriesKey);
      if (raw == null) return [];
      final list = raw is String
          ? (jsonDecode(raw) as List? ?? [])
          : (raw as List? ?? []);
      return list
          .map((e) => MemoryEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('[AiMemory] _loadMemories error: $e');
      return [];
    }
  }

  Future<void> _saveMemories(List<MemoryEntry> memories) async {
    final box = await HiveStorage.openBox(_boxName);
    await box.put(_memoriesKey, memories.map((m) => m.toJson()).toList());
  }

  Future<List<UserGoal>> _loadGoals() async {
    try {
      final box = await HiveStorage.openBox(_boxName);
      final raw = box.get(_goalsKey);
      if (raw == null) return [];
      final list = raw is String
          ? (jsonDecode(raw) as List? ?? [])
          : (raw as List? ?? []);
      return list
          .map((e) => UserGoal.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('[AiMemory] _loadGoals error: $e');
      return [];
    }
  }

  Future<void> _saveGoals(List<UserGoal> goals) async {
    final box = await HiveStorage.openBox(_boxName);
    await box.put(_goalsKey, goals.map((g) => g.toJson()).toList());
  }

  Future<String?> _loadLastSessionSummary() async {
    final box = await HiveStorage.openBox(_boxName);
    return box.get(_lastSessionKey) as String?;
  }

  Future<void> _saveLastSessionSummary(String summary) async {
    final box = await HiveStorage.openBox(_boxName);
    await box.put(_lastSessionKey, summary);
  }

  String _summarizeConversation(List<Map<String, dynamic>> messages) {
    final userMsgs = messages
        .where((m) => m['isUser'] == true)
        .map((m) => m['text'] as String? ?? '')
        .toList();
    if (userMsgs.isEmpty) return '';
    // Take first and last user messages for a compact summary
    if (userMsgs.length == 1) {
      return userMsgs.first.substring(0, userMsgs.first.length.clamp(0, 120));
    }
    final first =
        userMsgs.first.substring(0, userMsgs.first.length.clamp(0, 80));
    final last = userMsgs.last.substring(0, userMsgs.last.length.clamp(0, 80));
    return 'Started: "$first..." — Ended: "$last..."';
  }

  List<String> _extractTopics(List<Map<String, dynamic>> messages) {
    final allText = messages
        .map((m) => (m['text'] as String? ?? '').toLowerCase())
        .join(' ');
    final found = <String>[];
    final topicMap = {
      'anxiety': ['anx', 'worried', 'nervous', 'panic'],
      'stress': ['stress', 'overwhelm', 'burnout', 'pressure'],
      'sleep': ['sleep', 'insomnia', 'tired', 'rest'],
      'sadness': ['sad', 'lonely', 'depress', 'hopeless'],
      'anger': ['angry', 'frustrat', 'irritat'],
      'motivation': ['motivat', 'lazy', 'procrastin'],
      'mindfulness': ['meditat', 'mindful', 'breath', 'calm'],
      'gratitude': ['grateful', 'thankful', 'appreciate'],
      'relationships': ['relation', 'family', 'friend', 'partner'],
      'work': ['work', 'job', 'career', 'office', 'boss'],
      'recovery': ['habit', 'addict', 'urge', 'quit'],
    };
    for (final entry in topicMap.entries) {
      if (entry.value.any((kw) => allText.contains(kw))) {
        found.add(entry.key);
      }
    }
    return found;
  }

  List<String> _aggregateTopics(List<MemoryEntry> memories) {
    final counts = <String, int>{};
    for (final m in memories) {
      for (final t in m.topics) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toList();
  }

  String _computeOverallTone(List<MemoryEntry> memories) {
    if (memories.isEmpty) return 'neutral';
    final tones = memories.map((m) => m.emotionalTone).toList();
    final counts = <String, int>{};
    for (final t in tones) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Map<String, dynamic> _summarizeMoods(List<Map<String, dynamic>> moods) {
    if (moods.isEmpty) return {};
    final values = moods
        .map((m) =>
            (m['mood'] as num?)?.toDouble() ??
            (m['value'] as num?)?.toDouble() ??
            3.0)
        .toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    return {
      'avgMood': avg.toStringAsFixed(1),
      'trend': values.length > 1
          ? (values.first > values.last
              ? 'improving'
              : values.first < values.last
                  ? 'declining'
                  : 'stable')
          : 'stable',
      'entryCount': values.length,
    };
  }

  Future<Map<String, dynamic>> _getMeditationSummary() async {
    try {
      final box = await HiveStorage.openBox(HiveStorage.meditationBoxName);
      final totalSessions = box.length;
      return {'totalSessions': totalSessions};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> _getJournalThemes() async {
    try {
      final box = await HiveStorage.openBox(HiveStorage.journalBoxName);
      return {'totalEntries': box.length};
    } catch (_) {
      return {};
    }
  }

  Map<String, List<String>> _goalPatterns() => {
        'reduce_anxiety': [
          'reduce anxiety',
          'manage anxiety',
          'less anxious',
          'stop worrying'
        ],
        'better_sleep': [
          'sleep better',
          'improve sleep',
          'sleep earlier',
          'insomnia'
        ],
        'meditate_daily': [
          'meditate every day',
          'daily meditation',
          'meditate more',
          'mindfulness practice'
        ],
        'stress_management': [
          'manage stress',
          'less stressed',
          'handle pressure',
          'reduce stress'
        ],
        'positive_thinking': [
          'think positive',
          'more positive',
          'optimism',
          'gratitude'
        ],
        'exercise_more': [
          'exercise more',
          'walk more',
          'be more active',
          'workout'
        ],
        'recovery': [
          'quit',
          'stop habit',
          'overcome addiction',
          'urge control'
        ],
        'journaling': ['journal every day', 'write more', 'daily journal'],
      };

  String _goalLabel(String category) {
    const labels = {
      'reduce_anxiety': 'Reduce anxiety and worry',
      'better_sleep': 'Improve sleep quality',
      'meditate_daily': 'Build a daily meditation habit',
      'stress_management': 'Better manage stress',
      'positive_thinking': 'Cultivate a positive mindset',
      'exercise_more': 'Be more physically active',
      'recovery': 'Support recovery journey',
      'journaling': 'Develop a journaling habit',
    };
    return labels[category] ?? category;
  }
}
