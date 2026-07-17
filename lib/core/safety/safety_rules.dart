// lib/core/safety/safety_rules.dart

class SafetyRules {
  const SafetyRules._();

  // Clinical/Therapeutic constraints
  static const String clinicalGuidelines = '''
1. Never diagnose any illness or condition (e.g., do not say "You have depression/anxiety/OCD").
2. Never prescribe or suggest specific medical doses or drugs (e.g., Prozac, Xanax, etc.).
3. Always validate the client's emotional state before offering coping exercises.
4. Promote professional clinical help when distress is persistent or severe.
5. If self-harm or suicide is suspected, trigger crisis safety plans immediately.
''';

  // Crisis detection regular expressions
  static final List<RegExp> crisisPatterns = [
    RegExp(r'\b(suicide|suicidal|kill myself|end my life|want to die|ending it all)\b', caseSensitive: false),
    RegExp(r'\b(self.?harm|cut myself|harm myself|hurt myself|burn myself|slashing)\b', caseSensitive: false),
    RegExp(r'\b(better off dead|no reason to live|wish i was dead|final goodbye|last goodbye)\b', caseSensitive: false),
    RegExp(r'\b(pills to end it|overdose on|hang myself|jump from a bridge|jumping off)\b', caseSensitive: false),
    RegExp(r'\b(abused|being abused|domestic violence|beaten up|physical abuse)\b', caseSensitive: false),
  ];

  // Helper response for crisis situations
  static const String crisisResponse = '''
I hear how much pain you're in, and I want you to be safe. Because I'm an AI wellness companion, I cannot provide emergency crisis support, but there are people who care and want to support you right now. 

Please reach out to one of these free, confidential resources immediately:
• **AASRA** (India, 24x7): +91-9820466726
• **Kiran Helpline** (India): 1800-599-0019
• **988 Suicide & Crisis Lifeline** (US/Canada): Call or text 988
• **Crisis Text Line**: Text HOME to 741741
• **International Support**: Visit [findahelpline.com](https://findahelpline.com) to find support in your country.

Please contact a professional therapist, doctor, or local emergency services if you are in immediate danger. You do not have to go through this alone.
''';

  // Fallback response for offline scenarios
  static const String offlineResponse = '''
It looks like you're currently offline. I can't connect to my AI server, but I'm still here for you. 

Here is a quick grounding exercise to help you find calm:
1. Breathe in deeply through your nose for 4 seconds.
2. Hold your breath for 4 seconds.
3. Exhale slowly through your mouth for 4 seconds.
4. Rest for 4 seconds.
Repeat this cycle 3-4 times.

If you are experiencing a crisis, please seek immediate help from family, a professional, or contact your local emergency hotline. Once you're back online, we can continue our conversation.
''';
}
