class AssessmentResponse {
  final String questionId;
  final String question;
  final String type;
  final dynamic answer;

  const AssessmentResponse({
    required this.questionId,
    required this.question,
    required this.type,
    required this.answer,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'question': question,
        'type': type,
        'answer': answer,
      };
}
