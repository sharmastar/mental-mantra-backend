// lib/services/ai/journal_insight_engine.dart

class JournalInsight {
  final String sentiment; // positive, negative, neutral, mixed
  final double sentimentScore; // 0.0 to 1.0
  final List<String> cognitiveDistortions;
  final String aiFeedback;

  const JournalInsight({
    required this.sentiment,
    required this.sentimentScore,
    required this.cognitiveDistortions,
    required this.aiFeedback,
  });
}

class JournalInsightEngine {
  /// Analyzes a journal entry text locally to provide immediate therapeutic feedback
  Future<JournalInsight> analyzeEntry(String text) async {
    final lowerText = text.toLowerCase();

    // Simple offline keyword-based analysis
    int negativeScore = 0;
    int positiveScore = 0;
    final List<String> distortions = [];

    // All-or-nothing thinking
    if (lowerText.contains('always') ||
        lowerText.contains('never') ||
        lowerText.contains('ruined everything')) {
      distortions.add('All-or-Nothing Thinking');
      negativeScore += 2;
    }

    // Catastrophizing
    if (lowerText.contains('disaster') ||
        lowerText.contains('terrible') ||
        lowerText.contains('worst')) {
      distortions.add('Catastrophizing');
      negativeScore += 2;
    }

    // Personalization
    if (lowerText.contains('my fault') || lowerText.contains('blame myself')) {
      distortions.add('Personalization');
      negativeScore += 2;
    }

    // Positive markers
    if (lowerText.contains('happy') ||
        lowerText.contains('grateful') ||
        lowerText.contains('progress') ||
        lowerText.contains('better')) {
      positiveScore += 2;
    }

    String sentiment = 'neutral';
    double score = 0.5;

    if (positiveScore > negativeScore) {
      sentiment = 'positive';
      score = 0.8;
    } else if (negativeScore > positiveScore + 2) {
      sentiment = 'negative';
      score = 0.2;
    } else if (negativeScore > 0 && positiveScore > 0) {
      sentiment = 'mixed';
      score = 0.5;
    }

    String feedback = _generateFeedback(distortions, sentiment);

    return JournalInsight(
      sentiment: sentiment,
      sentimentScore: score,
      cognitiveDistortions: distortions,
      aiFeedback: feedback,
    );
  }

  String _generateFeedback(List<String> distortions, String sentiment) {
    if (distortions.isNotEmpty) {
      return 'I noticed some "${distortions.first}" in your writing. Remember that thoughts are just thoughts, not always facts. Try to reframe the situation gently.';
    }
    if (sentiment == 'positive') {
      return 'You are showing great resilience and positivity today. Keep holding onto this feeling!';
    }
    if (sentiment == 'negative') {
      return 'It sounds like a tough moment. Be kind to yourself today. This feeling will pass.';
    }
    return 'Thank you for reflecting today. Writing it down is a great step toward mental clarity.';
  }
}
