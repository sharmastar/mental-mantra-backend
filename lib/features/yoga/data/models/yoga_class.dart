enum YogaLevel { beginner, intermediate, advanced }
enum YogaStyle { hatha, vinyasa, yin, restorative, ashtanga, kundalini }

class YogaPose {
  final String id;
  final String name;
  final String sanskritName;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final int difficultyRating;
  final List<String> benefits;
  final List<String> contraindications;
  final int durationSeconds;

  const YogaPose({
    required this.id,
    required this.name,
    this.sanskritName = '',
    required this.description,
    this.imageUrl,
    this.videoUrl,
    this.difficultyRating = 1,
    this.benefits = const [],
    this.contraindications = const [],
    this.durationSeconds = 30,
  });

  factory YogaPose.fromJson(Map<String, dynamic> json) => YogaPose(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    sanskritName: json['sanskritName'] as String? ?? '',
    description: json['description'] as String? ?? '',
    imageUrl: json['imageUrl'] as String?,
    videoUrl: json['videoUrl'] as String?,
    difficultyRating: json['difficultyRating'] as int? ?? 1,
    benefits: List<String>.from(json['benefits'] ?? []),
    contraindications: List<String>.from(json['contraindications'] ?? []),
    durationSeconds: json['durationSeconds'] as int? ?? 30,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sanskritName': sanskritName,
    'description': description,
    'imageUrl': imageUrl,
    'videoUrl': videoUrl,
    'difficultyRating': difficultyRating,
    'benefits': benefits,
    'contraindications': contraindications,
    'durationSeconds': durationSeconds,
  };
}

class YogaClass {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final YogaLevel level;
  final YogaStyle style;
  final int durationMinutes;
  final List<YogaPose> poses;
  final String? instructor;
  final bool isFavorite;

  const YogaClass({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    this.level = YogaLevel.beginner,
    this.style = YogaStyle.hatha,
    this.durationMinutes = 30,
    this.poses = const [],
    this.instructor,
    this.isFavorite = false,
  });

  String get durationLabel => '$durationMinutes min';

  factory YogaClass.fromJson(Map<String, dynamic> json) => YogaClass(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    imageUrl: json['imageUrl'] as String?,
    videoUrl: json['videoUrl'] as String?,
    level: YogaLevel.values.firstWhere(
      (e) => e.name == json['level'],
      orElse: () => YogaLevel.beginner,
    ),
    style: YogaStyle.values.firstWhere(
      (e) => e.name == json['style'],
      orElse: () => YogaStyle.hatha,
    ),
    durationMinutes: json['durationMinutes'] as int? ?? 30,
    poses: (json['poses'] as List<dynamic>?)?.map((p) => YogaPose.fromJson(p as Map<String, dynamic>)).toList() ?? [],
    instructor: json['instructor'] as String?,
    isFavorite: json['isFavorite'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'videoUrl': videoUrl,
    'level': level.name,
    'style': style.name,
    'durationMinutes': durationMinutes,
    'poses': poses.map((p) => p.toJson()).toList(),
    'instructor': instructor,
    'isFavorite': isFavorite,
  };

  YogaClass copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? videoUrl,
    YogaLevel? level,
    YogaStyle? style,
    int? durationMinutes,
    List<YogaPose>? poses,
    String? instructor,
    bool? isFavorite,
  }) => YogaClass(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    videoUrl: videoUrl ?? this.videoUrl,
    level: level ?? this.level,
    style: style ?? this.style,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    poses: poses ?? this.poses,
    instructor: instructor ?? this.instructor,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}
