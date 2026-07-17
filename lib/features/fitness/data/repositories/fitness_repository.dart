import 'package:mental_mantra/core/network/api_client.dart';
import '../models/fitness_record.dart';

class FitnessRepository {
  Future<FitnessRecord?> getTodayRecord() async {
    final records = await getHistory(days: 1);
    return records.isNotEmpty ? records.first : null;
  }

  Future<List<FitnessRecord>> getHistory({int days = 30}) async {
    try {
      final response = await ApiClient.get('/fitness');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List<dynamic>)
            .map((e) => FitnessRecord.fromJson(
                {...e as Map<String, dynamic>, 'id': e['id'] ?? ''}))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveTodayRecord(FitnessRecord record) async {
    try {
      final response = await ApiClient.post('/fitness', data: record.toJson());
      return (response.data as Map<String, dynamic>)['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> logWorkout(dynamic session) async {
    try {
      await ApiClient.post('/fitness', data: session.toJson());
      return null;
    } catch (e) {
      return null;
    }
  }
}
