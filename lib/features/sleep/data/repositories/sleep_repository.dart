import 'package:mental_mantra/core/network/api_client.dart';
import '../models/sleep_record.dart';

class SleepRepository {
  Future<List<SleepRecord>> getRecords({int limit = 30}) async {
    try {
      final response = await ApiClient.get('/sleep');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List<dynamic>)
            .map((e) => SleepRecord.fromJson(
                {...e as Map<String, dynamic>, 'id': e['id'] ?? ''}))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addRecord(SleepRecord record) async {
    try {
      final response = await ApiClient.post('/sleep', data: record.toJson());
      return (response.data as Map<String, dynamic>)['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      await ApiClient.delete('/sleep/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRecord(String id, SleepRecord record) async {
    try {
      await ApiClient.put('/sleep/$id', data: record.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<SleepStats> computeStats() async {
    final records = await getRecords(limit: 90);
    if (records.isEmpty) return const SleepStats();

    final totalDuration =
        records.fold(0, (int sum, r) => sum + r.durationMinutes);
    final totalQuality = records.fold(0, (int sum, r) => sum + r.qualityRating);
    final averageDuration = totalDuration ~/ records.length;
    final averageQuality = totalQuality ~/ records.length;

    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < records.length; i++) {
      final expected = today.subtract(Duration(days: i));
      final recordDate = records[i].date;
      if (recordDate.year == expected.year &&
          recordDate.month == expected.month &&
          recordDate.day == expected.day) {
        streak++;
      } else {
        break;
      }
    }

    return SleepStats(
      averageDurationMinutes: averageDuration,
      averageQuality: averageQuality,
      totalSessions: records.length,
      currentStreak: streak,
      bestStreak: streak,
      recentRecords: records.take(7).toList(),
    );
  }
}
