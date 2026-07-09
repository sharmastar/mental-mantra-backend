class SleepRecord {
  final String? id;
  final DateTime date;
  final int durationMinutes;
  final int qualityRating;
  final DateTime? bedtime;
  final DateTime? wakeTime;
  final List<String> notes;
  final List<String> factors;
  final bool hasNightWakeups;

  const SleepRecord({
    this.id,
    required this.date,
    required this.durationMinutes,
    this.qualityRating = 3,
    this.bedtime,
    this.wakeTime,
    this.notes = const [],
    this.factors = const [],
    this.hasNightWakeups = false,
  });

  String get durationLabel {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
  }

  String get qualityLabel {
    switch (qualityRating) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return 'Unknown';
    }
  }

  factory SleepRecord.fromJson(Map<String, dynamic> json) => SleepRecord(
    id: json['id'] as String?,
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    durationMinutes: json['durationMinutes'] as int? ?? 0,
    qualityRating: json['qualityRating'] as int? ?? 3,
    bedtime: json['bedtime'] != null ? DateTime.tryParse(json['bedtime'] as String) : null,
    wakeTime: json['wakeTime'] != null ? DateTime.tryParse(json['wakeTime'] as String) : null,
    notes: List<String>.from(json['notes'] ?? []),
    factors: List<String>.from(json['factors'] ?? []),
    hasNightWakeups: json['hasNightWakeups'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'date': date.toIso8601String().split('T')[0],
    'durationMinutes': durationMinutes,
    'qualityRating': qualityRating,
    'bedtime': bedtime?.toIso8601String(),
    'wakeTime': wakeTime?.toIso8601String(),
    'notes': notes,
    'factors': factors,
    'hasNightWakeups': hasNightWakeups,
  };

  SleepRecord copyWith({
    String? id,
    DateTime? date,
    int? durationMinutes,
    int? qualityRating,
    DateTime? bedtime,
    DateTime? wakeTime,
    List<String>? notes,
    List<String>? factors,
    bool? hasNightWakeups,
  }) => SleepRecord(
    id: id ?? this.id,
    date: date ?? this.date,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    qualityRating: qualityRating ?? this.qualityRating,
    bedtime: bedtime ?? this.bedtime,
    wakeTime: wakeTime ?? this.wakeTime,
    notes: notes ?? this.notes,
    factors: factors ?? this.factors,
    hasNightWakeups: hasNightWakeups ?? this.hasNightWakeups,
  );
}

class SleepStats {
  final int averageDurationMinutes;
  final int averageQuality;
  final int totalSessions;
  final int currentStreak;
  final int bestStreak;
  final List<SleepRecord> recentRecords;

  const SleepStats({
    this.averageDurationMinutes = 0,
    this.averageQuality = 0,
    this.totalSessions = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.recentRecords = const [],
  });
}
