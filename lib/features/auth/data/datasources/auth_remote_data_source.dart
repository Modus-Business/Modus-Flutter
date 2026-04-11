import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/session/auth_session.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/send_signup_verification_params.dart';
import '../../domain/entities/signup_params.dart';
import '../../domain/entities/verify_email_code_params.dart';

enum AuthRemoteExceptionType {
  invalidCredentials,
  network,
  server,
  configuration,
  unknown,
}

class AuthRemoteException implements Exception {
  const AuthRemoteException(
    this.message, {
    this.type = AuthRemoteExceptionType.unknown,
  });

  const AuthRemoteException.network([
    this.message = '네트워크 연결을 확인한 뒤 다시 시도해주세요.',
  ]) : type = AuthRemoteExceptionType.network;

  const AuthRemoteException.configuration([
    this.message = '인증 서버 주소가 올바르게 설정되지 않았습니다.',
  ]) : type = AuthRemoteExceptionType.configuration;

  final String message;
  final AuthRemoteExceptionType type;
}

abstract class AuthRemoteDataSource {
  Future<void> login(LoginParams params);
  Future<void> signup(SignupParams params);
  Future<void> sendEmailVerification(SendSignupVerificationParams params);
  Future<void> verifyEmailCode(VerifyEmailCodeParams params);
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required http.Client client,
    required String baseUrl,
  }) : _client = client,
       _baseUrl = baseUrl;

  final http.Client _client;
  final String _baseUrl;

  @override
  Future<void> login(LoginParams params) async {
    try {
      final http.Response response = await _post(
        endpoint: _buildUri('/auth/login'),
        body: <String, dynamic>{
          'email': params.email.trim(),
          'password': params.password,
        },
        successStatusCodes: const <int>{200},
        clientErrorMessage: '이메일 또는 비밀번호를 확인해주세요.',
        unknownMessage: '로그인 요청을 처리하지 못했습니다. 다시 시도해주세요.',
      );

      await _saveTokensFromResponse(response);
    } on http.ClientException catch (error) {
      _logException(error);
      throw const AuthRemoteException.network();
    }
  }

  @override
  Future<void> signup(SignupParams params) async {
    try {
      await _post(
        endpoint: _buildUri('/auth/signup'),
        body: <String, dynamic>{
          'name': params.name.trim(),
          'email': params.email.trim(),
          'verificationCode': params.verificationCode.trim(),
          'role': params.role.name,
          'password': params.password,
          'passwordConfirmation': params.passwordConfirmation,
        },
        successStatusCodes: const <int>{201},
        clientErrorMessage: '회원가입 정보를 다시 확인해주세요.',
        unknownMessage: '회원가입 요청을 처리하지 못했습니다. 다시 시도해주세요.',
      );
    } on http.ClientException catch (error) {
      _logException(error);
      throw const AuthRemoteException.network();
    }
  }

  @override
  Future<void> sendEmailVerification(
    SendSignupVerificationParams params,
  ) async {
    try {
      await _post(
        endpoint: _buildUri('/auth/signup/send-verification'),
        body: <String, dynamic>{'email': params.email.trim()},
        successStatusCodes: const <int>{200},
        clientErrorMessage: '인증번호 발송에 실패했습니다. 다시 시도해주세요.',
        unknownMessage: '인증번호 발송 요청을 처리하지 못했습니다. 다시 시도해주세요.',
      );
    } on http.ClientException catch (error) {
      _logException(error);
      throw const AuthRemoteException.network();
    }
  }

  @override
  Future<void> verifyEmailCode(VerifyEmailCodeParams params) async {
    try {
      await _post(
        endpoint: _buildUri('/auth/email/verify'),
        body: <String, dynamic>{'code': params.code.trim()},
        successStatusCodes: const <int>{200},
        clientErrorMessage: '인증 코드를 확인해주세요.',
        unknownMessage: '인증 코드 검증 요청을 처리하지 못했습니다. 다시 시도해주세요.',
      );
    } on http.ClientException catch (error) {
      _logException(error);
      throw const AuthRemoteException.network();
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _post(
        endpoint: _buildUri('/auth/logout'),
        body: <String, dynamic>{'refreshToken': refreshToken.trim()},
        successStatusCodes: const <int>{200},
        clientErrorMessage: '로그아웃 요청을 처리하지 못했습니다.',
        unknownMessage: '로그아웃 요청을 처리하지 못했습니다.',
      );
    } on http.ClientException catch (error) {
      _logException(error);
      throw const AuthRemoteException.network();
    }
  }

  Future<http.Response> _post({
    required Uri endpoint,
    Map<String, dynamic>? body,
    required Set<int> successStatusCodes,
    required String clientErrorMessage,
    required String unknownMessage,
  }) async {
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };
    final String? encodedBody = body == null ? null : jsonEncode(body);

    _logRequest(
      method: 'POST',
      endpoint: endpoint,
      headers: headers,
      body: encodedBody,
    );

    final http.Response response = await _client.post(
      endpoint,
      headers: headers,
      body: encodedBody,
    );

    _logResponse(response);

    if (successStatusCodes.contains(response.statusCode)) {
      return response;
    }

    throw AuthRemoteException(
      _resolveMessage(
        response,
        clientErrorMessage: clientErrorMessage,
        unknownMessage: unknownMessage,
      ),
      type: _resolveType(response.statusCode),
    );
  }

  Future<void> _saveTokensFromResponse(http.Response response) async {
    final String body = response.body.trim();

    if (body.isEmpty) {
      return;
    }

    try {
      final dynamic decoded = jsonDecode(body);
      final String? accessToken = _findToken(
        decoded,
        keys: const <String>['accessToken', 'access_token', 'token', 'jwt'],
      );
      final String? refreshToken = _findToken(
        decoded,
        keys: const <String>['refreshToken', 'refresh_token'],
      );

      if (accessToken != null || refreshToken != null) {
        await AuthSession.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        debugPrint('[Auth API] Session tokens saved.');
      }
    } on FormatException {
      // 로그인 응답이 비어있거나 JSON이 아니면 토큰 저장만 건너뜁니다.
    }
  }

  String? _findToken(dynamic value, {required List<String> keys}) {
    if (value is Map<String, dynamic>) {
      for (final String key in keys) {
        final dynamic token = value[key];

        if (token is String && token.trim().isNotEmpty) {
          return token;
        }
      }

      for (final dynamic nestedValue in value.values) {
        final String? token = _findToken(nestedValue, keys: keys);

        if (token != null) {
          return token;
        }
      }
    }

    return null;
  }

  Uri _buildUri(String path) {
    final Uri? baseUri = Uri.tryParse(_baseUrl);

    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      throw const AuthRemoteException.configuration();
    }

    return baseUri.resolve(path);
  }

  AuthRemoteExceptionType _resolveType(int statusCode) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return AuthRemoteExceptionType.invalidCredentials;
    }

    if (statusCode >= 500) {
      return AuthRemoteExceptionType.server;
    }

    return AuthRemoteExceptionType.unknown;
  }

  String _resolveMessage(
    http.Response response, {
    required String clientErrorMessage,
    required String unknownMessage,
  }) {
    final String body = response.body.trim();

    if (body.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(body);

        if (decoded is Map<String, dynamic>) {
          final dynamic message = decoded['message'] ?? decoded['error'];

          if (message is String && message.trim().isNotEmpty) {
            return message.trim();
          }
        }
      } on FormatException {
        // 응답 형식이 일정하지 않아도 상태 코드 기준 메시지로 안전하게 처리합니다.
      }
    }

    switch (response.statusCode) {
      case 400:
      case 401:
      case 403:
        return clientErrorMessage;
      default:
        if (response.statusCode >= 500) {
          return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
        }

        return unknownMessage;
    }
  }

  void _logRequest({
    required String method,
    required Uri endpoint,
    required Map<String, String> headers,
    required String? body,
  }) {
    debugPrint('[Auth API] REQUEST $method $endpoint');
    debugPrint('[Auth API] Headers: $headers');
    debugPrint('[Auth API] Body: ${body ?? '(empty)'}');
  }

  void _logResponse(http.Response response) {
    debugPrint(
      '[Auth API] RESPONSE ${response.statusCode} ${response.request?.url ?? ''}',
    );
    debugPrint(
      '[Auth API] Response Body: ${response.body.isEmpty ? '(empty)' : response.body}',
    );
  }

  void _logException(Object error) {
    debugPrint('[Auth API] EXCEPTION $error');
  }
}
