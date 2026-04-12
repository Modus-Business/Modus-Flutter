import '../../domain/entities/student_survey.dart';
import '../../domain/entities/submit_survey_params.dart';
import '../../domain/failures/survey_failure.dart';
import '../../domain/repositories/survey_repository.dart';
import '../datasources/survey_remote_data_source.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  const SurveyRepositoryImpl({required SurveyRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final SurveyRemoteDataSource _remoteDataSource;

  @override
  Future<StudentSurvey> submitSurvey(SubmitSurveyParams params) async {
    try {
      return await _remoteDataSource.submitSurvey(params);
    } on SurveyRemoteException catch (error) {
      throw SurveyFailure(error.message, type: error.type);
    }
  }
}
