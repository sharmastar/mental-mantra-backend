class MoodEntry {
  final String? id;
  final int moodValue;
  final String moodLabel;
  final String moodEmoji;
  final int stressLevel;
  final int energyLevel;
  final int anxietyLevel;
  final int sleepHours;
  final List<String> tags;
  final String note;
  final DateTime createdAt;

  const MoodEntry({
    this.id,
    required this.moodValue,
    required this.moodLabel,
    required this.moodEmoji,
    required this.stressLevel,
    required this.energyLevel,
    required this.anxietyLevel,
    required this.sleepHours,
    this.tags = const [],
    this.note = '',
    required this.createdAt,
  });
}
