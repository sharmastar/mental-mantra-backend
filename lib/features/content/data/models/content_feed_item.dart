import 'package:flutter/material.dart';

class ContentFeedItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final String? videoId;
  final String? route;
  final bool isFeatured;

  const ContentFeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
    this.videoId,
    this.route,
    this.isFeatured = false,
  });
}
