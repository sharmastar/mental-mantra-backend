// lib/core/storage/hive_storage.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveStorage {
  HiveStorage._();

  static const String userBoxName = 'user_box';
  static const String settingsBoxName = 'settings_box';
  static const String journalBoxName = 'journal_box';
  static const String habitBoxName = 'habit_box';
  static const String meditationBoxName = 'meditation_box';
  static const String musicBoxName = 'music_box';
  static const String moodBoxName = 'mood_box';
  static const String chatBoxName = 'chat_box';
  static const String goalsBoxName = 'goals_box';
  static const String cacheBoxName = 'cache_box';

  static late Box<dynamic> _userBox;
  static late Box<dynamic> _settingsBox;
  static late Box<dynamic> _cacheBox;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    _userBox = await Hive.openBox<dynamic>(userBoxName);
    _settingsBox = await Hive.openBox<dynamic>(settingsBoxName);
    _cacheBox = await Hive.openBox<dynamic>(cacheBoxName);
  }

  static Future<Box<dynamic>> openBox(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box<dynamic>(name);
    return Hive.openBox<dynamic>(name);
  }

  // ── User Box ──────────────────────────────────────────────────────
  static Box<dynamic> get userBox => _userBox;

  static Future<void> saveUser(Map<String, dynamic> data) async {
    await _userBox.putAll(data);
  }

  static Map<String, dynamic> getUser() {
    return Map<String, dynamic>.from(_userBox.toMap());
  }

  static Future<void> clearUser() async => _userBox.clear();

  // ── Settings Box ──────────────────────────────────────────────────
  static Box<dynamic> get settingsBox => _settingsBox;

  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  // ── Cache Box ─────────────────────────────────────────────────────
  static Box<dynamic> get cacheBox => _cacheBox;

  static Future<void> saveCache(String key, dynamic value) async {
    await _cacheBox.put(key, value);
  }

  static dynamic getCache(String key) => _cacheBox.get(key);

  static Future<void> deleteCache(String key) async => _cacheBox.delete(key);

  static Future<void> clearCache() async => _cacheBox.clear();

  // ── Onboarding ────────────────────────────────────────────────────
  static Future<void> saveOnboardingData(Map<String, dynamic> data) async {
    final box = await openBox('onboarding_box');
    await box.putAll(data);
    if (data.containsKey('wellness_result')) {
      await _cacheBox.put('wellness_result', data['wellness_result']);
    }
  }

  static Future<Map<String, dynamic>> getOnboardingData() async {
    final box = await openBox('onboarding_box');
    return Map<String, dynamic>.from(box.toMap());
  }

  // ── Mood Cache ────────────────────────────────────────────────────
  static Future<void> saveMoodEntry(String date, Map<String, dynamic> entry) async {
    final box = await openBox(moodBoxName);
    await box.put(date, entry);
  }

  static Future<List<Map<String, dynamic>>> getRecentMoods({int days = 7}) async {
    final box = await openBox(moodBoxName);
    final results = <Map<String, dynamic>>[];
    final keys = box.keys.toList()..sort((a, b) => b.compareTo(a));
    for (int i = 0; i < keys.length && i < days; i++) {
      final val = box.get(keys[i]);
      if (val != null) results.add(Map<String, dynamic>.from(val));
    }
    return results;
  }

  // ── Journal Cache ─────────────────────────────────────────────────
  static Future<void> saveJournalDraft(Map<String, dynamic> draft) async {
    final box = await openBox(journalBoxName);
    await box.put('draft', draft);
  }

  static Future<Map<String, dynamic>?> getJournalDraft() async {
    final box = await openBox(journalBoxName);
    final val = box.get('draft');
    return val != null ? Map<String, dynamic>.from(val) : null;
  }

  static Future<void> clearJournalDraft() async {
    final box = await openBox(journalBoxName);
    await box.delete('draft');
  }

  // ── AI Coach Service Cache ────────────────────────────────────────
  static Future<void> saveWellnessProfile(Map<String, dynamic> data) async {
    await _cacheBox.put('wellness_profile', data);
  }

  static Future<Map<String, dynamic>> getWellnessProfile() async {
    final data = _cacheBox.get('wellness_profile');
    return data != null ? Map<String, dynamic>.from(data) : {};
  }

  static Future<void> saveDailyPlan(Map<String, dynamic> data) async {
    await _cacheBox.put('daily_plan', data);
  }

  static Future<Map<String, dynamic>?> getDailyPlan() async {
    final data = _cacheBox.get('daily_plan');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<Map<String, dynamic>?> getLastCheckin() async {
    final data = _cacheBox.get('last_checkin');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<Map<String, dynamic>> getWeekData() async {
    final data = _cacheBox.get('week_data');
    return data != null ? Map<String, dynamic>.from(data) : {};
  }

  // ── Chat History ──────────────────────────────────────────────────
  static Future<void> saveChatHistory(List<Map<String, dynamic>> messages) async {
    final box = await openBox(chatBoxName);
    await box.put('chat_history', messages);
  }

  static Future<List<Map<String, dynamic>>> getChatHistory() async {
    final box = await openBox(chatBoxName);
    final data = box.get('chat_history');
    if (data != null && data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> clearChatHistory() async {
    final box = await openBox(chatBoxName);
    await box.delete('chat_history');
  }

  // ── Classification v2 ──────────────────────────────────────────────
  static const String classificationBoxName = 'classification_box';

  static Future<void> saveClassificationV2(Map<String, dynamic> data) async {
    await _cacheBox.put('classification_result_v2', data);
  }

  static Map<String, dynamic>? getClassificationV2() {
    final data = _cacheBox.get('classification_result_v2');
    return data is Map<String, dynamic> ? data : null;
  }

  // ── Cleanup ───────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    await _userBox.clear();
    await _settingsBox.clear();
    await _cacheBox.clear();
  }
}
