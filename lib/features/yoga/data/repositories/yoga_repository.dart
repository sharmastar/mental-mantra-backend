import 'package:mental_mantra/core/network/api_client.dart';
import '../models/yoga_class.dart';
import '../yoga_catalog.dart';

class YogaRepository {
  Future<List<YogaClass>> getClasses() async {
    try {
      final response = await ApiClient.get('/yoga');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final sessions = (data['data'] as List<dynamic>);
        if (sessions.isNotEmpty) {
          return sessions.map((s) {
            final json = s as Map<String, dynamic>;
            return YogaClass(
              id: json['id'] as String? ?? '',
              title: json['sessionName'] as String? ?? '',
              durationMinutes: json['durationMin'] as int? ?? 10,
              imageUrl: '',
              description: json['category'] as String? ?? 'General',
              videoUrl: '',
            );
          }).toList();
        }
      }
    } catch (_) {}
    return YogaCatalog.classes;
  }

  Future<void> logSession(String sessionName, String category, int durationMin) async {
    try {
      await ApiClient.post('/yoga', data: {
        'sessionName': sessionName,
        'category': category,
        'durationMin': durationMin,
      });
    } catch (_) {}
  }

  Future<void> toggleFavorite(String classId, bool isFavorite) async {
    try {
      await ApiClient.put('/yoga/$classId/favorite', data: {'isFavorite': isFavorite});
    } catch (_) {}
  }
}
