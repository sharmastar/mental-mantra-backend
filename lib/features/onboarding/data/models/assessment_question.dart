import 'package:flutter/material.dart';
export 'package:mental_mantra/core/domain/entities/assessment_response.dart';

class AnswerOption {
  final String value;
  final String label;
  final IconData? icon;
  final String? subtitle;
  final Color? color;

  const AnswerOption({
    required this.value,
    required this.label,
    this.icon,
    this.subtitle,
    this.color,
  });
}

class QuestionType {
  static const String text = 'text';
  static const String singleSelect = 'single_select';
  static const String multiSelect = 'multi_select';
  static const String slider = 'slider';
  static const String frequencyScale = 'frequency_scale';
}

class AssessmentQuestion {
  final String id;
  final String question;
  final String type;
  final List<String>? _options;
  final int? sliderMin;
  final int? sliderMax;
  final String? sliderStartLabel;
  final String? sliderEndLabel;
  final bool isOptional;
  final bool isSensitive;
  final String? subtitle;
  final String? encouragementAfter;
  final List<String>? suggestedNames;

  const AssessmentQuestion({
    required this.id,
    required this.question,
    required this.type,
    List<String>? options,
    this.sliderMin,
    this.sliderMax,
    this.sliderStartLabel,
    this.sliderEndLabel,
    this.isOptional = false,
    this.isSensitive = false,
    this.subtitle,
    this.encouragementAfter,
    this.suggestedNames,
  }) : _options = options;

  String get questionText => question;

  bool get isMultiSelect => type == QuestionType.multiSelect;

  bool get canSkip => isOptional;

  String get emoji {
    switch (id) {
      case 'nickname':
        return '👋';
      case 'age_group':
        return '🎂';
      case 'reasons_joined':
        return '💭';
      case 'challenge_duration':
        return '⏳';
      case 'affected_areas':
        return '🎯';
      case 'emotional_overwhelm':
        return '😮‍💨';
      case 'excessive_worry':
        return '🌀';
      case 'feeling_lonely':
        return '💙';
      case 'sleep_hours':
        return '🌙';
      case 'sleep_quality':
        return '😴';
      case 'physical_activity':
        return '🏃';
      case 'emotional_support':
        return '🤝';
      case 'habit_struggles':
        return '🔄';
      case 'coping_style':
        return '🛡️';
      case 'improvement_goals':
        return '🌟';
      default:
        return '❓';
    }
  }

  String? get subtext => subtitle;

