import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mental_mantra/core/config/ai_prompts.dart';
import 'package:mental_mantra/core/network/api_client.dart';
import 'package:mental_mantra/core/storage/hive_storage.dart';
import 'package:mental_mantra/core/domain/entities/assessment_response.dart';
import 'wellness_scorer.dart';
import 'safety_detector.dart';

class AiCoachService {
  final WellnessScorer _scorer = const WellnessScorer();

  Future<Map<String, dynamic>> calculateWellnessProfile(List<AssessmentResponse> responses) async {
    final scores = _scorer.calculateFromResponses(responses);
    final concerns = WellnessScorer.identifyPrimaryConcerns(scores);
    final riskLevel = WellnessScorer.riskLevelFromScores(scores);

    Map<String, dynamic> aiResult = {};
    try {
      final prompt = AiPrompts.wellnessProfilePrompt(responses.map((r) => r.toJson()).toList());
      aiResult = await _callGemini(prompt);
      if (aiResult.containsKey('overallScore')) {
        scores['overallScore'] = (aiResult['overallScore'] as num).toDouble();
        scores['stressScore'] = (aiResult['stressScore'] as num?)?.toDouble() ?? scores['stressScore']!;
        scores['anxietyScore'] = (aiResult['anxietyScore'] as num?)?.toDouble() ?? scores['anxietyScore']!;
      }
    } catch (e) {
      debugPrint('[AiCoach] Gemini assessment failed: $e');
    }

    final result = {
      ...scores,
      'primaryConcerns': aiResult['primaryConcerns'] ?? concerns,
      'strengths': aiResult['strengths'] ?? _inferStrengths(responses),
      'riskLevel': aiResult['riskLevel'] ?? riskLevel,
      'summary': aiResult['summary'] ?? _generateSummary(scores, concerns),
      'recommendedFocusAreas': aiResult['recommendedFocusAreas'] ?? concerns,
      'safetyEscalation': aiResult['safetyEscalation'] ?? riskLevel == 'critical',
      'escalationReason': aiResult['escalationReason'],
      'encouragement': aiResult['encouragement'] ?? _generateEncouragement(scores),
    };
    await HiveStorage.saveWellnessProfile(result);
    return result;
  }

  Future<Map<String, dynamic>> generateDailyPlan(String userId) async {
    final cached = await HiveStorage.getDailyPlan();
    if (cached != null) return cached;
    final profile = await HiveStorage.getWellnessProfile();
    final lastCheckin = await HiveStorage.getLastCheckin();
    Map<String, dynamic> result = {};
    try {
      final prompt = AiPrompts.dailyRecommendationPrompt(profile, lastCheckin);
      result = await _callGemini(prompt);
    } catch (e) {
      debugPrint('[AiCoach] Daily plan Gemini failed: $e');
    }
    if (result.isEmpty) {
      result = _generateFallbackPlan(profile);
    }
    await HiveStorage.saveDailyPlan(result);
    return result;
  }

  Future<Map<String, dynamic>> analyzeJournalEntry(String content, int mood) async {
    final safetyCheck = SafetyDetector.assess(content);
    Map<String, dynamic> result = {};
    try {
      final prompt = AiPrompts.journalAnalysisPrompt(content, mood);
      result = await _callGemini(prompt);
    } catch (e) {
      debugPrint('[AiCoach] Journal analysis Gemini failed: $e');
    }
    result['riskIndicators'] = result['riskIndicators'] ?? safetyCheck.containsCrisisIndicator;
    result['flaggedConcerns'] = result['flaggedConcerns'] ?? [];
    if (safetyCheck.containsCrisisIndicator) {
      (result['flaggedConcerns'] as List).add(safetyCheck.extractedConcern);
    }
    return result;
  }

  Future<Map<String, dynamic>> analyzeMoodTrend(List<Map<String, dynamic>> recentMoods, int days) async {
    try {
      final prompt = AiPrompts.moodAnalysisPrompt(recentMoods, days);
      return await _callGemini(prompt);
    } catch (_) {
      return _fallbackMoodAnalysis(recentMoods);
    }
  }

  Future<Map<String, dynamic>> generateWeeklyInsights(String userId) async {
    final weekData = await HiveStorage.getWeekData();
    try {
      final prompt = AiPrompts.weeklyInsightsPrompt(weekData);
      return await _callGemini(prompt);
    } catch (_) {
      return {'weekSummary': 'Keep going! Every day counts.', 'scoreTrend': 'stable', 'keyAchievements': [], 'encouragementMessage': 'You\'re doing great!'};
    }
  }

