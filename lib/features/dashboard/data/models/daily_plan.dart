class DailyPlan {
  final List<PlanActivity> morning;
  final List<PlanActivity> afternoon;
  final List<PlanActivity> evening;
  final List<PlanActivity> beforeBed;

  const DailyPlan({
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.beforeBed,
  });

  List<PlanActivity> get allActivities =>
      [...morning, ...afternoon, ...evening, ...beforeBed];
  int get totalDuration =>
      allActivities.fold(0, (sum, a) => sum + a.durationMinutes);

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    return DailyPlan(
      morning: _parseActivities(json['morning']),
      afternoon: _parseActivities(json['afternoon']),
      evening: _parseActivities(json['evening']),
      beforeBed: _parseActivities(json['beforeBed']),
    );
  }

  static List<PlanActivity> _parseActivities(dynamic list) {
    if (list is! List) return [];
    return list
        .map((e) => PlanActivity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class PlanActivity {
  final String type;
  final String title;
  final String description;
  final String duration;

  const PlanActivity({
    required this.type,
    required this.title,
    required this.description,
    required this.duration,
  });

  int get durationMinutes {
    final match = RegExp(r'(\d+)').firstMatch(duration);
    if (match != null) return int.parse(match.group(1)!);
    return 5;
  }

  factory PlanActivity.fromJson(Map<String, dynamic> json) => PlanActivity(
        type: json['type'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        duration: json['duration'] ?? '5 min',
      );
}

class WellnessSummary {
  final double overallScore;
  final String trend;
  final List<String> highlights;
  final List<String> areasToFocus;
  final String encouragement;

  const WellnessSummary({
    required this.overallScore,
    required this.trend,
    required this.highlights,
    required this.areasToFocus,
    required this.encouragement,
  });

  factory WellnessSummary.fromJson(Map<String, dynamic> json) =>
      WellnessSummary(
        overallScore: (json['overallScore'] ?? 0).toDouble(),
        trend: json['trend'] ?? 'stable',
        highlights: List<String>.from(json['highlights'] ?? []),
        areasToFocus: List<String>.from(json['areasToFocus'] ?? []),
        encouragement: json['encouragement'] ?? '',
      );
}

class MoodEntry {
  final String date;
  final int mood;
  final int? energy;
  final int? stress;
  final int? anxiety;
  final String? notes;
  final DateTime timestamp;

  const MoodEntry({
    required this.date,
    required this.mood,
    this.energy,
    this.stress,
    this.anxiety,
    this.notes,
    required this.timestamp,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        date: json['date'] ?? '',
        mood: json['mood'] ?? 3,
        energy: json['energy'],
        stress: json['stress'],
        anxiety: json['anxiety'],
        notes: json['notes'],
        timestamp: (json['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'mood': mood,
        'energy': energy,
        'stress': stress,
        'anxiety': anxiety,
        'notes': notes,
        'timestamp': timestamp,
      };
}
