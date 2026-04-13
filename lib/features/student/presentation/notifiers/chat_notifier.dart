import 'package:flutter/foundation.dart';

import '../../../../core/session/auth_session.dart';
import '../../data/services/chat_socket_service.dart';
import '../../domain/entities/student_class.dart';

/// 그룹 채팅 상태를 관리하는 ChangeNotifier
///
/// 서버 스펙 준수:
/// - nickname 보내지 않음 (서버가 accessToken + group 기반으로 결정)
/// - groupId는 join 때만 보냄
/// - chat.send에는 content만 포함
/// - chat.error, connect_error 모두 처리
class ChatNotifier extends ChangeNotifier {
  ChatNotifier({required ChatSocketService service}) : _service = service;

  final ChatSocketService _service;
  ValueChanged<int>? onInterventionCheckDue;

  // 메시지 목록 (서버의 sentAt 기준으로 정렬)
  final List<StudentChatMessage> _messages = [];
  List<StudentChatMessage> get messages => List.unmodifiable(_messages);
  int _lastInterventionCheckBucket = 0;

  // 서버에서 확정된 내 닉네임 (isMine 판별에 사용)
  String? _myNickname;
  String? get myNickname => _myNickname;

  // 연결 상태
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // chat.error / connect_error 메시지 (UI에서 소비 후 null로 처리)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// 그룹 채팅방 입장 및 소켓 연결
  void connect(String groupId) {
    final String? token = AuthSession.accessToken;
    if (token == null) {
      debugPrint('[ChatNotifier] accessToken 없음 - 연결 불가');
      _isConnected = false;
      _errorMessage = '채팅 연결에 필요한 로그인 정보가 없습니다.';
      notifyListeners();
      return;
    }

    _registerCallbacks();
    _service.connect(accessToken: token, groupId: groupId);
  }

  /// 다른 그룹으로 이동
  void switchGroup(String newGroupId) {
    final String? token = AuthSession.accessToken;
    if (token == null) return;

    _messages.clear();
    _myNickname = null;
    _lastInterventionCheckBucket = 0;
    _isConnected = false;
    notifyListeners();

    _registerCallbacks();
    _service.connect(accessToken: token, groupId: newGroupId);
  }

  /// 메시지 전송 - chat.send에 content만 포함 (서버 스펙)
  void sendMessage(String content) {
    _service.sendMessage(content);
  }

  /// 화면 이탈 시 소켓 disconnect (서버 스펙: 그룹 화면 나가면 disconnect 필요)
  void leaveGroup() {
    _service.leaveGroup();
    _isConnected = false;
    notifyListeners();
  }

  /// 에러 메시지 소비 (UI에서 스낵바 표시 후 호출)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _registerCallbacks() {
    _service
      ..onJoined = (String groupId, String nickname) {
        _myNickname = nickname;
        _isConnected = true;
        notifyListeners();
      }
      ..onHistory = (List<ChatSocketMessage> rawMessages) {
        // 초기 메시지 렌더: 서버 sentAt 기준으로 교체
        _messages
          ..clear()
          ..addAll(rawMessages.map(_toEntity));
        _lastInterventionCheckBucket = _messages.length ~/ 10;
        notifyListeners();
      }
      ..onMessage = (ChatSocketMessage msg) {
        // 중복 메시지 방지
        final bool exists = _messages.any((m) => m.id == msg.messageId);
        if (!exists) {
          _messages.add(_toEntity(msg));
          _notifyInterventionCheckIfNeeded();
          notifyListeners();
        }
      }
      ..onChatError = (String message) {
        // chat.join / chat.send 실패 (율 제한, 권한 없음 등)
        _errorMessage = message;
        notifyListeners();
      }
      ..onConnectError = (String message) {
        // connect_error: accessToken 만료, 허용되지 않은 origin 등
        _isConnected = false;
        _errorMessage = message.trim().isEmpty
            ? '채팅 서버 연결에 실패했습니다.'
            : '채팅 서버 연결에 실패했습니다. $message';
        notifyListeners();
      };
  }

  void _notifyInterventionCheckIfNeeded() {
    if (_messages.length < 10 || _messages.length % 10 != 0) {
      return;
    }

    final int currentBucket = _messages.length ~/ 10;
    if (currentBucket <= _lastInterventionCheckBucket) {
      return;
    }

    _lastInterventionCheckBucket = currentBucket;
    onInterventionCheckDue?.call(_messages.length);
  }

  StudentChatMessage _toEntity(ChatSocketMessage msg) {
    final bool isMine = _myNickname != null && msg.nickname == _myNickname;
    return StudentChatMessage(
      id: msg.messageId,
      author: msg.nickname,
      message: msg.content,
      sentAt: _formatSentAt(msg.sentAt),
      isMine: isMine,
    );
  }

  String _formatSentAt(String iso) {
    try {
      final DateTime dt = DateTime.parse(iso).toLocal();
      final DateTime now = DateTime.now();
      final Duration diff = now.difference(dt);
      if (diff.inSeconds < 60) return '방금 전';
      if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
      if (diff.inHours < 24) return '${diff.inHours}시간 전';
      return '${dt.month}/${dt.day} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  void dispose() {
    onInterventionCheckDue = null;
    _service.detachCallbacks();
    super.dispose();
  }
}
