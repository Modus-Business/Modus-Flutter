import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/session/auth_session.dart';
import '../../domain/entities/student_survey.dart';
import '../../domain/entities/submit_survey_params.dart';
import '../../domain/failures/survey_failure.dart';

class SurveyRemoteException implements Exception {
  const SurveyRemoteException(
    this.message, {
    this.type = SurveyFailureType.unknown,
  });

  final String message;
  final SurveyFailureType type;
}

abstract class SurveyRemoteDataSource {
  Future<StudentSurvey> submitSurvey(SubmitSurveyParams params);
}

class SurveyRemoteDataSourceImpl implements SurveyRemoteDataSource {
  const SurveyRemoteDataSourceImpl({
    required http.Client client,
    required String baseUrl,
  }) : _client = client,
       _baseUrl = baseUrl;

  final http.Client _client;
  final String _baseUrl;

  @override
  Future<StudentSurvey> submitSurvey(SubmitSurveyParams params) async {
    final Uri endpoint = _buildUri('/survey');
    final String encodedBody = jsonEncode(params.toJson());

    try {
      debugPrint('[Survey API] REQUEST POST $endpoint');
      debugPrint('[Survey API] Body: $encodedBody');

      final http.Response response = await _client.post(
        endpoint,
        headers: _headers(hasBody: true),
        body: encodedBody,
      );

      debugPrint(
        '[Survey API] RESPONSE ${response.statusCode} ${response.request?.url ?? ''}',
      );
      debugPrint(
        '[Survey API] Response Body: ${response.body.isEmpty ? '(empty)' : response.body}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw SurveyRemoteException(
          _resolveMessage(response),
          type: _resolveType(response.statusCode),
        );
      }

      if (response.body.trim().isEmpty) {
        throw const SurveyRemoteException('설문 제출 응답이 비어 있습니다.');
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> data =
          decoded['data'] as Map<String, dynamic>? ?? decoded;

      return StudentSurvey.fromJson(data);
    } on http.ClientException catch (error) {
      debugPrint('[Survey API] EXCEPTION $error');
      throw const SurveyRemoteException(
        '네트워크 연결을 확인한 뒤 다시 시도해주세요.',
        type: SurveyFailureType.network,
      );
    } on FormatException catch (error) {
      debugPrint('[Survey API] EXCEPTION $error');
      throw const SurveyRemoteException('설문 제출 응답 형식을 확인할 수 없습니다.');
    }
  }

  Uri _buildUri(String path) {
    final Uri? baseUri = Uri.tryParse(_baseUrl);

    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      throw const SurveyRemoteException(
        '설문 API 서버 주소가 올바르지 않습니다.',
        type: SurveyFailureType.configuration,
      );
    }

    return baseUri.resolve(path);
  }

  Map<String, String> _headers({bool hasBody = false}) {
    final String? token = AuthSession.accessToken;

    return <String, String>{
      'Accept': 'application/json',
      if (hasBody) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  SurveyFailureType _resolveType(int statusCode) {
    switch (statusCode) {
      case 400:
        return SurveyFailureType.validation;
      case 401:
        return SurveyFailureType.unauthorized;
      case 403:
        return SurveyFailureType.forbidden;
      default:
        if (statusCode >= 500) {
          return SurveyFailureType.server;
        }

        return SurveyFailureType.unknown;
    }
  }

  String _resolveMessage(http.Response response) {
    final String body = response.body.trim();

    if (body.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(body);

        if (decoded is Map<String, dynamic>) {
          final dynamic message = decoded['message'] ?? decoded['error'];

          if (message is String && message.trim().isNotEmpty) {
            return message.trim();
          }

          if (message is List) {
            final String joinedMessage = message
                .whereType<Object>()
                .map((Object item) => item.toString().trim())
                .where((String item) => item.isNotEmpty)
                .join('\n');

            if (joinedMessage.isNotEmpty) {
              return joinedMessage;
            }
          }
        }
      } on FormatException {
        // 서버 에러 포맷이 바뀌어도 상태 코드 기준 메시지로 안전하게 보여줍니다.
      }
    }

    switch (response.statusCode) {
      case 400:
        return '설문 내용을 다시 확인해주세요.';
      case 401:
        return '로그인이 필요합니다. 다시 로그인해 주세요.';
      case 403:
        return '설문 제출 권한이 없습니다.';
      default:
        if (response.statusCode >= 500) {
          return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
        }

        return '설문 제출에 실패했습니다. 다시 시도해주세요.';
    }
  }
}
