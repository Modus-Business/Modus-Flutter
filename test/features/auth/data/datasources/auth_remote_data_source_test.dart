import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:modus_flutter/core/session/auth_session.dart';
import 'package:modus_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:modus_flutter/features/auth/domain/entities/login_params.dart';
import 'package:modus_flutter/features/auth/domain/entities/send_signup_verification_params.dart';
import 'package:modus_flutter/features/auth/domain/entities/signup_params.dart';
import 'package:modus_flutter/features/auth/domain/entities/signup_role.dart';
import 'package:modus_flutter/features/auth/domain/entities/verify_email_code_params.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(AuthSession.clear);

  group('AuthRemoteDataSourceImpl', () {
    test('로그인 요청 시 POST /auth/login으로 email과 password를 보낸다', () async {
      late Uri requestedUri;
      late Map<String, String> requestedHeaders;
      late Map<String, dynamic> requestedBody;

      final AuthRemoteDataSource dataSource = AuthRemoteDataSourceImpl(
        client: MockClient((http.Request request) async {
          requestedUri = request.url;
          requestedHeaders = request.headers;
          requestedBody = jsonDecode(request.body) as Map<String, dynamic>;

          return http.Response('', 200);
        }),
        baseUrl: 'http://localhost:8080',
      );

      await dataSource.login(
        const LoginParams(email: 'user@example.com', password: 'Password123!'),
      );

      expect(requestedUri.toString(), 'http://localhost:8080/auth/login');
      expect(requestedHeaders['Content-Type'], 'application/json');
      expect(requestedBody, {
        'email': 'user@example.com',
        'password': 'Password123!',
      });
    });

    test('로그인 응답의 accessToken과 refreshToken을 로컬 세션에 저장한다', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await AuthSession.initialize();

      final AuthRemoteDataSource dataSource = AuthRemoteDataSourceImpl(
        client: MockClient((http.Request request) async {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'accessToken': 'access-token',
                'refreshToken': 'refresh-token',
              },
            }),
            200,
          );
        }),
        baseUrl: 'http://localhost:8080',
      );

      await dataSource.login(
        const LoginParams(email: 'user@example.com', password: 'Password123!'),
      );

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      expect(AuthSession.accessToken, 'access-token');
      expect(AuthSession.refreshToken, 'refresh-token');
      expect(preferences.getString('auth.access_token'), 'access-token');
      expect(preferences.getString('auth.refresh_token'), 'refresh-token');
    });

    test('401 응답이면 로그인 실패 예외를 던진다', () async {
      final AuthRemoteDataSource dataSource = AuthRemoteDataSourceImpl(
        client: MockClient((http.Request request) async {
          return http.Response('', 401);
        }),
        baseUrl: 'http://localhost:8080',
      );

      expect(
        () => dataSource.login(
          const LoginParams(
            email: 'user@example.com',
            password: 'Password123!',
          ),
        ),
        throwsA(
          isA<AuthRemoteException>().having(
            (AuthRemoteException error) => error.type,
            'type',
            AuthRemoteExceptionType.invalidCredentials,
          ),
        ),
      );
    });

    test('회원가입 요청 시 POST /auth/signup으로 필요한 필드를 보낸다', () async {
      late Uri requestedUri;
      late Map<String, dynamic> requestedBody;

      final AuthRemoteDataSource dataSource = AuthRemoteDataSourceImpl(
        client: MockClient((http.Request request) async {
          requestedUri = request.url;
          requestedBody = jsonDecode(request.body) as Map<String, dynamic>;

          return http.Response('', 201);
        }),
        baseUrl: 'http://localhost:8080',
      );

      await dataSource.signup(
        const SignupParams(
          name: '홍길동',
          email: 'user@example.com',
          verificationCode: 'A1b2C3',
          role: SignupRole.student,
          password: 'Password123!',
          passwordConfirmation: 'Password123!',
        ),
      );

      expect(requestedUri.toString(), 'http://localhost:8080/auth/signup');
      expect(requestedBody, {
        'name': '홍길동',
        'email': 'user@example.com',
        'verificationCode': 'A1b2C3',
        'role': 'student',
        'password': 'Password123!',
        'passwordConfirmation': 'Password123!',
      });
    });

    test('회원가입 이메일 인증번호 발송 요청 시 email을 보낸다', () async {
      late Uri requestedUri;
      late Map<String, String> requestedHeaders;
      late Map<String, dynamic> requestedBody;

      final AuthRemoteDataSource dataSource = AuthRemoteDataSourceImpl(
        client: MockClient((http.Request request) async {
          requestedUri = request.url;
          requestedHeaders = request.headers;
          requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('', 200);
        }),
        baseUrl: 'http://localhost:8080',
      );

      await dataSource.sendEmailVerification(
        const SendSignupVerificationParams(email: 'user@example.com'),
      );

      expect(
        requestedUri.toString(),
        'http://localhost:8080/auth/signup/send-verification',
      );
      expect(requestedHeaders['Content-Type'], 'application/json');
      expect(requestedBody, {'email': 'user@example.com'});
    });

    test('이메일 인증 코드 검증 요청 시 POST /auth/email/verify로 code를 보낸다', () async {
      late Uri requestedUri;
      late Map<String, dynamic> requestedBody;

      final AuthRemoteDataSource dataSource = AuthRemoteDataSourceImpl(
        client: MockClient((http.Request request) async {
          requestedUri = request.url;
          requestedBody = jsonDecode(request.body) as Map<String, dynamic>;

          return http.Response('', 200);
        }),
        baseUrl: 'http://localhost:8080',
      );

      await dataSource.verifyEmailCode(
        const VerifyEmailCodeParams(code: 'A1b2C3'),
      );

      expect(
        requestedUri.toString(),
        'http://localhost:8080/auth/email/verify',
      );
      expect(requestedBody, {'code': 'A1b2C3'});
    });

    test('로그아웃 요청 시 POST /auth/logout으로 refreshToken을 보낸다', () async {
      late Uri requestedUri;
      late Map<String, String> requestedHeaders;
      late Map<String, dynamic> requestedBody;

      final AuthRemoteDataSource dataSource = AuthRemoteDataSourceImpl(
        client: MockClient((http.Request request) async {
          requestedUri = request.url;
          requestedHeaders = request.headers;
          requestedBody = jsonDecode(request.body) as Map<String, dynamic>;

          return http.Response('', 200);
        }),
        baseUrl: 'http://localhost:8080',
      );

      await dataSource.logout('refresh-token');

      expect(requestedUri.toString(), 'http://localhost:8080/auth/logout');
      expect(requestedHeaders['Content-Type'], 'application/json');
      expect(requestedBody, {'refreshToken': 'refresh-token'});
    });
  });
}
