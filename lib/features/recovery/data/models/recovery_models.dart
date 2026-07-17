import 'package:flutter/material.dart';

enum UrgeType {
  gaming,
  socialMedia,
  appBrowsing,
  videoStreaming,
  shopping,
  other
}

enum DetoxSessionType { focus, digitalDetox, gamingBreak, socialMediaFree }

enum RecoveryTargetType {
  screenTime,
  gamingHours,
  appUsage,
  abstinenceDays,
  detoxSessions
}

class UrgeLog {
  final String? id;
  final String trigger;
  final int intensity;
  final UrgeType urgeType;
  final bool resisted;
  final String? copingStrategy;
  final String? notes;
  final DateTime createdAt;

  UrgeLog({
    this.id,
    required this.trigger,
    required this.intensity,
    required this.urgeType,
    required this.resisted,
    this.copingStrategy,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'trigger': trigger,
        'intensity': intensity,
        'urgeType': urgeType.name,
        'resisted': resisted,
        'copingStrategy': copingStrategy,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UrgeLog.fromJson(Map<String, dynamic> json) => UrgeLog(
        id: json['id'] as String?,
        trigger: json['trigger'] as String? ?? '',
        intensity: json['intensity'] as int? ?? 5,
        urgeType: UrgeType.values.firstWhere(
          (e) => e.name == json['urgeType'],
          orElse: () => UrgeType.other,
        ),
        resisted: json['resisted'] as bool? ?? false,
        copingStrategy: json['copingStrategy'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  static const List<Map<String, dynamic>> copingStrategies = [
    {
      'id': 'urge_surfing',
      'label': 'Urge Surfing Meditation',
      'icon': Icons.waves
    },
    {
      'id': 'deep_breathing',
      'label': 'Deep Breathing (4-7-8)',
      'icon': Icons.air
    },
    {
      'id': 'physical_activity',
      'label': 'Walk or Exercise',
      'icon': Icons.directions_walk
    },
    {'id': 'journal', 'label': 'Write About the Urge', 'icon': Icons.edit_note},
    {'id': 'cold_water', 'label': 'Drink Cold Water', 'icon': Icons.water_drop},
    {
      'id': 'music',
      'label': 'Listen to Calming Music',
      'icon': Icons.music_note
    },
    {'id': 'talk', 'label': 'Call or Text Someone', 'icon': Icons.phone},
    {
      'id': 'meditation',
      'label': 'Quick Guided Meditation',
      'icon': Icons.self_improvement
    },
    {'id': 'hobby', 'label': 'Do a Different Hobby', 'icon': Icons.palette},
    {'id': 'shower', 'label': 'Take a Cold Shower', 'icon': Icons.shower},
    {'id': 'distraction', 'label': 'Change Environment', 'icon': Icons.explore},
    {
      'id': 'affirmation',
      'label': 'Read Recovery Affirmations',
      'icon': Icons.auto_awesome
    },
  ];
}

class DetoxSession {
  final String? id;
  final DetoxSessionType sessionType;
  final int durationMin;
  final int completedMinutes;
  final bool completed;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? notes;

  const DetoxSession({
    this.id,
    required this.sessionType,
    required this.durationMin,
    this.completedMinutes = 0,
    this.completed = false,
    required this.startedAt,
    this.completedAt,
    this.notes,
  });

  int get progressPercent => durationMin > 0
      ? (completedMinutes * 100 / durationMin).round().clamp(0, 100)
      : 0;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'sessionType': sessionType.name,
        'durationMin': durationMin,
        'completedMinutes': completedMinutes,
        'completed': completed,
        'startedAt': startedAt.toIso8601String(),
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
        'notes': notes,
      };

  factory DetoxSession.fromJson(Map<String, dynamic> json) => DetoxSession(
        id: json['id'] as String?,
        sessionType: DetoxSessionType.values.firstWhere(
          (e) => e.name == json['sessionType'],
          orElse: () => DetoxSessionType.focus,
        ),
        durationMin: json['durationMin'] as int? ?? 25,
        completedMinutes: json['completedMinutes'] as int? ?? 0,
        completed: json['completed'] as bool? ?? false,
        startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
            DateTime.now(),
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
        notes: json['notes'] as String?,
      );

  DetoxSession copyWith({
    String? id,
    DetoxSessionType? sessionType,
    int? durationMin,
    int? completedMinutes,
    bool? completed,
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
  }) =>
      DetoxSession(
        id: id ?? this.id,
        sessionType: sessionType ?? this.sessionType,
        durationMin: durationMin ?? this.durationMin,
        completedMinutes: completedMinutes ?? this.completedMinutes,
        completed: completed ?? this.completed,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        notes: notes ?? this.notes,
      );
}

class RecoveryGoal {
  final String? id;
  final RecoveryTargetType targetType;
  final int targetValue;
  final int currentValue;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const RecoveryGoal({
    this.id,
    required this.targetType,
    required this.targetValue,
    this.currentValue = 0,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  int get progressPercent =>
      targetValue > 0 ? (currentValue * 100 ~/ targetValue).clamp(0, 100) : 0;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'targetType': targetType.name,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        'isActive': isActive,
      };

  factory RecoveryGoal.fromJson(Map<String, dynamic> json) => RecoveryGoal(
        id: json['id'] as String?,
        targetType: RecoveryTargetType.values.firstWhere(
          (e) => e.name == json['targetType'],
          orElse: () => RecoveryTargetType.abstinenceDays,
        ),
        targetValue: json['targetValue'] as int? ?? 1,
        currentValue: json['currentValue'] as int? ?? 0,
        startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ??
            DateTime.now(),
        endDate: json['endDate'] != null
            ? DateTime.tryParse(json['endDate'] as String)
            : null,
        isActive: json['isActive'] as bool? ?? true,
      );
}

class RecoveryStats {
  final int currentStreak;
  final int bestStreak;
  final int totalUrgesLogged;
  final int urgesResisted;
  final int totalDetoxMinutes;
  final int totalDetoxSessions;
  final List<UrgeLog> recentUrges;
  final List<DetoxSession> recentSessions;
  final RecoveryGoal? activeGoal;

  const RecoveryStats({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalUrgesLogged = 0,
    this.urgesResisted = 0,
    this.totalDetoxMinutes = 0,
    this.totalDetoxSessions = 0,
    this.recentUrges = const [],
    this.recentSessions = const [],
    this.activeGoal,
  });

  double get resistanceRate =>
      totalUrgesLogged > 0 ? urgesResisted / totalUrgesLogged : 0;

  RecoveryStats copyWith({
    int? currentStreak,
    int? bestStreak,
    int? totalUrgesLogged,
    int? urgesResisted,
    int? totalDetoxMinutes,
    int? totalDetoxSessions,
    List<UrgeLog>? recentUrges,
    List<DetoxSession>? recentSessions,
    RecoveryGoal? activeGoal,
  }) =>
      RecoveryStats(
        currentStreak: currentStreak ?? this.currentStreak,
        bestStreak: bestStreak ?? this.bestStreak,
        totalUrgesLogged: totalUrgesLogged ?? this.totalUrgesLogged,
        urgesResisted: urgesResisted ?? this.urgesResisted,
        totalDetoxMinutes: totalDetoxMinutes ?? this.totalDetoxMinutes,
        totalDetoxSessions: totalDetoxSessions ?? this.totalDetoxSessions,
        recentUrges: recentUrges ?? this.recentUrges,
        recentSessions: recentSessions ?? this.recentSessions,
        activeGoal: activeGoal ?? this.activeGoal,
      );
}
