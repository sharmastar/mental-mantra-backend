class DailyTask {
  final String id;
  final String emoji;
  final String label;
  final String type;
  final int xp;
  final bool done;

  const DailyTask({
    required this.id,
    required this.emoji,
    required this.label,
    required this.type,
    this.xp = 10,
    this.done = false,
  });

  DailyTask copyWith({bool? done}) {
    return DailyTask(
      id: id,
      emoji: emoji,
      label: label,
      type: type,
      xp: xp,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'emoji': emoji,
    'label': label,
    'type': type,
    'xp': xp,
    'done': done,
  };

  factory DailyTask.fromJson(Map<String, dynamic> json) => DailyTask(
    id: json['id'] as String,
    emoji: json['emoji'] as String,
    label: json['label'] as String,
    type: json['type'] as String? ?? 'general',
    xp: (json['xp'] as num?)?.toInt() ?? 10,
    done: json['done'] as bool? ?? false,
  );
}