  Future<Map<String, dynamic>> _callGemini(String prompt) async {
    final response = await ApiClient.post(
      '/ai/generate',
      data: {'prompt': prompt},
    );
    final responseData = response.data as Map<String, dynamic>?;
    if (responseData == null || responseData['success'] != true) {
      throw Exception('AI service failed');
    }
    final text = responseData['text'] as String? ?? '';
    final cleaned = text.replaceAll(RegExp(r'```json|```'), '').trim();
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }

  Map<String, dynamic> _generateFallbackPlan(Map<String, dynamic> profile) {
    final concerns = List<String>.from(profile['primaryConcerns'] ?? ['Stress Management']);
    return {
      'dailyPlan': {
        'morning': [{'type': 'breathing', 'title': 'Morning Calm', 'description': 'Start your day with deep breathing', 'duration': '5 min'}],
        'afternoon': [{'type': 'meditation', 'title': 'Midday Reset', 'description': 'A brief mindfulness check', 'duration': '10 min'}],
        'evening': [{'type': 'journal', 'title': 'Evening Reflection', 'description': 'Write about your day', 'duration': '10 min'}],
        'beforeBed': [{'type': 'meditation', 'title': 'Sleep Wind-Down', 'description': 'Prepare for restful sleep', 'duration': '15 min'}],
      },
      'recommendations': {'meditation': [], 'music': [], 'yoga': [], 'breathing': [], 'journalPrompt': '', 'quote': {'text': 'Peace begins within.', 'author': 'Unknown'}, 'affirmations': ['I am capable of handling whatever comes my way']},
      'wellnessSummary': {'overallScore': (profile['overallScore'] ?? 50).toDouble(), 'trend': 'stable', 'highlights': ['You took the first step!'], 'areasToFocus': concerns, 'encouragement': 'Every journey begins with a single step.'},
      'safetyCheck': {'riskLevel': profile['riskLevel'] ?? 'low', 'triggered': false, 'message': null},
    };
  }

  Map<String, dynamic> _fallbackMoodAnalysis(List<Map<String, dynamic>> recentMoods) {
    if (recentMoods.isEmpty) return {'trend': 'stable', 'averageMood': 3.0, 'volatility': 'low', 'patterns': [], 'suggestions': ['Track your mood daily for insights'], 'riskFlag': false};
    final avg = recentMoods.fold(0.0, (sum, m) => sum + (m['mood'] ?? 3).toDouble()) / recentMoods.length;
    return {'trend': avg > 3.5 ? 'improving' : avg < 2.5 ? 'declining' : 'stable', 'averageMood': avg, 'volatility': 'medium', 'patterns': [], 'suggestions': ['Consider what affects your mood most'], 'riskFlag': false};
  }

  List<String> _inferStrengths(List<AssessmentResponse> responses) {
    final strengths = <String>[];
    for (final r in responses) {
      if (r.questionId == 'coping_mechanisms' && r.answer is List) {
        if ((r.answer as List).length >= 3) strengths.add('Resourceful coping strategies');
      }
      if (r.questionId == 'social_support' && r.answer == "I have a strong support system") {
        strengths.add('Strong support network');
      }
      if (r.questionId == 'exercise_frequency') {
        if (r.answer == 'Daily') strengths.add('Active lifestyle');
      }
    }
    if (strengths.isEmpty) strengths.add('Self-awareness in seeking help');
    return strengths;
  }

  String _generateSummary(Map<String, double> scores, List<String> concerns) {
    if (scores['overallScore']! >= 70) return 'You\'re doing well overall! Focus on maintaining your wellbeing and building on your strengths.';
    if (scores['overallScore']! >= 50) return 'You have some areas to work on, but you\'re on the right track. Small consistent steps will help.';
    return 'It seems like you\'re going through a challenging time. The personalized plan will help you start feeling better step by step.';
  }

  String _generateEncouragement(Map<String, double> scores) {
    if (scores['overallScore']! >= 70) return 'You\'re building great habits — keep it up!';
    if (scores['overallScore']! >= 50) return 'Every small step counts. You\'ve got this!';
    return 'Starting is the hardest part and you\'ve already done it. Be kind to yourself.';
  }
}

extension on List<Map<String, dynamic>> {
  double fold<T>(double initial, double Function(double, Map<String, dynamic>) fn) {
    double result = initial;
    for (final item in this) { result = fn(result, item); }
    return result;
  }
}
