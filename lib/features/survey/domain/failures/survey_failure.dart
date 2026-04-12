enum SurveyFailureType {
  validation,
  unauthorized,
  forbidden,
  network,
  server,
  configuration,
  unknown,
}

class SurveyFailure implements Exception {
  const SurveyFailure(this.message, {this.type = SurveyFailureType.unknown});

  final String message;
  final SurveyFailureType type;

  @override
  String toString() => 'SurveyFailure(type: $type, message: $message)';
}
