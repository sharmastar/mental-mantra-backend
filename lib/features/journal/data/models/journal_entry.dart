class JournalEntry {
  final String? id;
  final String title;
  final String content;
  final int mood;
  final List<String> emotions;
  final List<String> tags;
  final bool isPrivate;
  final Map<String, dynamic>? aiAnalysis;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.mood,
    this.emotions = const [],
    this.tags = const [],
    this.isPrivate = false,
    this.aiAnalysis,
    required this.createdAt,
    required this.updatedAt,
  });

  int get wordCount => content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  String? get aiInsight => aiAnalysis?['encouragement'] as String?;

  factory JournalEntry.fromJson(Map<String, dynamic> json, [String? docId]) => JournalEntry(
    id: docId ?? json['id'],
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    mood: json['mood'] ?? 3,
    emotions: List<String>.from(json['emotions'] ?? []),
    tags: List<String>.from(json['tags'] ?? []),
    isPrivate: json['isPrivate'] ?? false,
    aiAnalysis: json['aiAnalysis'] as Map<String, dynamic>?,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'mood': mood,
    'emotions': emotions,
    'tags': tags,
    'isPrivate': isPrivate,
    'aiAnalysis': aiAnalysis,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    int? mood,
    List<String>? emotions,
    List<String>? tags,
    bool? isPrivate,
    Map<String, dynamic>? aiAnalysis,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      emotions: emotions ?? this.emotions,
      tags: tags ?? this.tags,
      isPrivate: isPrivate ?? this.isPrivate,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class JournalFilter {
  final String? searchQuery;
  final int? minMood;
  final int? maxMood;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<String> tagFilter;
  final String sortOrder;

  const JournalFilter({
    this.searchQuery,
    this.minMood,
    this.maxMood,
    this.fromDate,
    this.toDate,
    this.tagFilter = const [],
    this.sortOrder = 'newest',
  });
}
