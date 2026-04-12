class SubmitSurveyParams {
  const SubmitSurveyParams({
    required this.mbti,
    required this.personality,
    required this.preference,
  });

  final String mbti;
  final String personality;
  final String preference;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mbti': mbti.trim().toUpperCase(),
      'personality': personality.trim(),
      'preference': preference.trim(),
    };
  }
}
