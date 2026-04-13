enum ChatContributionLevel {
  low,
  medium,
  high,
  unknown;

  static ChatContributionLevel fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'low':
        return ChatContributionLevel.low;
      case 'medium':
        return ChatContributionLevel.medium;
      case 'high':
        return ChatContributionLevel.high;
      default:
        return ChatContributionLevel.unknown;
    }
  }
}

class StudentChatContributionAnalysis {
  const StudentChatContributionAnalysis({
    required this.groupId,
    required this.summary,
    required this.members,
  });

  final String groupId;
  final String summary;
  final List<StudentChatContributionMember> members;
}

class StudentChatContributionMember {
  const StudentChatContributionMember({
    required this.nickname,
    required this.contributionScore,
    required this.contributionLevel,
    required this.contributionTypes,
    required this.reason,
  });

  final String nickname;
  final int contributionScore;
  final ChatContributionLevel contributionLevel;
  final List<String> contributionTypes;
  final String reason;
}
