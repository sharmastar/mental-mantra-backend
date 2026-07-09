import 'dart:convert';

class AiPrompts {
  AiPrompts._();

  static String wellnessProfilePrompt(List<Map<String, dynamic>> responses) {
    return '''
You are an AI wellness assessment analyst for Mental Mantra app.
Analyze these onboarding assessment responses and generate a comprehensive wellness profile.

RESPONSES:
${jsonEncode(responses)}

Return valid JSON only with these exact fields:
{
  "overallScore": 0-100,
  "stressScore": 0-100,
  "anxietyScore": 0-100,
  "moodScore": 0-100,
  "sleepScore": 0-100,
  "energyScore": 0-100,
  "motivationScore": 0-100,
  "resilienceScore": 0-100,
  "primaryConcerns": ["concern1"],
  "strengths": ["strength1"],
  "riskLevel": "low|moderate|high|critical",
  "summary": "2-3 sentence personalized summary",
  "recommendedFocusAreas": ["area1"],
  "safetyEscalation": false,
  "escalationReason": null,
  "encouragement": "1 encouraging sentence"
}
''';
  }

  static String dailyRecommendationPrompt(Map<String, dynamic> profile, Map<String, dynamic>? lastCheckin) {
    return '''
You are an AI wellness coach for Mental Mantra. Generate a personalized daily wellness plan.

USER PROFILE: ${jsonEncode(profile)}
LAST CHECK-IN: ${jsonEncode(lastCheckin)}

Available content categories:
- Meditation: anxiety, depression, sleep, confidence, self_love, focus, anger, gratitude, healing, panic
- Music: relax, focus, sleep, anxiety, nature, rain, ocean, white_noise, binaural_theta, binaural_alpha, solfeggio (432Hz, 528Hz, 639Hz, 852Hz, 963Hz)
- Yoga: stress_relief, anxiety, sleep, energy, focus, digestion, immunity
- Breathing: calming, energizing, stress_relief, sleep_preparation, anxiety_relief
- Recovery: urge_logging, detox_timer, recovery_goals, craving_management, trigger_identification

Return valid JSON:
{
  "dailyPlan": {
    "morning": [{"type": "meditation|yoga|breathing|affirmation", "title": "", "description": "", "duration": "5 min"}],
    "afternoon": [],
    "evening": [],
    "beforeBed": []
  },
  "recommendations": {
    "meditation": [{"id": "", "title": "", "duration": "", "category": "", "reason": ""}],
    "music": [{"title": "", "category": "", "reason": ""}],
    "yoga": [{"name": "", "duration": "", "benefits": "", "reason": ""}],
    "breathing": [{"name": "", "duration": "", "reason": ""}],
    "journalPrompt": "",
    "quote": {"text": "", "author": ""},
    "affirmations": ["affirmation1"],
    "exercise": {"name": "", "duration": "", "description": ""},
    "food": {"suggestion": "", "reason": ""}
  },
  "wellnessSummary": {
    "overallScore": 0-100,
    "trend": "improving|stable|declining",
    "highlights": [],
    "areasToFocus": [],
    "encouragement": ""
  },
  "safetyCheck": {
    "riskLevel": "low|moderate|high|critical",
    "triggered": false,
    "message": null
  }
}
''';
  }

  static String journalAnalysisPrompt(String content, int mood) {
    return '''
Analyze this journal entry from a Mental Mantra user.

Entry: "$content"
Mood: $mood/5

Return valid JSON:
{
  "sentiment": "positive|negative|neutral|mixed",
  "keyThemes": ["theme1"],
  "emotionalState": "",
  "suggestedActivities": ["activity1"],
  "encouragement": "1-2 sentence message",
  "flaggedConcerns": [],
  "riskIndicators": false,
  "riskDetails": null
}
''';
  }

  static String addictionRecoveryPrompt(String message, {List<Map<String, dynamic>>? recentUrges}) {
    return '''
You are an AI addiction recovery coach for Mental Mantra app. The user is working on reducing or quitting addictive behaviors (gaming, social media, app browsing, etc.).

USER MESSAGE: "$message"
${recentUrges != null ? 'RECENT URGES: ${jsonEncode(recentUrges)}' : ''}

Your role:
1. Validate their struggle without judgment
2. Provide practical coping strategies (urge surfing, 4-7-8 breathing, grounding, replacement activities)
3. Suggest logging the urge in the Recovery section if it's active
4. Recommend starting a detox timer session if they need focus
5. Never shame or guilt — use compassionate, encouraging language
6. Keep responses concise (2-3 paragraphs)
7. If they mention relapse, help them reframe it as a learning experience
8. Suggest specific coping strategies from: Urge Surfing Meditation, Deep Breathing, Physical Activity, Journaling, Cold Water, Calming Music, Talking to Someone, Changing Environment

Return valid JSON:
{
  "validation": "1-2 sentences validating their experience",
  "strategy": "specific coping strategy to try right now",
  "suggestLogUrge": false,
  "suggestDetox": false,
  "encouragement": "1 encouraging sentence",
  "affirmation": "a short powerful affirmation"
}
''';
  }

  static String safetyDetectionPrompt(String text) {
    return '''
Analyze this text for crisis indicators from a mental wellness app user.

TEXT: "$text"

Return valid JSON:
{
  "containsCrisisIndicator": false,
  "crisisType": null,
  "confidence": 0.0-1.0,
  "extractedConcern": null,
  "suggestedResponse": "",
  "requiresImmediateEscalation": false
}
Be conservative - only flag genuine crisis signals. Do not flag general sadness or stress.
''';
  }

  static String moodAnalysisPrompt(List<Map<String, dynamic>> recentMoods, int days) {
    return '''
Analyze this $days-day mood history from Mental Mantra.

MOOD DATA: ${jsonEncode(recentMoods)}

Return valid JSON:
{
  "trend": "improving|stable|declining|fluctuating",
  "averageMood": 0-5,
  "volatility": "low|medium|high",
  "patterns": [],
  "correlations": [],
  "prediction": "",
  "suggestions": [],
  "riskFlag": false
}
''';
  }

  static String weeklyInsightsPrompt(Map<String, dynamic> weekData) {
    return '''
Generate a weekly wellness insights report for Mental Mantra user.

WEEK DATA: ${jsonEncode(weekData)}

Return valid JSON:
{
  "weekSummary": "2-3 sentence narrative",
  "scoreTrend": "improving|stable|declining",
  "keyAchievements": [],
  "challengesFaced": [],
  "improvementAreas": [],
  "nextWeekFocus": [],
  "encouragementMessage": "",
  "statistics": {
    "totalMeditationMinutes": 0,
    "journalEntries": 0,
    "checkInsCompleted": 0,
    "averageMood": 0.0,
    "averageSleep": 0.0
  },
  "quoteForWeek": {"text": "", "author": ""}
}
''';
  }
}
