import 'package:flutter/material.dart';

class WellnessTrendPoint {
  final int day;
  final double value;

  const WellnessTrendPoint({required this.day, required this.value});
}

class CategoryTrend {
  final String name;
  final Color color;
  final List<double> values;

  const CategoryTrend({required this.name, required this.color, required this.values});
}

class AnalyticsData {
  final List<WellnessTrendPoint> wellnessTrend;
  final List<CategoryTrend> categoryTrends;
  final List<int> tasksCompleted;
  final int avgWellness;
  final int totalCheckins;
  final int totalTasksDone;

  const AnalyticsData({
    this.wellnessTrend = const [],
    this.categoryTrends = const [],
    this.tasksCompleted = const [],
    this.avgWellness = 78,
    this.totalCheckins = 24,
    this.totalTasksDone = 142,
  });
}

const wellnessTrendData = [
  WellnessTrendPoint(day: 0, value: 65),
  WellnessTrendPoint(day: 1, value: 68),
  WellnessTrendPoint(day: 2, value: 72),
  WellnessTrendPoint(day: 3, value: 70),
  WellnessTrendPoint(day: 4, value: 75),
  WellnessTrendPoint(day: 5, value: 73),
  WellnessTrendPoint(day: 6, value: 78),
  WellnessTrendPoint(day: 7, value: 80),
  WellnessTrendPoint(day: 8, value: 76),
  WellnessTrendPoint(day: 9, value: 82),
  WellnessTrendPoint(day: 10, value: 85),
  WellnessTrendPoint(day: 11, value: 83),
  WellnessTrendPoint(day: 12, value: 86),
  WellnessTrendPoint(day: 13, value: 88),
];

const categoryTrendData = [
  CategoryTrend(name: 'Mood', color: Color(0xFF42C8B7), values: [65, 70, 68, 72, 75, 78, 80]),
  CategoryTrend(name: 'Energy', color: Color(0xFF00BFA5), values: [55, 60, 58, 62, 65, 68, 70]),
  CategoryTrend(name: 'Sleep', color: Color(0xFF1E6C64), values: [70, 72, 68, 75, 73, 78, 80]),
  CategoryTrend(name: 'Focus', color: Color(0xFF00BCD4), values: [60, 62, 65, 63, 68, 70, 72]),
  CategoryTrend(name: 'Calm', color: Color(0xFFE0F7F6), values: [50, 55, 58, 60, 62, 65, 68]),
];

const tasksCompletedData = [3, 5, 2, 6, 4, 7, 5];
