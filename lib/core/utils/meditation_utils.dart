import 'package:flutter/services.dart';

enum HapticType { light, medium, selection }

void triggerHaptic(HapticType type, {bool enabled = true}) {
  if (!enabled) return;
  switch (type) {
    case HapticType.light:
      HapticFeedback.lightImpact();
    case HapticType.medium:
      HapticFeedback.mediumImpact();
    case HapticType.selection:
      HapticFeedback.selectionClick();
  }
}

String formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String formatDurationFromDuration(Duration d) => formatDuration(d.inSeconds);

List<String> moodEmojis = ['', '😢', '😟', '😐', '😊', '🥰'];
List<String> moodLabels = ['', 'Sad', 'Anxious', 'Neutral', 'Happy', 'Joyful'];

String moodEmoji(int mood) => moodEmojis[mood.clamp(1, 5)];
String moodLabel(int mood) => moodLabels[mood.clamp(1, 5)];
