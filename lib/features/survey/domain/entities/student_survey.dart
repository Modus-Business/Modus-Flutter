class StudentSurvey {
  const StudentSurvey({
    required this.surveyId,
    required this.userId,
    required this.mbti,
    required this.personality,
    required this.preference,
    required this.createdAt,
    required this.updatedAt,
  });

  final String surveyId;
  final String userId;
  final String mbti;
  final String personality;
  final String preference;
  final String createdAt;
  final String updatedAt;

  factory StudentSurvey.fromJson(Map<String, dynamic> json) {
    return StudentSurvey(
      surveyId: _asString(json['surveyId']),
      userId: _asString(json['userId']),
      mbti: _asString(json['mbti']),
      personality: _asString(json['personality']),
      preference: _asString(json['preference']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  static String _asString(dynamic value) {
    if (value is String) {
      return value;
    }

    return value?.toString() ?? '';
  }
}
