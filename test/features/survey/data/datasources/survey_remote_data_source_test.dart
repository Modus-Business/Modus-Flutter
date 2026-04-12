import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:modus_flutter/features/survey/data/datasources/survey_remote_data_source.dart';
import 'package:modus_flutter/features/survey/domain/entities/submit_survey_params.dart';

void main() {
  test('POST /survey에 설문 필드만 전송하고 201 응답을 반환한다', () async {
    final MockClient client = MockClient((http.Request request) async {
      expect(request.method, 'POST');
      expect(request.url.toString(), 'http://api.modus.test/survey');
      expect(request.headers['Content-Type'], 'application/json');
      expect(jsonDecode(request.body), <String, dynamic>{
        'mbti': 'INTJ',
        'personality': '계획적으로 움직이는 편입니다.',
        'preference': '정리된 문서 협업을 선호합니다.',
      });

      return http.Response.bytes(
        utf8.encode(
          jsonEncode(<String, dynamic>{
            'success': true,
            'statusCode': 201,
            'data': <String, dynamic>{
              'surveyId': 'survey-1',
              'userId': 'student-1',
              'mbti': 'INTJ',
              'personality': '계획적으로 움직이는 편입니다.',
              'preference': '정리된 문서 협업을 선호합니다.',
              'createdAt': '2026-04-12T14:44:08.094Z',
              'updatedAt': '2026-04-12T14:44:08.094Z',
            },
            'timestamp': '2026-04-12T15:00:58.452Z',
            'path': '/survey',
          }),
        ),
        201,
        headers: <String, String>{
          'content-type': 'application/json; charset=utf-8',
        },
      );
    });
    final SurveyRemoteDataSource dataSource = SurveyRemoteDataSourceImpl(
      client: client,
      baseUrl: 'http://api.modus.test',
    );

    final result = await dataSource.submitSurvey(
      const SubmitSurveyParams(
        mbti: 'intj',
        personality: '계획적으로 움직이는 편입니다.',
        preference: '정리된 문서 협업을 선호합니다.',
      ),
    );

    expect(result.surveyId, 'survey-1');
    expect(result.userId, 'student-1');
    expect(result.mbti, 'INTJ');
  });
}
