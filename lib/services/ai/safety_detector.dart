class SafetyAssessment {
  final bool containsCrisisIndicator;
  final String? crisisType;
  final double confidence;
  final String? extractedConcern;
  final String? suggestedResponse;
  final bool requiresImmediateEscalation;

  const SafetyAssessment({
    this.containsCrisisIndicator = false,
    this.crisisType,
    this.confidence = 0.0,
    this.extractedConcern,
    this.suggestedResponse,
    this.requiresImmediateEscalation = false,
  });

  factory SafetyAssessment.fromJson(Map<String, dynamic> json) =>
      SafetyAssessment(
        containsCrisisIndicator: json['containsCrisisIndicator'] ?? false,
        crisisType: json['crisisType'],
        confidence: (json['confidence'] ?? 0.0).toDouble(),
        extractedConcern: json['extractedConcern'],
        suggestedResponse: json['suggestedResponse'],
        requiresImmediateEscalation:
            json['requiresImmediateEscalation'] ?? false,
      );
}

class SafetyDetector {
  SafetyDetector._();

  static final List<_CrisisPattern> _patterns = [
    _CrisisPattern(r'\b(kill myself|end my life|commit suicide|want to die)\b',
        'suicidal', 0.95, true),
    _CrisisPattern(r'\b(self.?harm|cut myself|hurt myself|burn myself)\b',
        'self_harm', 0.90, true),
    _CrisisPattern(r"\b(no reason to live|better off dead|can't go on)\b",
        'suicidal', 0.85, true),
    _CrisisPattern(r'\b(ending it all|final goodbye|last goodbye)\b',
        'suicidal', 0.90, true),
    _CrisisPattern(r'\b(hopeless|no hope|nothing matters anymore)\b',
        'hopelessness', 0.60, false),
    _CrisisPattern(r'\b(abused|being abused|physical abuse|sexual abuse)\b',
        'abuse', 0.70, true),
    _CrisisPattern(r'\b(emergency|i need help now|help me please)\b',
        'emergency', 0.75, true),
    _CrisisPattern(r"\b(can't take it anymore|i give up|i quit)\b",
        'hopelessness', 0.65, false),
    _CrisisPattern(r'\b(no one cares|no one understands|all alone)\b',
        'loneliness', 0.40, false),
    _CrisisPattern(r'\b(pills? to end it| overdose|hanging|jump off)\b',
        'suicidal', 0.95, true),
  ];

  static SafetyAssessment assess(String text) {
    if (text.isEmpty) const SafetyAssessment();
    // Limit text length while preserving word boundaries to avoid splitting crisis keywords
    final textToAssess = text.length > 5000
        ? _trimPreservingWords(text, 2500)
        : text;
    final lower = textToAssess.toLowerCase();
    for (final pattern in _patterns) {
      if (pattern.regex.hasMatch(lower)) {
        return SafetyAssessment(
          containsCrisisIndicator: true,
          crisisType: pattern.type,
          confidence: pattern.confidence,
          extractedConcern: pattern.regex.stringMatch(lower),
          requiresImmediateEscalation: pattern.requiresEscalation,
          suggestedResponse: _getResponse(pattern.type),
        );
      }
    }
    return const SafetyAssessment();
  }

  /// Trims [text] to roughly [maxChars] from both ends, snapping to the
  /// nearest word boundary so crisis keywords are never split in half.
  static String _trimPreservingWords(String text, int maxChars) {
    final firstSpace = text.indexOf(' ', maxChars);
    final startEnd = firstSpace == -1 ? maxChars : firstSpace + 1;

    final lastSpaceIdx = text.lastIndexOf(' ', text.length - maxChars);
    final tailStart = lastSpaceIdx == -1 ? text.length - maxChars : lastSpaceIdx;

    final head = text.substring(0, startEnd);
    final tail = text.substring(tailStart);
    return '$head $tail';
  }

  static String _getResponse(String crisisType) {
    switch (crisisType) {
      case 'suicidal':
        return 'I hear how much pain you\'re in. Please reach out for support right now. Your life matters and help is available 24/7.';
      case 'self_harm':
        return 'It sounds like you\'re going through an extremely difficult time. Please contact a crisis helpline where trained professionals can support you.';
      case 'abuse':
        return 'What you\'re describing is not okay. You deserve safety and support. Please contact a helpline or emergency services.';
      case 'hopelessness':
        return 'I can hear that things feel really hard right now. While these feelings are valid, please know that situations can change. Would you like to see some crisis resources?';
      case 'emergency':
        return 'It sounds like you need immediate support. Please call emergency services (108) or a crisis helpline right away.';
      default:
        return 'I want to make sure you\'re safe. Please reach out to a crisis helpline for immediate support.';
    }
  }
}

class _CrisisPattern {
  final RegExp regex;
  final String type;
  final double confidence;
  final bool requiresEscalation;
  _CrisisPattern(
      String pattern, this.type, this.confidence, this.requiresEscalation)
      : regex = RegExp(pattern, caseSensitive: false);
}