  List<AnswerOption> get options {
    if (_options == null) return const [];
    return _options.map((opt) {
      IconData? icon;
      Color? color;
      String? sub;

      // Reasons joined icons
      if (id == 'reasons_joined') {
        switch (opt) {
          case 'Stress or pressure':
            icon = Icons.flash_on;
            color = const Color(0xFFFF7043);
            break;
          case 'Anxiety or overthinking':
            icon = Icons.waves;
            color = const Color(0xFFFFB547);
            break;
          case 'Feeling emotionally low':
            icon = Icons.mood_bad;
            color = const Color(0xFF7986CB);
            break;
          case 'Loneliness':
            icon = Icons.person_outline;
            color = const Color(0xFF00BCD4);
            break;
          case 'Relationship difficulties':
            icon = Icons.favorite_border;
            color = const Color(0xFFE91E63);
            break;
          case 'Family conflicts':
            icon = Icons.family_restroom;
            color = const Color(0xFFFF8A65);
            break;
          case 'Work stress':
            icon = Icons.work_outline;
            color = const Color(0xFF42A5F5);
            break;
          case 'Academic stress':
            icon = Icons.school;
            color = const Color(0xFF66BB6A);
            break;
          case 'Sleep problems':
            icon = Icons.bedtime;
            color = const Color(0xFF5C6BC0);
            break;
          case 'Lack of motivation':
            icon = Icons.battery_alert;
            color = const Color(0xFF9C27B0);
            break;
          case 'Low confidence/self-esteem':
            icon = Icons.star_border;
            color = const Color(0xFFFF9800);
            break;
          case 'Addiction or habit control':
            icon = Icons.loop;
            color = const Color(0xFFE53935);
            break;
          case 'Anger or emotional control':
            icon = Icons.whatshot;
            color = const Color(0xFFD32F2F);
            break;
          case 'Emotional burnout':
            icon = Icons.local_fire_department;
            color = const Color(0xFFFF5722);
            break;
          case 'Just exploring mental wellness':
            icon = Icons.explore;
            color = const Color(0xFF4CAF50);
            break;
        }
      }

      // Affected areas icons
      if (id == 'affected_areas') {
        switch (opt) {
          case 'Relationships':
            icon = Icons.favorite;
            break;
          case 'Family life':
            icon = Icons.family_restroom;
            break;
          case 'Studies':
            icon = Icons.school;
            break;
          case 'Work performance':
            icon = Icons.work;
            break;
          case 'Sleep':
            icon = Icons.bedtime;
            break;
          case 'Physical health':
            icon = Icons.fitness_center;
            break;
          case 'Confidence':
            icon = Icons.star;
            break;
          case 'Social interactions':
            icon = Icons.groups;
            break;
          case 'Daily routine':
            icon = Icons.schedule;
            break;
          case 'Motivation/productivity':
            icon = Icons.trending_up;
            break;
        }
      }

      // Sleep quality icons
      if (id == 'sleep_quality') {
        switch (opt) {
          case 'Very good':
            icon = Icons.check_circle_outline;
            sub = 'Wake up refreshed';
            break;
          case 'Good':
            icon = Icons.thumb_up_alt_outlined;
            sub = 'Mostly rested';
            break;
          case 'Average':
            icon = Icons.remove_circle_outline;
            sub = 'Could be better';
            break;
          case 'Poor':
            icon = Icons.warning_amber_rounded;
            sub = 'Often tired';
            break;
          case 'Very poor':
            icon = Icons.error_outline;
            sub = 'Constantly exhausted';
            break;
        }
      }

      // Habit struggles icons
      if (id == 'habit_struggles') {
        switch (opt) {
          case 'Social media scrolling':
            icon = Icons.phone_android;
            color = const Color(0xFF2196F3);
            break;
          case 'Gaming':
            icon = Icons.sports_esports;
            color = const Color(0xFF9C27B0);
            break;
          case 'Pornography':
            icon = Icons.visibility_off;
            color = const Color(0xFFE53935);
            break;
          case 'Betting/Gambling':
            icon = Icons.casino;
            color = const Color(0xFFFF9800);
            break;
          case 'Alcohol':
            icon = Icons.local_bar;
            color = const Color(0xFF795548);
            break;
          case 'Smoking':
            icon = Icons.smoking_rooms;
            color = const Color(0xFF607D8B);
            break;
          case 'Emotional eating':
            icon = Icons.restaurant;
            color = const Color(0xFFFF7043);
            break;
          case 'Binge watching':
            icon = Icons.tv;
            color = const Color(0xFF00BCD4);
            break;
          case 'Shopping/spending':
            icon = Icons.shopping_cart;
            color = const Color(0xFFE91E63);
            break;
          case 'None':
            icon = Icons.check_circle;
            color = const Color(0xFF4CAF50);
            break;
        }
      }

      // Coping style icons
      if (id == 'coping_style') {
        switch (opt) {
          case 'Stay alone':
            icon = Icons.person;
            break;
          case 'Talk to someone':
            icon = Icons.chat_bubble_outline;
            break;
          case 'Sleep':
            icon = Icons.bedtime;
            break;
          case 'Cry':
            icon = Icons.water_drop;
            break;
          case 'Exercise':
            icon = Icons.fitness_center;
            break;
          case 'Watch content/videos':
            icon = Icons.play_circle_outline;
            break;
          case 'Scroll social media':
            icon = Icons.phone_android;
            break;
          case 'Pray/meditate':
            icon = Icons.self_improvement;
            break;
          case 'Work/study more':
            icon = Icons.work;
            break;
          case 'Get angry':
            icon = Icons.whatshot;
            break;
          case 'Eat more':
            icon = Icons.restaurant;
            break;
          case 'Play games':
            icon = Icons.sports_esports;
            break;
        }
      }

      // Improvement goals icons
      if (id == 'improvement_goals') {
        switch (opt) {
          case 'Reduce stress':
            icon = Icons.spa;
            color = const Color(0xFF4CAF50);
            break;
          case 'Reduce anxiety':
            icon = Icons.waves;
            color = const Color(0xFF00BCD4);
            break;
          case 'Improve sleep':
            icon = Icons.bedtime;
            color = const Color(0xFF5C6BC0);
            break;
          case 'Build confidence':
            icon = Icons.star;
            color = const Color(0xFFFFB300);
            break;
          case 'Improve relationships':
            icon = Icons.favorite;
            color = const Color(0xFFE91E63);
            break;
          case 'Addiction recovery':
            icon = Icons.loop;
            color = const Color(0xFFE53935);
            break;
          case 'Better focus/productivity':
            icon = Icons.track_changes;
            color = const Color(0xFF2196F3);
            break;
          case 'Emotional balance':
            icon = Icons.balance;
            color = const Color(0xFF9C27B0);
            break;
          case 'Self-discipline':
            icon = Icons.fitness_center;
            color = const Color(0xFFFF7043);
            break;
          case 'Motivation':
            icon = Icons.rocket_launch;
            color = const Color(0xFFFF9800);
            break;
          case 'Healthier habits':
            icon = Icons.check_circle_outline;
            color = const Color(0xFF66BB6A);
            break;
          case 'Inner peace':
            icon = Icons.self_improvement;
            color = const Color(0xFF7E57C2);
            break;
          case 'Overall wellbeing':
            icon = Icons.auto_awesome;
            color = const Color(0xFF26A69A);
            break;
        }
      }

      return AnswerOption(
        value: opt,
        label: opt,
        icon: icon,
        subtitle: sub,
        color: color,
      );
    }).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'type': type,
        'options': _options,
        'sliderMin': sliderMin,
        'sliderMax': sliderMax,
        'sliderStartLabel': sliderStartLabel,
        'sliderEndLabel': sliderEndLabel,
        'isOptional': isOptional,
        'isSensitive': isSensitive,
        'subtitle': subtitle,
        'encouragementAfter': encouragementAfter,
      };
}

