class FitnessRecord {
  final String? id;
  final DateTime date;
  final int steps;
  final double caloriesBurned;
  final int activeMinutes;
  final double? heartRateAvg;
  final double? heartRateMax;
  final List<WorkoutSession> workouts;

  const FitnessRecord({
    this.id,
    required this.date,
    this.steps = 0,
    this.caloriesBurned = 0,
    this.activeMinutes = 0,
    this.heartRateAvg,
    this.heartRateMax,
    this.workouts = const [],
  });

  factory FitnessRecord.fromJson(Map<String, dynamic> json) => FitnessRecord(
        id: json['id'] as String?,
        date:
            DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        steps: json['steps'] as int? ?? 0,
        caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0,
        activeMinutes: json['activeMinutes'] as int? ?? 0,
        heartRateAvg: (json['heartRateAvg'] as num?)?.toDouble(),
        heartRateMax: (json['heartRateMax'] as num?)?.toDouble(),
        workouts: (json['workouts'] as List<dynamic>?)
                ?.map((w) => WorkoutSession.fromJson(w as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'date': date.toIso8601String().split('T')[0],
        'steps': steps,
        'caloriesBurned': caloriesBurned,
        'activeMinutes': activeMinutes,
        'heartRateAvg': heartRateAvg,
        'heartRateMax': heartRateMax,
        'workouts': workouts.map((w) => w.toJson()).toList(),
      };
}

enum WorkoutType {
  walking,
  running,
  cycling,
  yoga,
  strength,
  meditation,
  stretching,
  other
}

class WorkoutSession {
  final String? id;
  final WorkoutType type;
  final int durationMinutes;
  final double caloriesBurned;
  final double? distanceKm;
  final int? heartRateAvg;
  final String? notes;
  final DateTime startedAt;

  const WorkoutSession({
    this.id,
    required this.type,
    required this.durationMinutes,
    this.caloriesBurned = 0,
    this.distanceKm,
    this.heartRateAvg,
    this.notes,
    required this.startedAt,
  });

  String get typeLabel {
    switch (type) {
      case WorkoutType.walking:
        return 'Walking';
      case WorkoutType.running:
        return 'Running';
      case WorkoutType.cycling:
        return 'Cycling';
      case WorkoutType.yoga:
        return 'Yoga';
      case WorkoutType.strength:
        return 'Strength Training';
      case WorkoutType.meditation:
        return 'Meditation';
      case WorkoutType.stretching:
        return 'Stretching';
      case WorkoutType.other:
        return 'Other';
    }
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'] as String?,
        type: WorkoutType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => WorkoutType.other,
        ),
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        heartRateAvg: json['heartRateAvg'] as int?,
        notes: json['notes'] as String?,
        startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'type': type.name,
        'durationMinutes': durationMinutes,
        'caloriesBurned': caloriesBurned,
        'distanceKm': distanceKm,
        'heartRateAvg': heartRateAvg,
        'notes': notes,
        'startedAt': startedAt.toIso8601String(),
      };
}

class FitnessStats {
  final int dailyStepGoal;
  final int averageSteps;
  final int totalActiveMinutes;
  final double totalCaloriesBurned;
  final int streakDays;
  final List<FitnessRecord> weeklyHistory;

  const FitnessStats({
    this.dailyStepGoal = 10000,
    this.averageSteps = 0,
    this.totalActiveMinutes = 0,
    this.totalCaloriesBurned = 0,
    this.streakDays = 0,
    this.weeklyHistory = const [],
  });
}
