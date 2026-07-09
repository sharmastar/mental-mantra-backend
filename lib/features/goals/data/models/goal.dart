import 'package:flutter/material.dart';

class Goal {
  final String id;
  final String title;
  final String category;
  final double progress;
  final Color color;
  final IconData icon;
  final int current;
  final int target;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.title,
    required this.category,
    this.progress = 0.0,
    this.color = const Color(0xFF42C8B7),
    this.icon = Icons.self_improvement,
    this.current = 0,
    this.target = 1,
    required this.createdAt,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? category,
    double? progress,
    Color? color,
    IconData? icon,
    int? current,
    int? target,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      current: current ?? this.current,
      target: target ?? this.target,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'progress': progress,
    'current': current,
    'target': target,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String? ?? 'General',
    progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    current: (json['current'] as num?)?.toInt() ?? 0,
    target: (json['target'] as num?)?.toInt() ?? 1,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );
}
