import 'package:mental_mantra/core/network/api_client.dart';
import '../models/journal_entry.dart';

class JournalRepository {
  Future<List<JournalEntry>> getEntries(
      {int limit = 20, int skip = 0, String? search}) async {
    try {
      final params = <String, dynamic>{'limit': limit, 'skip': skip};
      if (search != null) params['search'] = search;
      final response = await ApiClient.get('/journal', queryParameters: params);
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final entriesData = data['data']['entries'] as List<dynamic>? ?? [];
        return entriesData
            .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>, ''))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<JournalEntry?> getEntry(String entryId) async {
    try {
      final response = await ApiClient.get('/journal/$entryId');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return JournalEntry.fromJson(data['data'] as Map<String, dynamic>, '');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> createEntry(JournalEntry entry) async {
    try {
      final response = await ApiClient.post('/journal', data: entry.toJson());
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return data['data']['id'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateEntry(String entryId, Map<String, dynamic> updates) async {
    try {
      await ApiClient.put('/journal/$entryId', data: updates);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteEntry(String entryId) async {
    try {
      await ApiClient.delete('/journal/$entryId');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getEntryCount() async {
    final entries = await getEntries(limit: 1);
    return entries.length;
  }

  Future<Map<String, dynamic>> getStats() async {
    final entries = await getEntries(limit: 100);
    if (entries.isEmpty) return {'count': 0, 'avgMood': 0.0, 'streak': 0};
    final avgMood =
        entries.fold(0.0, (acc, e) => acc + e.mood) / entries.length;
    return {'count': entries.length, 'avgMood': avgMood};
  }

  Future<bool> saveAiAnalysis(
      String entryId, Map<String, dynamic> analysis) async {
    try {
      await ApiClient.put('/journal/$entryId/analysis', data: analysis);
      return true;
    } catch (e) {
      return false;
    }
  }
}
