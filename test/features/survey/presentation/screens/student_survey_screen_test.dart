import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modus_flutter/features/survey/domain/entities/student_survey.dart';
import 'package:modus_flutter/features/survey/domain/entities/submit_survey_params.dart';
import 'package:modus_flutter/features/survey/domain/repositories/survey_repository.dart';
import 'package:modus_flutter/features/survey/domain/usecases/submit_survey_use_case.dart';
import 'package:modus_flutter/features/survey/presentation/screens/student_survey_screen.dart';

void main() {
  testWidgets('설문 입력 후 제출하면 완료 콜백을 호출한다', (WidgetTester tester) async {
    bool completed = false;
    final _FakeSurveyRepository repository = _FakeSurveyRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: StudentSurveyScreen(
          submitSurveyUseCase: SubmitSurveyUseCase(repository),
          onCompleted: () {
            completed = true;
          },
        ),
      ),
    );

    expect(find.text('설문 제출'), findsOneWidget);

    await tester.tap(find.text('INTJ'));
    await tester.enterText(find.byType(TextField).at(0), '계획적으로 움직이는 편입니다.');
    await tester.enterText(find.byType(TextField).at(1), '정리된 문서 협업을 선호합니다.');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('설문 제출'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('설문 제출'));
    await tester.pump();

    expect(completed, isTrue);
    expect(repository.lastParams?.mbti, 'INTJ');
    expect(repository.lastParams?.personality, '계획적으로 움직이는 편입니다.');
    expect(repository.lastParams?.preference, '정리된 문서 협업을 선호합니다.');
  });
}

class _FakeSurveyRepository implements SurveyRepository {
  SubmitSurveyParams? lastParams;

  @override
  Future<StudentSurvey> submitSurvey(SubmitSurveyParams params) async {
    lastParams = params;

    return const StudentSurvey(
      surveyId: 'survey-1',
      userId: 'student-1',
      mbti: 'INTJ',
      personality: '계획적으로 움직이는 편입니다.',
      preference: '정리된 문서 협업을 선호합니다.',
      createdAt: '2026-04-12T14:44:08.094Z',
      updatedAt: '2026-04-12T14:44:08.094Z',
    );
  }
}
