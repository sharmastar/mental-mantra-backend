import 'package:flutter/material.dart';

class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String category;
  final IconData icon;
  final Color color;
  final String assetPath;
  final Duration duration;

  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.category,
    required this.icon,
    required this.color,
    required this.assetPath,
    this.duration = const Duration(seconds: 180),
  });

  String get formattedDuration {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class MusicCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<MusicTrack> tracks;

  const MusicCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.tracks,
  });
}
