import '../entities/student_survey.dart';
import '../entities/submit_survey_params.dart';
import '../repositories/survey_repository.dart';

class SubmitSurveyUseCase {
  const SubmitSurveyUseCase(this._repository);

  final SurveyRepository _repository;

  Future<StudentSurvey> call(SubmitSurveyParams params) {
    return _repository.submitSurvey(params);
  }
}
