enum MeditationType { guided, unguided, breathing, bodyScan, lovingKindness }

enum DifficultyLevel { beginner, intermediate, advanced }

class MeditationCategory {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int sessionCount;

  const MeditationCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    this.sessionCount = 0,
  });

  factory MeditationCategory.fromJson(Map<String, dynamic> json) =>
      MeditationCategory(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        iconUrl: json['iconUrl'] as String? ?? '',
        sessionCount: json['sessionCount'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'sessionCount': sessionCount,
      };
}

class MeditationSession {
  final String id;
  final String title;
  final String description;
  final String? audioUrl;
  final String? imageUrl;
  final MeditationType type;
  final DifficultyLevel difficulty;
  final int durationSeconds;
  final String? narrator;
  final String? language;
  final List<String> tags;
  final bool isFavorite;
  final bool isDownloaded;
  final DateTime? lastPlayedAt;
  final int timesCompleted;

  const MeditationSession({
    required this.id,
    required this.title,
    required this.description,
    this.audioUrl,
    this.imageUrl,
    this.type = MeditationType.guided,
    this.difficulty = DifficultyLevel.beginner,
    this.durationSeconds = 600,
    this.narrator,
    this.language,
    this.tags = const [],
    this.isFavorite = false,
    this.isDownloaded = false,
    this.lastPlayedAt,
    this.timesCompleted = 0,
  });

  String get durationLabel {
    final minutes = durationSeconds ~/ 60;
    if (minutes < 60) return '${minutes}min';
    final hours = minutes ~/ 60;
    final remainingMin = minutes % 60;
    return remainingMin > 0 ? '${hours}h ${remainingMin}min' : '${hours}h';
  }

  factory MeditationSession.fromJson(Map<String, dynamic> json) =>
      MeditationSession(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        audioUrl: json['audioUrl'] as String?,
        imageUrl: json['imageUrl'] as String?,
        type: MeditationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MeditationType.guided,
        ),
        difficulty: DifficultyLevel.values.firstWhere(
          (e) => e.name == json['difficulty'],
          orElse: () => DifficultyLevel.beginner,
        ),
        durationSeconds: json['durationSeconds'] as int? ?? 600,
        narrator: json['narrator'] as String?,
        language: json['language'] as String?,
        tags: List<String>.from(json['tags'] ?? []),
        isFavorite: json['isFavorite'] as bool? ?? false,
        isDownloaded: json['isDownloaded'] as bool? ?? false,
        lastPlayedAt: json['lastPlayedAt'] != null
            ? DateTime.tryParse(json['lastPlayedAt'] as String)
            : null,
        timesCompleted: json['timesCompleted'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'audioUrl': audioUrl,
        'imageUrl': imageUrl,
        'type': type.name,
        'difficulty': difficulty.name,
        'durationSeconds': durationSeconds,
        'narrator': narrator,
        'language': language,
        'tags': tags,
        'isFavorite': isFavorite,
        'isDownloaded': isDownloaded,
        'lastPlayedAt': lastPlayedAt?.toIso8601String(),
        'timesCompleted': timesCompleted,
      };

  MeditationSession copyWith({
    String? id,
    String? title,
    String? description,
    String? audioUrl,
    String? imageUrl,
    MeditationType? type,
    DifficultyLevel? difficulty,
    int? durationSeconds,
    String? narrator,
    String? language,
    List<String>? tags,
    bool? isFavorite,
    bool? isDownloaded,
    DateTime? lastPlayedAt,
    int? timesCompleted,
  }) {
    return MeditationSession(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      narrator: narrator ?? this.narrator,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      timesCompleted: timesCompleted ?? this.timesCompleted,
    );
  }
}
