import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;

/// 서버에서 내려오는 채팅 메시지 모델
class ChatSocketMessage {
  const ChatSocketMessage({
    required this.messageId,
    required this.groupId,
    required this.nickname,
    required this.content,
    required this.sentAt,
  });

  final String messageId;
  final String groupId;
  final String nickname;
  final String content;
  final String sentAt;

  factory ChatSocketMessage.fromJson(Map<String, dynamic> json) {
    return ChatSocketMessage(
      messageId: json['messageId'] as String? ?? '',
      groupId: json['groupId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      content: json['content'] as String? ?? '',
      sentAt: json['sentAt'] as String? ?? '',
    );
  }
}

typedef ChatMessageCallback = void Function(ChatSocketMessage message);
typedef ChatHistoryCallback = void Function(List<ChatSocketMessage> messages);
typedef ChatJoinedCallback = void Function(String groupId, String nickname);
typedef ChatErrorCallback = void Function(String message);

/// Socket.IO /chat 네임스페이스 기반 그룹 채팅 서비스.
///
/// 서버 스펙:
/// - namespace: /chat
/// - 인증: auth.token (accessToken)
/// - 그룹 입장: chat.join { groupId }
/// - 메시지 전송: chat.send { content }
/// - 화면 이탈 시 disconnect 필요
/// - 다른 그룹으로 이동 시 새 groupId로 재입장
class ChatSocketService {
  ChatSocketService._();

  static const String _socketNamespace = '/chat';
  static const String _socketEnginePath = '/socket.io/';

  static ChatSocketService? _instance;

  static ChatSocketService get instance {
    _instance ??= ChatSocketService._();
    return _instance!;
  }

  sio.Socket? _socket;
  String? _currentGroupId;
  String? _accessToken;

  // 콜백
  ChatMessageCallback? onMessage;
  ChatHistoryCallback? onHistory;
  ChatJoinedCallback? onJoined;
  ChatErrorCallback? onChatError;
  ChatErrorCallback? onConnectError;

  bool get isConnected => _socket?.connected ?? false;

  String get _baseUrl =>
      dotenv.env['CHAT_SOCKET_URL'] ??
      dotenv.env['BASE_URL'] ??
      dotenv.env['API_BASE_URL'] ??
      '';

  /// 소켓을 연결하고, 연결 성공 시 groupId로 chat.join을 emit합니다.
  ///
  /// [accessToken]: Bearer 토큰
  /// [groupId]: 입장할 그룹 ID
  void connect({required String accessToken, required String groupId}) {
    final String baseUrl = _baseUrl;
    if (baseUrl.isEmpty) {
      debugPrint('[Chat Socket] BASE_URL 환경 변수가 없습니다.');
      onConnectError?.call('BASE_URL 환경 변수가 없습니다.');
      return;
    }

    // 이미 같은 그룹에 연결된 경우 중복 연결 방지
    if (isConnected &&
        _currentGroupId == groupId &&
        _accessToken == accessToken) {
      debugPrint('[Chat Socket] 이미 같은 그룹($groupId)에 연결되어 있습니다.');
      return;
    }

    _disposeSocket();
    _accessToken = accessToken;
    _currentGroupId = groupId;

    try {
      final _ChatSocketEndpoint endpoint = _buildChatEndpoint(baseUrl);
      final String token = _normalizeBearerToken(accessToken);
      debugPrint('[Chat Socket] 최종 연결 URL: ${endpoint.namespaceUrl}');
      debugPrint('[Chat Socket] Resolved port: ${endpoint.port}');
      debugPrint('[Chat Socket] Host option: ${endpoint.originUrl}');
      debugPrint('[Chat Socket] Engine.IO path: $_socketEnginePath');
      debugPrint('[Chat Socket] Runtime origin: ${_runtimeOrigin()}');
      debugPrint(
        '[Chat Socket] 연결 groupId: $groupId (uuid=${_isUuid(groupId)})',
      );

      final Map<String, dynamic> socketOptions =
          sio.OptionBuilder()
              // nginx는 /socket.io/ 경로를 WebSocket upgrade 처리해야 합니다.
              .setTransports(['websocket'])
              .setPath(_socketEnginePath)
              .enableForceNew()
              .disableMultiplex()
              .disableReconnection()
              .disableAutoConnect()
              // Socket.IO handshake 인증은 HTTP 헤더가 아니라 auth.token으로 전달합니다.
              .setAuth({'token': token})
              .build()
            ..addAll({
              // socket_io_client가 기본 포트를 0으로 넘기는 경우가 있어
              // 실제 WebSocket transport 생성 옵션에도 포트를 직접 고정합니다.
              'transportOptions': {
                'websocket': {
                  'hostname': endpoint.host,
                  'port': endpoint.port,
                  'secure': endpoint.secure,
                  'path': _socketEnginePath,
                },
              },
            });

      debugPrint(
        '[Chat Socket] Socket.IO options: ${_maskToken(socketOptions)}',
      );
      sio.cache.clear();
      _socket = sio.io(endpoint.namespaceUrl, socketOptions);

      _registerEvents(groupId);
      _socket!.connect();
    } catch (e) {
      debugPrint('[Chat Socket] 초기화 실패: $e');
      onConnectError?.call('채팅 소켓 초기화에 실패했습니다.');
    }
  }

