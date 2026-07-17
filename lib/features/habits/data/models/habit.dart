import 'package:flutter/material.dart';
import 'package:mental_mantra/core/theme/app_theme.dart';

class Habit {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final int streak;
  final bool done;
  final int target;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.title,
    this.icon = Icons.check_circle_outline,
    this.color = AppTheme.primaryColor,
    this.streak = 0,
    this.done = false,
    this.target = 1,
    required this.createdAt,
  });

  Habit copyWith({
    String? id,
    String? title,
    IconData? icon,
    Color? color,
    int? streak,
    bool? done,
    int? target,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      streak: streak ?? this.streak,
      done: done ?? this.done,
      target: target ?? this.target,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'streak': streak,
        'done': done,
        'target': target,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        title: json['title'] as String,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        done: json['done'] as bool? ?? false,
        target: (json['target'] as num?)?.toInt() ?? 1,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
