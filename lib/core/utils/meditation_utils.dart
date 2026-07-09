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
  final min = seconds ~/ 60;
  final sec = seconds % 60;
  return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
}

List<String> moodEmojis = ['', '😢', '😟', '😐', '😊', '🥰'];
List<String> moodLabels = ['', 'Sad', 'Anxious', 'Neutral', 'Happy', 'Joyful'];

String moodEmoji(int mood) => moodEmojis[mood.clamp(1, 5)];
String moodLabel(int mood) => moodLabels[mood.clamp(1, 5)];