  void _registerEvents(String groupId) {
    _socket!
      ..onConnect((_) {
        // 연결 성공 → 즉시 chat.join emit
        debugPrint('[Chat Socket] 연결 성공 → chat.join 전송: $groupId');
        _socket!.emit('chat.join', {'groupId': groupId});
      })
      ..onDisconnect((reason) {
        debugPrint('[Chat Socket] 연결 해제: $reason');
      })
      ..onConnectError((data) {
        // connect_error: accessToken 만료/누락, 허용되지 않는 origin 등
        final String msg = _extractErrorMessage(data);
        debugPrint('[Chat Socket] connect_error payload: $data');
        debugPrint('[Chat Socket] connect_error: $msg');
        onConnectError?.call(msg);
      })
      ..on('chat.joined', (data) {
        final Map<String, dynamic> json = _toMap(data);
        final String resolvedGroupId = json['groupId'] as String? ?? '';
        final String nickname = json['nickname'] as String? ?? '';
        debugPrint('[Chat Socket] chat.joined: nickname=$nickname');
        onJoined?.call(resolvedGroupId, nickname);
      })
      ..on('chat.history', (data) {
        final List<dynamic> list = data is List ? data : [];
        final List<ChatSocketMessage> messages = list
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (item) =>
                  ChatSocketMessage.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
        debugPrint('[Chat Socket] chat.history: ${messages.length}개 수신');
        onHistory?.call(messages);
      })
      ..on('chat.message', (data) {
        final Map<String, dynamic> json = _toMap(data);
        final ChatSocketMessage msg = ChatSocketMessage.fromJson(json);
        debugPrint(
          '[Chat Socket] chat.message: ${msg.nickname}: ${msg.content}',
        );
        onMessage?.call(msg);
      })
      ..on('chat.error', (data) {
        // chat.join, chat.send 실패 시 수신 (권한 없음, rate limit 등)
        final Map<String, dynamic> json = _toMap(data);
        final String msg = json['message'] as String? ?? '채팅 오류가 발생했습니다.';
        final String event = json['event'] as String? ?? 'unknown';
        debugPrint('[Chat Socket] chat.error payload: $json');
        debugPrint('[Chat Socket] chat.error (event=$event): $msg');
        onChatError?.call(msg);
      })
      ..onError((data) {
        final String msg = _extractErrorMessage(data);
        debugPrint('[Chat Socket] socket error payload: $data');
        debugPrint('[Chat Socket] socket error: $msg');
      });
  }

  /// 메시지 전송. { content } 만 보냅니다 (서버 스펙 기준).
  void sendMessage(String content) {
    if (!isConnected) {
      debugPrint('[Chat Socket] 소켓이 연결되어 있지 않아 메시지를 보낼 수 없습니다.');
      return;
    }
    if (content.trim().isEmpty) return;

    debugPrint('[Chat Socket] chat.send: $content');
    _socket!.emit('chat.send', {'content': content});
  }