class AssessmentAnswers {
  final Map<String, dynamic> _answers;

  const AssessmentAnswers([this._answers = const {}]);

  List<String> getMulti(dynamic key) {
    final value = _answers[key.toString()];
    if (value is List) {
      return List<String>.from(value);
    }
    return const [];
  }

  String? getSingle(dynamic key) {
    final value = _answers[key.toString()];
    return value?.toString();
  }

  double? getSlider(dynamic key) {
    final value = _answers[key.toString()];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  bool hasAnswer(dynamic key) {
    return _answers.containsKey(key.toString());
  }

  Map<String, dynamic> toJson() => _answers;

  factory AssessmentAnswers.fromJson(Map<String, dynamic> json) =>
      AssessmentAnswers(json);
}

class WellnessProfile {
  final double overallScore;
  final double stressScore;
  final double anxietyScore;
  final double moodScore;
  final double sleepScore;
  final double energyScore;
  final double motivationScore;
  final double resilienceScore;
  final List<String> primaryConcerns;
  final List<String> strengths;
  final String riskLevel;
  final String summary;
  final List<String> recommendedFocusAreas;
  final bool safetyEscalation;
  final String? escalationReason;
  final String encouragement;

  const WellnessProfile({
    required this.overallScore,
    required this.stressScore,
    required this.anxietyScore,
    required this.moodScore,
    required this.sleepScore,
    required this.energyScore,
    required this.motivationScore,
    required this.resilienceScore,
    required this.primaryConcerns,
    required this.strengths,
    required this.riskLevel,
    required this.summary,
    required this.recommendedFocusAreas,
    this.safetyEscalation = false,
    this.escalationReason,
    required this.encouragement,
  });

  factory WellnessProfile.fromJson(Map<String, dynamic> json) =>
      WellnessProfile(
        overallScore: (json['overallScore'] ?? 50).toDouble(),
        stressScore: (json['stressScore'] ?? 50).toDouble(),
        anxietyScore: (json['anxietyScore'] ?? 50).toDouble(),
        moodScore: (json['moodScore'] ?? 50).toDouble(),
        sleepScore: (json['sleepScore'] ?? 50).toDouble(),
        energyScore: (json['energyScore'] ?? 50).toDouble(),
        motivationScore: (json['motivationScore'] ?? 50).toDouble(),
        resilienceScore: (json['resilienceScore'] ?? 50).toDouble(),
        primaryConcerns: List<String>.from(json['primaryConcerns'] ?? []),
        strengths: List<String>.from(json['strengths'] ?? []),
        riskLevel: json['riskLevel'] ?? 'low',
        summary: json['summary'] ?? '',
        recommendedFocusAreas:
            List<String>.from(json['recommendedFocusAreas'] ?? []),
        safetyEscalation: json['safetyEscalation'] ?? false,
        escalationReason: json['escalationReason'],
        encouragement: json['encouragement'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'overallScore': overallScore,
        'stressScore': stressScore,
        'anxietyScore': anxietyScore,
        'moodScore': moodScore,
        'sleepScore': sleepScore,
        'energyScore': energyScore,
        'motivationScore': motivationScore,
        'resilienceScore': resilienceScore,
        'primaryConcerns': primaryConcerns,
        'strengths': strengths,
        'riskLevel': riskLevel,
        'summary': summary,
        'recommendedFocusAreas': recommendedFocusAreas,
        'safetyEscalation': safetyEscalation,
        'escalationReason': escalationReason,
        'encouragement': encouragement,
      };
}
