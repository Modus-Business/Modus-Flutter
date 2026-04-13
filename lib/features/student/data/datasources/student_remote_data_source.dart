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

  Future<Map<String, dynamic>> fetchGroupDetail(String groupId);

  Future<List<Map<String, dynamic>>> fetchGroupNotices(String groupId);

  Future<Map<String, dynamic>> createPresignedUploadUrl({
    required String fileName,
    required String contentType,
    required String purpose,
  });

  Future<void> uploadPresignedFile({
    required String uploadUrl,
    required String contentType,
    required Uint8List bytes,
  });

  Future<void> submitAssignment({
    required String groupId,
    required String fileUrl,
    required String link,
  });

  Future<Map<String, dynamic>?> fetchMySubmission(String groupId);

  Future<Map<String, dynamic>> fetchGroupNickname(String groupId);

  Future<Map<String, dynamic>> requestChatMessageAdvice({
    required String groupId,
    required String content,
  });

  Future<Map<String, dynamic>> requestChatInterventionAdvice(String groupId);

  Future<Map<String, dynamic>> requestChatContributionAnalysis(String groupId);

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

      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      return decoded['data'] as Map<String, dynamic>? ?? decoded;
    } on http.ClientException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('네트워크 연결을 확인한 뒤 다시 시도해주세요.');
    } on FormatException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('수업 참여 응답 형식을 확인할 수 없습니다.');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchGroupDetail(String groupId) async {
    final Uri endpoint = _buildUri('/groups/${Uri.encodeComponent(groupId)}');

    return _getData(
      endpoint: endpoint,
      failureMessage: '모둠 상세 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
      formatMessage: '모둠 상세 정보 응답 형식을 확인할 수 없습니다.',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchGroupNotices(String groupId) async {
    final Uri endpoint = _buildUri(
      '/notices/group/${Uri.encodeComponent(groupId)}',
    );
    final Map<String, dynamic> data = await _getData(
      endpoint: endpoint,
      failureMessage: '공지 목록을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
      formatMessage: '공지 목록 응답 형식을 확인할 수 없습니다.',
    );
    final List<dynamic> notices =
        data['notices'] as List<dynamic>? ?? <dynamic>[];

    return notices
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => item)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> createPresignedUploadUrl({
    required String fileName,
    required String contentType,
    required String purpose,
  }) async {
    final Uri endpoint = _buildUri('/storage/presigned-upload-url');

    return _postData(
      endpoint: endpoint,
      body: <String, dynamic>{
        'fileName': fileName.trim(),
        'contentType': contentType.trim(),
        'purpose': purpose.trim(),
      },
      successStatusCodes: const <int>{201},
      failureMessage: '파일 업로드 URL을 발급받지 못했습니다. 잠시 후 다시 시도해주세요.',
      formatMessage: '파일 업로드 URL 응답 형식을 확인할 수 없습니다.',
    );
  }

  @override
  Future<void> uploadPresignedFile({
    required String uploadUrl,
    required String contentType,
    required Uint8List bytes,
  }) async {
    final Uri? endpoint = Uri.tryParse(uploadUrl);

    if (endpoint == null || !endpoint.hasScheme || endpoint.host.isEmpty) {
      throw const StudentRemoteException('파일 업로드 주소가 올바르지 않습니다.');
    }

    try {
      debugPrint('[Student API] REQUEST PUT $endpoint');
      debugPrint('[Student API] Upload Content-Type: $contentType');

      final http.Response response = await _client.put(
        endpoint,
        headers: <String, String>{'Content-Type': contentType},
        body: bytes,
      );

      debugPrint(
        '[Student API] RESPONSE ${response.statusCode} ${response.request?.url ?? ''}',
      );
      debugPrint(
        '[Student API] Response Body: ${response.body.isEmpty ? '(empty)' : response.body}',
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw const StudentRemoteException('파일 업로드에 실패했습니다. 잠시 후 다시 시도해주세요.');
      }
    } on http.ClientException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('네트워크 연결을 확인한 뒤 다시 시도해주세요.');
    }
  }

  @override
  Future<void> submitAssignment({
    required String groupId,
    required String fileUrl,
    required String link,
  }) async {
    final Uri endpoint = _buildUri('/assignments/submissions');
    final Map<String, dynamic> body = <String, dynamic>{
      'groupId': groupId.trim(),
    };

    if (fileUrl.trim().isNotEmpty) {
      body['fileUrl'] = fileUrl.trim();
    }
    if (link.trim().isNotEmpty) {
      body['link'] = link.trim();
    }

    await _postData(
      endpoint: endpoint,
      body: body,
      successStatusCodes: const <int>{201},
      failureMessage: '과제 제출에 실패했습니다. 잠시 후 다시 시도해주세요.',
      formatMessage: '과제 제출 응답 형식을 확인할 수 없습니다.',
    );
  }

  @override
  Future<Map<String, dynamic>?> fetchMySubmission(String groupId) async {
    final Uri endpoint = _buildUri(
      '/assignments/submissions/my/${Uri.encodeComponent(groupId)}',
    );

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

      if (response.statusCode == 404) {
        return null; // 아직 제출 내역이 없음
      }

      if (response.statusCode != 200) {
        throw const StudentRemoteException('내 과제 제출 내역을 불러오지 못했습니다.');
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      return decoded['data'] as Map<String, dynamic>? ?? decoded;
    } on http.ClientException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('네트워크 연결을 확인한 뒤 다시 시도해주세요.');
    } on FormatException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('제출 내역 응답 형식을 확인할 수 없습니다.');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchGroupNickname(String groupId) async {
    final Uri endpoint = _buildUri(
      '/groups/${Uri.encodeComponent(groupId)}/nickname',
    );

    return _getData(
      endpoint: endpoint,
      failureMessage: '모둠 닉네임을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
      formatMessage: '모둠 닉네임 응답 형식을 확인할 수 없습니다.',
    );
  }

  @override
  Future<Map<String, dynamic>> requestChatMessageAdvice({
    required String groupId,
    required String content,
  }) async {
    final Uri endpoint = _buildUri('/chat/message-advice');

    return _postData(
      endpoint: endpoint,
      body: <String, dynamic>{
        'groupId': groupId.trim(),
        'content': content.trim(),
      },
      successStatusCodes: const <int>{200, 201},
      failureMessage: '메시지 AI 조언을 받지 못했습니다. 잠시 후 다시 시도해주세요.',
      formatMessage: '메시지 AI 조언 응답 형식을 확인할 수 없습니다.',
    );
  }

  @override
  Future<Map<String, dynamic>> requestChatInterventionAdvice(
    String groupId,
  ) async {
    final Uri endpoint = _buildUri('/chat/intervention-advice');

    return _postData(
      endpoint: endpoint,
      body: <String, dynamic>{'groupId': groupId.trim()},
      successStatusCodes: const <int>{200, 201},
      failureMessage: '그룹 대화 AI 조언을 받지 못했습니다. 잠시 후 다시 시도해주세요.',
      formatMessage: '그룹 대화 AI 조언 응답 형식을 확인할 수 없습니다.',
    );
  }

  @override
  Future<Map<String, dynamic>> requestChatContributionAnalysis(
    String groupId,
  ) async {
    final Uri endpoint = _buildUri('/chat/contribution-analysis');

    return _postData(
      endpoint: endpoint,
      body: <String, dynamic>{'groupId': groupId.trim()},
      successStatusCodes: const <int>{200, 201},
      failureMessage: '그룹 대화 기여도 분석을 받지 못했습니다. 잠시 후 다시 시도해주세요.',
      formatMessage: '그룹 대화 기여도 분석 응답 형식을 확인할 수 없습니다.',
    );
  }

  @override
  Future<Map<String, dynamic>> fetchSettings() async {
    final Uri endpoint = _buildUri('/me/settings');

    return _getData(
      endpoint: endpoint,
      failureMessage: '사용자 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
      formatMessage: '사용자 정보 응답 형식을 확인할 수 없습니다.',
    );
  }

  Future<Map<String, dynamic>> _getData({
    required Uri endpoint,
    required String failureMessage,
    required String formatMessage,
  }) async {
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
        throw StudentRemoteException(failureMessage);
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      return decoded['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    } on http.ClientException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('네트워크 연결을 확인한 뒤 다시 시도해주세요.');
    } on FormatException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw StudentRemoteException(formatMessage);
    }
  }

  Future<Map<String, dynamic>> _postData({
    required Uri endpoint,
    required Map<String, dynamic> body,
    required Set<int> successStatusCodes,
    required String failureMessage,
    required String formatMessage,
  }) async {
    final String encodedBody = jsonEncode(body);

    try {
      debugPrint('[Student API] REQUEST POST $endpoint');
      debugPrint('[Student API] Body: $encodedBody');

      final http.Response response = await _client.post(
        endpoint,
        headers: _headers(hasBody: true),
        body: encodedBody,
      );

      debugPrint(
        '[Student API] RESPONSE ${response.statusCode} ${response.request?.url ?? ''}',
      );
      debugPrint(
        '[Student API] Response Body: ${response.body.isEmpty ? '(empty)' : response.body}',
      );

      if (!successStatusCodes.contains(response.statusCode)) {
        throw StudentRemoteException(failureMessage);
      }

      if (response.body.trim().isEmpty) {
        return <String, dynamic>{};
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      return decoded['data'] as Map<String, dynamic>? ?? decoded;
    } on http.ClientException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw const StudentRemoteException('네트워크 연결을 확인한 뒤 다시 시도해주세요.');
    } on FormatException catch (error) {
      debugPrint('[Student API] EXCEPTION $error');
      throw StudentRemoteException(formatMessage);
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