  /// 다른 그룹으로 이동할 때 호출합니다.
  /// 기존 연결을 해제하고 새 groupId로 재연결합니다.
  void switchGroup(String newGroupId) {
    if (_accessToken == null) return;
    debugPrint('[Chat Socket] 그룹 전환: $_currentGroupId → $newGroupId');
    connect(accessToken: _accessToken!, groupId: newGroupId);
  }

  /// 화면 이탈 시 콜백 분리 후 소켓 disconnect.
  /// (서버 스펙: 그룹 화면 나가면 disconnect 필요)
  void leaveGroup() {
    debugPrint('[Chat Socket] 그룹 이탈 - disconnect');
    detachCallbacks();
    _socket?.disconnect();
    _currentGroupId = null;
  }

  /// 콜백만 분리합니다. 소켓 연결은 유지됩니다.
  void detachCallbacks() {
    onMessage = null;
    onHistory = null;
    onJoined = null;
    onChatError = null;
    onConnectError = null;
  }

  /// 앱 종료 / 로그아웃 시 전체 정리
  void dispose() {
    debugPrint('[Chat Socket] 전체 정리');
    _disposeSocket();
    _currentGroupId = null;
    _accessToken = null;
    detachCallbacks();
  }

  void _disposeSocket() {
    _socket?.io.close();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  String _extractErrorMessage(dynamic data) {
    if (data is String) return data;
    if (data is Map) {
      return (data['message'] as String?) ??
          (data['error'] as String?) ??
          data.toString();
    }
    return data?.toString() ?? '알 수 없는 오류';
  }

  _ChatSocketEndpoint _buildChatEndpoint(String rawUrl) {
    final Uri uri = Uri.parse(rawUrl.trim());

    if (!uri.hasScheme || uri.host.isEmpty) {
      throw FormatException('잘못된 채팅 서버 URL입니다: $rawUrl');
    }

    final bool secure = uri.scheme == 'https' || uri.scheme == 'wss';
    final String socketScheme = secure ? 'https' : 'http';
    final int port = _resolvePort(uri, secure: secure);
    final String formattedHost = _formatHost(uri.host);
    final String originUrl = '$socketScheme://$formattedHost:$port';

    return _ChatSocketEndpoint(
      namespaceUrl: '$originUrl$_socketNamespace',
      originUrl: originUrl,
      host: uri.host,
      port: port,
      secure: secure,
    );
  }

  String _formatHost(String host) {
    return host.contains(':') && !host.startsWith('[') ? '[$host]' : host;
  }

  int _resolvePort(Uri uri, {required bool secure}) {
    final int defaultPort = secure ? 443 : 80;
    final Match? match = RegExp(r':(\d+)$').firstMatch(uri.authority);
    if (match == null) return defaultPort;

    return int.tryParse(match.group(1)!) ?? defaultPort;
  }

  String _normalizeBearerToken(String token) {
    final String trimmedToken = token.trim();
    const String bearerPrefix = 'Bearer ';

    if (trimmedToken.startsWith(bearerPrefix)) {
      return trimmedToken.substring(bearerPrefix.length).trim();
    }

    return trimmedToken;
  }

  Map<String, dynamic> _maskToken(Map<String, dynamic> options) {
    final Map<String, dynamic> masked = Map<String, dynamic>.from(options);
    final Object? auth = masked['auth'];

    if (auth is Map) {
      masked['auth'] = {...auth, if (auth.containsKey('token')) 'token': '***'};
    }

    return masked;
  }

  bool _isUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value.trim());
  }

  String _runtimeOrigin() {
    if (!kIsWeb) {
      return 'native app (browser Origin header 없음)';
    }

    try {
      return Uri.base.origin;
    } catch (_) {
      return Uri.base.toString();
    }
  }
}

class _ChatSocketEndpoint {
  const _ChatSocketEndpoint({
    required this.namespaceUrl,
    required this.originUrl,
    required this.host,
    required this.port,
    required this.secure,
  });

  final String namespaceUrl;
  final String originUrl;
  final String host;
  final int port;
  final bool secure;
}
