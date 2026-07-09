import 'package:mental_mantra/core/storage/hive_storage.dart';
import 'personalization_context.dart';

class PersonalizationRepository {
  static const _classificationKeyV2 = 'classification_result_v2';
  static const _memoryKey = 'ai_memory_summary';
  static const _classificationKeyV1 = 'classification_result';

  Future<PersonalizationContext> build() async {
    final classification = await _getClassification();
    final profile = await HiveStorage.getWellnessProfile();
    final recentMoods = await HiveStorage.getRecentMoods(days: 7);
    final memory = _getMemory();
    final onboardingData = await HiveStorage.getOnboardingData();
    final user = HiveStorage.getUser();

    return PersonalizationContext(
      primaryDomain: classification?['primaryDomain'] as String?,
      secondaryDomains: _stringList(classification?['secondaryDomains']),
      domainScores: _stringDoubleMap(classification?['scores']),
      confidence: (classification?['confidence'] as num?)?.toDouble() ?? 0.0,
      riskLevel: classification?['riskLevel'] as String? ?? profile['riskLevel'] as String? ?? 'low',
      completedAt: classification?['completedAt'] as String?,
      version: (classification?['version'] as num?)?.toInt() ?? 0,

      overallWellnessScore: (profile['overallScore'] as num?)?.toDouble(),
      primaryConcerns: _stringList(profile['primaryConcerns']),
      strengths: _stringList(profile['strengths']),

      averageMood: _computeAverageMood(recentMoods),
      moodEntryCount: recentMoods.length,
      moodTrend: _computeMoodTrend(recentMoods),

      memorySummary: memory,

      spiritualMode: onboardingData['spiritual_mode'] == true,
      language: onboardingData['language'] as String? ?? 'en',
      currentStreak: (user['streakDays'] as num?)?.toInt() ?? 0,
      totalPoints: (user['totalPoints'] as num?)?.toInt() ?? 0,
      level: (user['level'] as num?)?.toInt() ?? 1,
      onboardingCompleted: (user['onboardingCompleted'] as bool?) ?? false,
      lastMeditationType: onboardingData['lastMeditationType'] as String?,
    );
  }

  Future<void> saveClassification(Map<String, dynamic> data) async {
    final v2 = <String, dynamic>{
      ...data,
      'version': (data['version'] as num?)?.toInt() ?? 2,
      'completedAt': data['completedAt'] ?? DateTime.now().toIso8601String(),
    };
    await HiveStorage.saveCache(_classificationKeyV2, v2);
  }

  Future<Map<String, dynamic>?> _getClassification() async {
    final v2 = HiveStorage.getCache(_classificationKeyV2);
    if (v2 != null && v2 is Map) {
      return Map<String, dynamic>.from(v2);
    }

    final v1 = HiveStorage.getCache(_classificationKeyV1);
    if (v1 != null && v1 is Map) {
      final migrated = _migrateV1ToV2(Map<String, dynamic>.from(v1));
      await saveClassification(migrated);
      return migrated;
    }

    final onboardingData = await HiveStorage.getOnboardingData();
    final wrRaw = onboardingData['wellness_result'];
    if (wrRaw != null && wrRaw is Map) {
      final wr = Map<String, dynamic>.from(wrRaw);
      final inferred = _inferFromWellnessResult(wr);
      await saveClassification(inferred);
      return inferred;
    }

    return null;
  }

  String? _getMemory() {
    final data = HiveStorage.getCache(_memoryKey);
    return data as String?;
  }

  Map<String, dynamic> _migrateV1ToV2(Map<String, dynamic> v1) {
    return {
      'primaryDomain': v1['primaryDomain'],
      'secondaryDomains': v1['secondaryDomains'] ?? [],
      'scores': v1['scores'] ?? v1['domainScores'] ?? {},
      'confidence': v1['confidence'] ?? 0.0,
      'riskLevel': v1['riskLevel'] ?? 'low',
      'completedAt': v1['completedAt'] ?? DateTime.now().toIso8601String(),
      'version': 2,
    };
  }

  Map<String, dynamic> _inferFromWellnessResult(Map<String, dynamic> wr) {
    final domainScores = <String, double>{};
    final rawScores = (wr['domainScores'] is Map)
        ? Map<String, dynamic>.from(wr['domainScores'] as Map)
        : <String, dynamic>{};
    for (final entry in rawScores.entries) {
      domainScores[_mapDomainKey(entry.key)] = (entry.value as num).toDouble();
    }

    final sorted = domainScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'primaryDomain': sorted.isNotEmpty ? sorted.first.key : null,
      'secondaryDomains': sorted.length > 1 ? [sorted[1].key] : [],
      'scores': domainScores,
      'confidence': sorted.isNotEmpty ? sorted.first.value / 10.0 : 0.0,
      'riskLevel': wr['needsCrisisSupport'] == true ? 'high' : 'low',
      'completedAt': DateTime.now().toIso8601String(),
      'version': 2,
    };
  }

  String _mapDomainKey(String name) {
    return switch (name) {
      'Stress & Burnout' => 'stress_burnout',
      'Anxiety & Overthinking' => 'anxiety_overthinking',
      'Low Mood' => 'stress_burnout',
      'Sleep Wellness' => 'sleep_dysregulation',
      'Relationship Wellness' => 'emotional_isolation',
      'Habit Recovery' => 'addiction_recovery',
      'Confidence Building' => 'low_motivation',
      'Social Connection' => 'emotional_isolation',
      'Mindfulness & Inner Peace' => 'spiritual_seeking',
      _ => name.toLowerCase().replaceAll(' ', '_').replaceAll('&', '').replaceAll('__', '_').trim(),
    };
  }

  double _computeAverageMood(List<Map<String, dynamic>> moods) {
    if (moods.isEmpty) return 3.0;
    final sum = moods.fold<double>(0.0, (s, m) {
      final val = m['mood'];
      return s + ((val is num) ? val.toDouble() : 3.0);
    });
    return sum / moods.length;
  }

  String _computeMoodTrend(List<Map<String, dynamic>> moods) {
    if (moods.length < 2) return 'stable';
    final first = moods.last;
    final last = moods.first;
    final fVal = (first['mood'] as num?)?.toDouble() ?? 3.0;
    final lVal = (last['mood'] as num?)?.toDouble() ?? 3.0;
    final diff = lVal - fVal;
    if (diff > 0.5) return 'improving';
    if (diff < -0.5) return 'declining';
    return 'stable';
  }

  List<String> _stringList(dynamic value) {
    if (value is List) return value.whereType<String>().toList();
    return [];
  }

  Map<String, double> _stringDoubleMap(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
    }
    return {};
  }
}
