enum ChatMessageRiskLevel {
  low,
  medium,
  high,
  unknown;

  static ChatMessageRiskLevel fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'low':
        return ChatMessageRiskLevel.low;
      case 'medium':
        return ChatMessageRiskLevel.medium;
      case 'high':
        return ChatMessageRiskLevel.high;
      default:
        return ChatMessageRiskLevel.unknown;
    }
  }
}

class StudentChatMessageAdvice {
  const StudentChatMessageAdvice({
    required this.groupId,
    required this.riskLevel,
    required this.riskLevelLabel,
    required this.shouldBlock,
    required this.shouldShowPopup,
    required this.shouldSkip,
    required this.warning,
    required this.suggestedRewrite,
  });

  final String groupId;
  final ChatMessageRiskLevel riskLevel;
  final String riskLevelLabel;
  final bool shouldBlock;
  final bool shouldShowPopup;
  final bool shouldSkip;
  final String warning;
  final String suggestedRewrite;

  bool get hasWarning => warning.trim().isNotEmpty;

  bool get hasSuggestedRewrite => suggestedRewrite.trim().isNotEmpty;

  bool get hasRiskLevelLabel => riskLevelLabel.trim().isNotEmpty;

  bool get needsUserDecision => shouldBlock || shouldShowPopup;
}
