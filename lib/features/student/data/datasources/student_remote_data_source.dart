import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/session/auth_session.dart';

class StudentRemoteException implements Exception {
  const StudentRemoteException(this.message);

  final String message;
}

abstract class StudentRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchClasses();

  Future<Map<String, dynamic>> joinClass(String classCode);

  Future<Map<String, dynamic>> fetchSettings();
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  const StudentRemoteDataSourceImpl({
    required http.Client client,
    required String baseUrl,
  }) : _client = client,
       _baseUrl = baseUrl;

  final http.Client _client;
  final String _baseUrl;

  @override
  Future<List<Map<String, dynamic>>> fetchClasses() async {
    final Uri endpoint = _buildUri('/classes');

    try {
      debugPrint('[Student API] REQUEST GET $endpoint');

      final http.Response response = await _client.get(
        endpoint,
        headers: _headers(),
      );

      debugPrint(
        '[Student API] RESPONSE ${response.statusCode} ${response.request?.url ?? ''}',
      );
      debugPrint(
        '[Student API] Response Body: ${response.body.isEmpty ? '(empty)' : response.body}',
      );

      if (response.statusCode != 200) {
        throw const StudentRemoteException(
          '수업 목록을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
        );
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> data =
          decoded['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final List<dynamic> classes =
          data['classes'] as List<dynamic>? ?? <dynamic>[];

      return classes
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> item) => item)
          .toList();
    } on http.ClientException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('네트워크 연결을 확인한 뒤 다시 시도해주세요.');
    } on FormatException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('수업 목록 응답 형식을 확인할 수 없습니다.');
    }
  }

  @override
  Future<Map<String, dynamic>> joinClass(String classCode) async {
    final Uri endpoint = _buildUri('/classes/join');
    final String body = jsonEncode(<String, dynamic>{
      'classCode': classCode.trim(),
    });

    try {
      debugPrint('[Student API] REQUEST POST $endpoint');
      debugPrint('[Student API] Body: $body');

      final http.Response response = await _client.post(
        endpoint,
        headers: _headers(hasBody: true),
        body: body,
      );

      debugPrint(
        '[Student API] RESPONSE ${response.statusCode} ${response.request?.url ?? ''}',
      );
      debugPrint(
        '[Student API] Response Body: ${response.body.isEmpty ? '(empty)' : response.body}',
      );

      if (response.statusCode != 201) {
        throw const StudentRemoteException('수업 참여에 실패했습니다. 수업 코드를 확인해주세요.');
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on http.ClientException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('네트워크 연결을 확인한 뒤 다시 시도해주세요.');
    } on FormatException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('수업 참여 응답 형식을 확인할 수 없습니다.');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchSettings() async {
    final Uri endpoint = _buildUri('/me/settings');

    try {
      debugPrint('[Student API] REQUEST GET $endpoint');

      final http.Response response = await _client.get(
        endpoint,
        headers: _headers(),
      );

      debugPrint(
        '[Student API] RESPONSE ${response.statusCode} ${response.request?.url ?? ''}',
      );
      debugPrint(
        '[Student API] Response Body: ${response.body.isEmpty ? '(empty)' : response.body}',
      );

      if (response.statusCode != 200) {
        throw const StudentRemoteException(
          '사용자 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
        );
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      return decoded['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    } on http.ClientException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('네트워크 연결을 확인한 뒤 다시 시도해주세요.');
    } on FormatException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('사용자 정보 응답 형식을 확인할 수 없습니다.');
    }
  }

  Uri _buildUri(String path) {
    final Uri? baseUri = Uri.tryParse(_baseUrl);

    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      throw const StudentRemoteException('학생 API 서버 주소가 올바르지 않습니다.');
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
}
