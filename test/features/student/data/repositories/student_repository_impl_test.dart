import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:modus_flutter/core/session/auth_session.dart';
import 'package:modus_flutter/features/student/data/datasources/student_remote_data_source.dart';
import 'package:modus_flutter/features/student/data/repositories/student_repository_impl.dart';

void main() {
  tearDown(AuthSession.clear);

  test('수업 목록 API 응답을 StudentClass 목록으로 매핑한다', () async {
    await AuthSession.saveTokens(accessToken: 'test-token');

    late Uri requestedUri;
    late Map<String, String> requestedHeaders;

    final StudentRepositoryImpl repository = StudentRepositoryImpl(
      remoteDataSource: StudentRemoteDataSourceImpl(
        client: MockClient((http.Request request) async {
          requestedUri = request.url;
          requestedHeaders = request.headers;

          return http.Response(
            jsonEncode({
              'success': true,
              'statusCode': 200,
              'data': {
                'classes': [
                  {
                    'classId': '0a11d54c-c75a-4d10-a4a0-1fd224c636c7',
                    'name': 'Project Studio',
                    'description':
                        'Main class for planning and delivering the service project.',
                    'classCode': null,
                    'studentCount': null,
                    'createdAt': '2026-04-10T12:00:00.000Z',
                    'myGroup': {
                      'groupId': '3f4d3db1-6dd7-4e1c-b34e-78f76bdcd001',
                      'name': 'Group 3',
                    },
                  },
                ],
              },
              'timestamp': '2026-04-11T12:00:00.000Z',
              'path': '/classes',
            }),
            200,
          );
        }),
        baseUrl: 'http://localhost:8080',
      ),
    );

    final classes = await repository.fetchClasses();

    expect(requestedUri.toString(), 'http://localhost:8080/classes');
    expect(requestedHeaders['Authorization'], 'Bearer test-token');
    expect(classes, hasLength(1));
    expect(classes.first.id, '0a11d54c-c75a-4d10-a4a0-1fd224c636c7');
    expect(classes.first.title, 'Project Studio');
    expect(
      classes.first.description,
      'Main class for planning and delivering the service project.',
    );
    expect(classes.first.classCode, '코드 미정');
    expect(classes.first.groupAssigned, isTrue);
    expect(classes.first.groupName, 'Group 3');
  });

  test('수업 코드로 수업에 참여하고 캐시에 추가한다', () async {
    await AuthSession.saveTokens(accessToken: 'test-token');

    late Uri requestedUri;
    late Map<String, String> requestedHeaders;
    late Map<String, dynamic> requestedBody;

    final StudentRepositoryImpl repository = StudentRepositoryImpl(
      remoteDataSource: StudentRemoteDataSourceImpl(
        client: MockClient((http.Request request) async {
          requestedUri = request.url;
          requestedHeaders = request.headers;
          requestedBody = jsonDecode(request.body) as Map<String, dynamic>;

          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'classId': 'class-1',
                'name': '프로덕트 스튜디오',
                'description': '서비스 구조 설계와 퍼블리싱을 함께 진행하는 메인 실습 수업',
                'classCode': 'AB12-CD34',
                'joinedAt': '2026-04-11T13:32:29.063Z',
              }),
            ),
            201,
            headers: const <String, String>{
              'content-type': 'application/json; charset=utf-8',
            },
          );
        }),
        baseUrl: 'http://localhost:8080',
      ),
    );

    final joinedClass = await repository.joinClass('AB12-CD34');

    expect(requestedUri.toString(), 'http://localhost:8080/classes/join');
    expect(requestedHeaders['Authorization'], 'Bearer test-token');
    expect(requestedBody, {'classCode': 'AB12-CD34'});
    expect(joinedClass.id, 'class-1');
    expect(joinedClass.title, '프로덕트 스튜디오');
    expect(joinedClass.classCode, 'AB12-CD34');
    expect(repository.getClasses().first.id, 'class-1');
  });
}
