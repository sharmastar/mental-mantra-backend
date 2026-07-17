import 'package:flutter/foundation.dart';
import 'package:mental_mantra/core/network/api_client.dart';

import '../models/meditation_session.dart';
import '../meditation_catalog.dart';

class MeditationRepository {
  Future<List<MeditationCategory>> getCategories() async {
    return MeditationCatalog.categories;
  }

  Future<List<MeditationSession>> getSessions() async {
    try {
      final response = await ApiClient.get('/meditation/history');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final sessions = data['data']['sessions'] as List<dynamic>? ?? [];
        return sessions.map((s) {
          final json = s as Map<String, dynamic>;
          return MeditationSession(
            id: json['id'] as String? ?? '',
            title: json['sessionName'] as String? ?? '',
            durationSeconds: (json['durationMin'] as int? ?? 0) * 60,
            imageUrl: '',
            description: json['category'] as String? ?? 'General',
            audioUrl: '',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('MeditationRepository.getSessions: $e');
    }
    return MeditationCatalog.allSessions;
  }

  Future<void> logSession(
      String sessionName, String category, int durationMin) async {
    try {
      await ApiClient.post('/meditation/session', data: {
        'sessionName': sessionName,
        'category': category,
        'durationMin': durationMin,
      });
    } catch (e) {
      debugPrint('MeditationRepository.logSession: $e');
    }
  }

  Future<void> toggleFavorite(String sessionId, bool isFavorite) async {
    try {
      await ApiClient.put('/meditation/$sessionId/favorite',
          data: {'isFavorite': isFavorite});
    } catch (e) {
      debugPrint('MeditationRepository.toggleFavorite: $e');
    }
  }

  Future<void> markCompleted(String sessionId) async {
    try {
      await ApiClient.post('/meditation/$sessionId/complete');
    } catch (e) {
      debugPrint('MeditationRepository.markCompleted: $e');
    }
  }
}
