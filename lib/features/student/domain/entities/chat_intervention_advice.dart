enum ChatInterventionType {
  participation,
  deepening,
  deepQuestion,
  unknown;

  static ChatInterventionType fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'participation':
        return ChatInterventionType.participation;
      case 'deepening':
        return ChatInterventionType.deepening;
      case 'deep_question':
        return ChatInterventionType.deepQuestion;
      default:
        return ChatInterventionType.unknown;
    }
  }
}

class StudentChatInterventionAdvice {
  const StudentChatInterventionAdvice({
    required this.groupId,
    required this.interventionNeeded,
    required this.interventionType,
    required this.reason,
    required this.suggestedMessage,
  });

  final String groupId;
  final bool interventionNeeded;
  final ChatInterventionType interventionType;
  final String reason;
  final String suggestedMessage;

  bool get hasReason => reason.trim().isNotEmpty;

  bool get hasSuggestedMessage => suggestedMessage.trim().isNotEmpty;
}
