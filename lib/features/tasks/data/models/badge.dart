class Badge {
  final String id;
  final String emoji;
  final String label;
  final String description;
  final bool earned;

  const Badge({
    required this.id,
    required this.emoji,
    required this.label,
    required this.description,
    this.earned = false,
  });

  Badge copyWith({bool? earned}) {
    return Badge(
      id: id,
      emoji: emoji,
      label: label,
      description: description,
      earned: earned ?? this.earned,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'emoji': emoji,
        'label': label,
        'description': description,
        'earned': earned,
      };

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
        id: json['id'] as String,
        emoji: json['emoji'] as String,
        label: json['label'] as String,
        description: json['description'] as String? ?? '',
        earned: json['earned'] as bool? ?? false,
      );
}
