enum WellnessActionType {
  breathing,
  meditation,
  sos,
  sleepSounds,
  recoveryPlan,
  grounding,
  professionalHelp,
}

class WellnessAction {
  final WellnessActionType type;
  final String label;
  final String route;

  const WellnessAction({
    required this.type,
    required this.label,
    required this.route,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'label': label,
        'route': route,
      };

  factory WellnessAction.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = WellnessActionType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => WellnessActionType.breathing,
    );
    return WellnessAction(
      type: type,
      label: json['label'] as String? ?? '',
      route: json['route'] as String? ?? '',
    );
  }
}

class NovaMessage {
  final String messageId;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isStreaming;
  final WellnessAction? wellnessAction;

  NovaMessage({
    String? messageId,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isStreaming = false,
    this.wellnessAction,
  })  : messageId =
            messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  NovaMessage copyWith({
    String? messageId,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isStreaming,
    WellnessAction? wellnessAction,
  }) {
    return NovaMessage(
      messageId: messageId ?? this.messageId,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      wellnessAction: wellnessAction ?? this.wellnessAction,
    );
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        if (wellnessAction != null) 'wellnessAction': wellnessAction!.toJson(),
      };

  factory NovaMessage.fromJson(Map<String, dynamic> json) {
    WellnessAction? wa;
    final waMap = json['wellnessAction'];
    if (waMap is Map) {
      wa = WellnessAction.fromJson(Map<String, dynamic>.from(waMap));
    }
    return NovaMessage(
      messageId: json['messageId'] as String?,
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      wellnessAction: wa,
    );
  }
}

class NovaConversationHistory {
  final List<NovaMessage> messages;
  final String? lastFailedMessage;

  const NovaConversationHistory({
    this.messages = const [],
    this.lastFailedMessage,
  });
}
