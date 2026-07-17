import 'package:mental_mantra/core/storage/hive_storage.dart';
import '../models/nova_conversation_history.dart';

class NovaRepository {
  Future<List<NovaMessage>> loadHistory() async {
    final saved = await HiveStorage.getChatHistory();
    return saved.map((m) => NovaMessage.fromJson(Map<String, dynamic>.from(m))).toList();
  }

  Future<void> saveHistory(List<NovaMessage> messages) async {
    final list = messages.map((m) => m.toJson()).toList();
    await HiveStorage.saveChatHistory(list);
  }

  Future<void> clearHistory() async {
    await HiveStorage.clearChatHistory();
  }

  Future<Map<String, dynamic>?> loadWellnessProfile() async {
    return await HiveStorage.getWellnessProfile();
  }
}
