import '../entities/student_survey.dart';
import '../entities/submit_survey_params.dart';

abstract class SurveyRepository {
  Future<StudentSurvey> submitSurvey(SubmitSurveyParams params);
}
