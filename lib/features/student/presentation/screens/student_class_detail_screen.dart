import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/services/chat_socket_service.dart';
import '../../domain/entities/chat_intervention_advice.dart';
import '../../domain/entities/chat_message_advice.dart';
import '../../domain/entities/student_class.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/entities/student_upload_file.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/student_repository_registry.dart';
import '../notifiers/chat_notifier.dart';
import '../widgets/group_chat_panel.dart';
import '../widgets/group_members_card.dart';
import '../widgets/student_detail_dialogs.dart';
import '../widgets/student_empty_group_state.dart';
import '../widgets/student_shell.dart';

enum _MessageAdviceAction { sendOriginal, applyRewrite, cancel }

const List<String> _messageAdviceRiskKeywords = <String>[
  '짜증',
  '별로',
  '싫어',
  '답답',
  '최악',
  '대충',
  '뭐함',
  '왜 안',
  '안 한',
  '안함',
  '못하',
  '이상해',
  '잘못',
  '탓',
  '문제',
  '그냥 하지마',
];

const List<String> _messageAdviceAlwaysCheckKeywords = <String>[
  '개같',
  '개빡',
  '개새',
  '개소리',
  '꺼져',
  '닥쳐',
  '멍청',
  '바보',
  '미친',
  '병신',
  '시발',
  '씨발',
  'ㅅㅂ',
  'ㅂㅅ',
  'ㅁㅊ',
  '존나',
  '좆',
  '지랄',
  '한심',
];

const List<String> _messageAdviceSafeShortMessages = <String>[
  '네',
  '넵',
  '예',
  '응',
  '아니',
  '아니요',
  '좋아요',
  '좋습니다',
  '감사합니다',
  '고마워요',
  '확인',
  '확인했습니다',
  '제가 할게요',
  '제가 할게요.',
  '올렸어요',
  '했습니다',
];

class StudentClassDetailScreen extends StatefulWidget {
  const StudentClassDetailScreen({
    super.key,
    required this.studentClass,
    required this.profile,
    required this.onClassesTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  final StudentClass studentClass;
  final StudentProfile profile;
  final VoidCallback onClassesTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  @override
  State<StudentClassDetailScreen> createState() =>
      _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  late StudentClass _studentClass;
  final TextEditingController _draftController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _isMemberCardOpen = false;
  bool _isCheckingMessageAdvice = false;
  bool _isCheckingInterventionAdvice = false;
  int _lastChatMessageCount = 0;
  String? _autoShownNicknameGroupId;
  String? _editingMessageId;

  // ChatNotifier: ChangeNotifier 기반 채팅 상태 관리
  late final ChatNotifier _chatNotifier = ChatNotifier(
    service: ChatSocketService.instance,
  );

  @override
  void initState() {
    super.initState();
    _studentClass = widget.studentClass;
    _chatNotifier.addListener(_onChatNotifierChanged);
    _chatNotifier.onInterventionCheckDue = (_) {
      unawaited(_handleInterventionAdviceRequest(isAutomatic: true));
    };
    _loadGroup();
    // 소켓 연결은 _loadGroup()에서 groupId 확보 후 시작
  }

  @override
  void dispose() {
    _chatNotifier.onInterventionCheckDue = null;
    _chatNotifier.removeListener(_onChatNotifierChanged);
    _draftController.dispose();
    _chatScrollController.dispose();
    // 서버 스펙: 그룹 화면 이탈 시 disconnect
    _chatNotifier.leaveGroup();
    _chatNotifier.dispose();
    super.dispose();
  }

  void _showAssignments() {
    showDialog<void>(
      context: context,
      builder: (_) =>
          AssignmentListDialog(assignments: _studentClass.assignments),
    );
  }

  Future<void> _showAnnouncements() async {
    final StudentRepository? repository = StudentRepositoryRegistry.repository;
    final String? groupId = _studentClass.group?.id;

    if (repository != null && groupId != null && groupId.isNotEmpty) {
      try {
        final List<StudentAnnouncement> announcements = await repository
            .fetchGroupNotices(groupId);

        if (!mounted) {
          return;
        }

        setState(() {
          _studentClass = _studentClass.copyWith(announcements: announcements);
        });
      } catch (_) {
        // 공지 조회 실패 시 기존 공지 목록을 그대로 보여줍니다.
      }
    }

    if (!mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) =>
          AnnouncementListDialog(announcements: _studentClass.announcements),
    );
  }

  Future<void> _showGroupNickname() async {
    final String? groupId = _studentClass.group?.id;

    if (groupId == null || groupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모둠 배정 후에 닉네임을 조회할 수 있습니다.')),
      );
      return;
    }

    final StudentRepository? repository = StudentRepositoryRegistry.repository;
    if (repository == null) return;

    await _showGroupNicknameDialog(
      repository: repository,
      groupId: groupId,
      showError: true,
    );
  }

  Future<void> _showGroupNicknameDialog({
    required StudentRepository repository,
    required String groupId,
    required bool showError,
  }) async {
    try {
      final StudentGroupNickname nicknameData = await repository
          .fetchGroupNickname(groupId);

      if (!mounted) return;

      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            nicknameData.nickname,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF27334B),
            ),
          ),
          content: Text(
            nicknameData.reason,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF7D87A0),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      if (showError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('모둠 닉네임을 불러오지 못했습니다.')));
      }
    }
  }

  void _showGroupNicknameDialogOnce(String groupId) {
    if (_autoShownNicknameGroupId == groupId) {
      return;
    }

    final StudentRepository? repository = StudentRepositoryRegistry.repository;
    if (repository == null) {
      return;
    }

    _autoShownNicknameGroupId = groupId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        _showGroupNicknameDialog(
          repository: repository,
          groupId: groupId,
          showError: false,
        ),
      );
    });
  }

  Future<void> _loadGroup() async {
    final StudentRepository? repository = StudentRepositoryRegistry.repository;

    if (repository == null) {
      return;
    }

    try {
      final StudentClass studentClass = await repository.fetchClassGroup(
        _studentClass.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _studentClass = studentClass;
      });

      // 모둠 정보 로드 후 ChatNotifier를 통해 소켓 연결
      final String? groupId = studentClass.group?.id;
      if (groupId != null && groupId.isNotEmpty) {
        _chatNotifier.connect(groupId);
        _showGroupNicknameDialogOnce(groupId);
      }
    } catch (_) {
      // 모둠 조회 실패 시 기존 상태를 유지합니다.
    }
  }

  void _onChatNotifierChanged() {
    final int messageCount = _chatNotifier.messages.length;
    if (messageCount != _lastChatMessageCount) {
      final bool isInitialHistory =
          _lastChatMessageCount == 0 && messageCount > 0;
      _lastChatMessageCount = messageCount;
      _scrollChatToBottom(
        animated: !isInitialHistory,
        retryCount: isInitialHistory ? 8 : 4,
      );
    }

    final String? error = _chatNotifier.errorMessage;
    if (error != null && mounted) {
      // 프레임 빌드 완료 후 SnackBar를 띄워 레이아웃 충돌 방지
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        _chatNotifier.clearError();
      });
    }
  }

  void _scrollChatToBottom({bool animated = true, int retryCount = 4}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (!_chatScrollController.hasClients) {
        _retryScrollChatToBottom(animated: animated, retryCount: retryCount);
        return;
      }

      final double targetOffset =
          _chatScrollController.position.maxScrollExtent;
      if (targetOffset <= 0 && retryCount > 0) {
        _retryScrollChatToBottom(animated: animated, retryCount: retryCount);
        return;
      }

      if (animated) {
        _chatScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      } else {
        _chatScrollController.jumpTo(targetOffset);
      }
    });
  }

  void _retryScrollChatToBottom({
    required bool animated,
    required int retryCount,
  }) {
    if (retryCount <= 0) {
      return;
    }

    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (!mounted) {
        return;
      }

      _scrollChatToBottom(animated: animated, retryCount: retryCount - 1);
    });
  }

  Future<void> _showSubmissionDialog() async {
    final String? groupId = _studentClass.group?.id;

    if (groupId == null || groupId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모둠 배정 후 과제를 제출할 수 있습니다.')));
      return;
    }

    final bool? submitted = await showDialog<bool>(
      context: context,
      builder: (_) => SubmissionDialog(
        groupId: groupId,
        onUploadFile: (StudentUploadFile file) async {
          final StudentRepository? repository =
              StudentRepositoryRegistry.repository;

          if (repository == null) {
            throw StateError('학생 저장소가 연결되지 않았습니다.');
          }

          return repository.uploadAssignmentFile(file);
        },
        onSubmit: ({required String fileUrl, required String link}) async {
          final StudentRepository? repository =
              StudentRepositoryRegistry.repository;
          final String? groupId = _studentClass.group?.id;

          if (repository == null) {
            throw StateError('학생 저장소가 연결되지 않았습니다.');
          }

          if (groupId == null || groupId.isEmpty) {
            throw StateError('모둠 정보가 없어 과제를 제출할 수 없습니다.');
          }

          await repository.submitAssignment(
            StudentSubmissionRequest(
              groupId: groupId,
              fileUrl: fileUrl,
              link: link,
            ),
          );
        },
      ),
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('과제를 제출했습니다.')));
      // 제출 성공 후 데이터를 다시 로드하여 '내 제출물' 영역을 갱신합니다.
      _loadGroup();
    }
  }

  void _handleSend() {
    unawaited(_handleSendWithAdvice());
  }

  Future<void> _handleSendWithAdvice() async {
    if (_isCheckingMessageAdvice) return;

    final String draft = _draftController.text.trim();
    if (draft.isEmpty) return;

    final String? groupId = _studentClass.group?.id;
    if (groupId == null || groupId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모둠 배정 후 메시지를 보낼 수 있습니다.')));
      return;
    }

    if (!_shouldRequestMessageAdvice(draft)) {
      _sendCheckedMessage(draft);
      return;
    }

    final StudentRepository? repository = StudentRepositoryRegistry.repository;
    if (repository == null) {
      _sendCheckedMessage(draft);
      return;
    }

    final bool forceBlockOriginal = _hasAlwaysCheckKeyword(draft);
    StudentChatMessageAdvice advice;
    setState(() {
      _isCheckingMessageAdvice = true;
    });

    try {
      advice = await repository.requestChatMessageAdvice(
        groupId: groupId,
        content: draft,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isCheckingMessageAdvice = false;
      });
      if (forceBlockOriginal) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('메시지 표현을 확인하지 못했습니다. 문장을 수정한 뒤 다시 시도해주세요.'),
          ),
        );
        return;
      }
      _sendCheckedMessage(draft);
      return;
    }

    if (!mounted) return;

    setState(() {
      _isCheckingMessageAdvice = false;
    });

    // 서버가 skip/popup 여부를 결정하므로 클라이언트는 해당 플래그를 우선 따릅니다.
    if (advice.shouldSkip) {
      _sendCheckedMessage(draft);
      return;
    }

    final bool shouldShowAdviceDialog =
        forceBlockOriginal || advice.shouldBlock || advice.shouldShowPopup;
    if (!shouldShowAdviceDialog) {
      _sendCheckedMessage(draft);
      return;
    }

    final _MessageAdviceAction action = await _showMessageAdviceDialog(
      advice,
      forceBlockOriginal: forceBlockOriginal,
    );

    if (!mounted) return;

    switch (action) {
      case _MessageAdviceAction.sendOriginal:
        _sendCheckedMessage(draft);
        break;
      case _MessageAdviceAction.applyRewrite:
        _applySuggestedRewrite(advice.suggestedRewrite);
        break;
      case _MessageAdviceAction.cancel:
        break;
    }
  }

  bool _shouldRequestMessageAdvice(String content) {
    final String text = content.trim();
    if (text.isEmpty) {
      return false;
    }

    final String compactText = text.replaceAll(RegExp(r'\s+'), '');
    final String normalizedText = text.toLowerCase();
    if (_hasAlwaysCheckKeyword(text)) {
      return true;
    }

    if (_messageAdviceSafeShortMessages.any(
      (String message) => compactText == message.replaceAll(' ', ''),
    )) {
      return false;
    }

    if (text.length < 8) {
      return false;
    }

    if (text.length >= 80) {
      return true;
    }

    return _messageAdviceRiskKeywords.any(
      (String keyword) => normalizedText.contains(keyword.toLowerCase()),
    );
  }

  bool _hasAlwaysCheckKeyword(String content) {
    final String normalizedCompactText = content
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .toLowerCase();

    return _messageAdviceAlwaysCheckKeywords.any(
      (String keyword) => normalizedCompactText.contains(keyword.toLowerCase()),
    );
  }

  void _sendCheckedMessage(String content) {
    _draftController.clear();
    setState(() {}); // 전송 버튼 비활성화 즉시 반영

    // ChatNotifier를 통해 전송 (chat.send에 content만 포함 - 서버 스펙)
    _chatNotifier.sendMessage(content);
  }

  void _applySuggestedRewrite(String suggestedRewrite) {
    final String rewrite = suggestedRewrite.trim();
    if (rewrite.isEmpty) return;

    _draftController.value = TextEditingValue(
      text: rewrite,
      selection: TextSelection.collapsed(offset: rewrite.length),
    );
    setState(() {});
  }

  Future<_MessageAdviceAction> _showMessageAdviceDialog(
    StudentChatMessageAdvice advice, {
    required bool forceBlockOriginal,
  }) async {
    final String warning = advice.warning.trim();
    final String suggestedRewrite = advice.suggestedRewrite.trim();
    final bool hasSuggestedRewrite = suggestedRewrite.isNotEmpty;
    final bool canSendOriginal = !advice.shouldBlock && !forceBlockOriginal;

    final _MessageAdviceAction? action = await showDialog<_MessageAdviceAction>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AI 메시지 조언',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF586CE8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                advice.shouldBlock || forceBlockOriginal
                    ? '전송하기 전에 수정이 필요해요'
                    : '보내기 전에 확인해 주세요',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF27334B),
                  height: 1.25,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _messageRiskLevelLabel(advice),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF586CE8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAF0),
                  border: Border.all(color: const Color(0xFFFFE0A6)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  warning.isNotEmpty ? warning : 'AI가 메시지를 확인했어요.',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B4B18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                canSendOriginal
                    ? '원문을 보낼 수도 있지만, 표현을 조금 부드럽게 바꿔볼 수 있어요.'
                    : '이 문장은 바로 전송되지 않아요. 수정안을 적용하거나 닫고 다시 작성해 주세요.',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7D87A0),
                ),
              ),
              if (hasSuggestedRewrite) ...[
                const SizedBox(height: 16),
                const Text(
                  '추천 문장',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF596781),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FF),
                    border: Border.all(color: const Color(0xFFD9E1F3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    suggestedRewrite,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF27334B),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(_MessageAdviceAction.cancel),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7D87A0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(canSendOriginal ? '닫기' : '다시 쓸게요'),
            ),
            if (hasSuggestedRewrite)
              FilledButton(
                onPressed: () => Navigator.of(
                  context,
                ).pop(_MessageAdviceAction.applyRewrite),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF586CE8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('수정안 적용'),
              ),
            if (canSendOriginal)
              TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).pop(_MessageAdviceAction.sendOriginal),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF586CE8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('원문 전송'),
              ),
          ],
        );
      },
    );

    return action ?? _MessageAdviceAction.cancel;
  }

  String _messageRiskLevelLabel(StudentChatMessageAdvice advice) {
    if (advice.hasRiskLevelLabel) {
      return advice.riskLevelLabel.trim();
    }

    switch (advice.riskLevel) {
      case ChatMessageRiskLevel.low:
        return '위험도 낮음';
      case ChatMessageRiskLevel.medium:
        return '주의 필요';
      case ChatMessageRiskLevel.high:
        return '전송 주의';
      case ChatMessageRiskLevel.unknown:
        return '표현 점검';
    }
  }

  void _handleInterventionAdvice() {
    unawaited(_handleInterventionAdviceRequest());
  }

  Future<void> _handleInterventionAdviceRequest({
    bool isAutomatic = false,
  }) async {
    if (_isCheckingInterventionAdvice) return;

    final String? groupId = _studentClass.group?.id;
    if (groupId == null || groupId.isEmpty) {
      if (!isAutomatic) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모둠 배정 후 AI 조언을 받을 수 있습니다.')),
        );
      }
      return;
    }

    final StudentRepository? repository = StudentRepositoryRegistry.repository;
    if (repository == null) {
      if (!isAutomatic) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('그룹 대화 AI 조언 기능이 연결되지 않았습니다.')),
        );
      }
      return;
    }

    setState(() {
      _isCheckingInterventionAdvice = true;
    });

    StudentChatInterventionAdvice advice;
    try {
      advice = await repository.requestChatInterventionAdvice(groupId);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isCheckingInterventionAdvice = false;
      });
      if (!isAutomatic) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('그룹 대화 AI 조언을 확인하지 못했습니다.')),
        );
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _isCheckingInterventionAdvice = false;
    });

    if (isAutomatic && !advice.interventionNeeded) {
      return;
    }

    final bool applySuggestedMessage = await _showInterventionAdviceDialog(
      advice,
    );

    if (!mounted || !applySuggestedMessage) return;

    _applySuggestedRewrite(advice.suggestedMessage);
  }

  Future<bool> _showInterventionAdviceDialog(
    StudentChatInterventionAdvice advice,
  ) async {
    final String reason = advice.reason.trim();
    final String suggestedMessage = advice.suggestedMessage.trim();
    final bool hasSuggestedMessage = suggestedMessage.isNotEmpty;

    final bool? shouldApply = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AI 대화 조언',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF586CE8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                advice.interventionNeeded ? '대화를 이어갈 제안이 있어요' : '지금은 괜찮아요',
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF27334B),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (advice.interventionNeeded)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _interventionTypeLabel(advice.interventionType),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF586CE8),
                    ),
                  ),
                ),
              if (advice.interventionNeeded) const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  border: Border.all(color: const Color(0xFFD9E1F3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reason.isNotEmpty ? reason : '최근 대화 흐름을 더 지켜봐도 괜찮아요.',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF596781),
                  ),
                ),
              ),
              if (hasSuggestedMessage) ...[
                const SizedBox(height: 16),
                const Text(
                  '추천 문장',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF596781),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FF),
                    border: Border.all(color: const Color(0xFFD9E1F3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    suggestedMessage,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF27334B),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7D87A0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('닫기'),
            ),
            if (hasSuggestedMessage)
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF586CE8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('입력창에 넣기'),
              ),
          ],
        );
      },
    );

    return shouldApply ?? false;
  }

  String _interventionTypeLabel(ChatInterventionType type) {
    switch (type) {
      case ChatInterventionType.participation:
        return '참여 유도';
      case ChatInterventionType.deepening:
        return '논의 심화';
      case ChatInterventionType.deepQuestion:
        return '심화 질문';
      case ChatInterventionType.unknown:
        return '대화 조언';
    }
  }

  void _handleEdit(StudentChatMessage message) {
    // TODO: 서버가 메시지 수정 이벤트를 지원하면 소켓으로 연동
    setState(() {
      _editingMessageId = message.id;
      _draftController.text = message.message;
    });
  }

  void _handleDelete(StudentChatMessage message) {
    // TODO: 서버가 메시지 삭제 이벤트를 지원하면 소켓으로 연동
    setState(() {
      _studentClass = _studentClass.copyWith(
        chatMessages: _studentClass.chatMessages
            .where((StudentChatMessage item) => item.id != message.id)
            .toList(),
      );

      if (_editingMessageId == message.id) {
        _editingMessageId = null;
        _draftController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StudentShell(
      selectedItem: StudentNavItem.classes,
      onClassesTap: widget.onClassesTap,
      onSettingsTap: widget.onSettingsTap,
      onLogoutTap: widget.onLogoutTap,
      showProfileAvatar: false,
      appBarTitle: _DetailBreadcrumb(
        title: _studentClass.title,
        subtitle: _studentClass.groupAssigned
            ? _studentClass.groupName ?? ''
            : '모둠 배정 전',
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool useTwoColumns = constraints.maxWidth >= 980;
          final Widget chatArea = ListenableBuilder(
            listenable: _chatNotifier,
            builder: (BuildContext ctx, _) {
              return GroupChatPanel(
                groupAssigned: _studentClass.groupAssigned,
                messages: _chatNotifier.messages,
                controller: _draftController,
                scrollController: _chatScrollController,
                editingMessageId: _editingMessageId,
                isCheckingAdvice: _isCheckingMessageAdvice,
                isCheckingInterventionAdvice: _isCheckingInterventionAdvice,
                onChanged: (_) => setState(() {}),
                onSend: _handleSend,
                onInterventionAdvice: _handleInterventionAdvice,
                onEdit: _handleEdit,
                onDelete: _handleDelete,
              );
            },
          );
          final Widget membersArea = GroupMembersCard(
            groupAssigned: _studentClass.groupAssigned,
            isOpen: _isMemberCardOpen,
            onToggle: () {
              setState(() {
                _isMemberCardOpen = !_isMemberCardOpen;
              });
            },
            group: _studentClass.group,
            classCode: _studentClass.classCode,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: useTwoColumns ? 1160 : 430,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 14, 0, 12),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _ActionButton(
                            label: '공지',
                            icon: Icons.notifications_none_rounded,
                            isFilled: false,
                            onTap: _showAnnouncements,
                          ),
                          _ActionButton(
                            label: '모둠 조회',
                            icon: Icons.search_rounded,
                            isFilled: false,
                            onTap: _showGroupNickname,
                          ),
                          _ActionButton(
                            label: '과제 제출',
                            icon: Icons.file_present_outlined,
                            isFilled: true,
                            onTap: _showSubmissionDialog,
                          ),
                          TextButton(
                            onPressed: _showAssignments,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6E82F6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              '모둠 과제',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_studentClass.groupAssigned)
                      useTwoColumns
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: chatArea),
                                const SizedBox(width: 16),
                                Expanded(flex: 3, child: membersArea),
                              ],
                            )
                          : Column(
                              children: [
                                chatArea,
                                const SizedBox(height: 12),
                                membersArea,
                              ],
                            )
                    else ...[
                      const StudentEmptyGroupState(),
                      const SizedBox(height: 12),
                      membersArea,
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailBreadcrumb extends StatelessWidget {
  const _DetailBreadcrumb({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF7C88A6),
          size: 20,
        ),
        Expanded(
          child: Text(
            '$title / $subtitle',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF27334B),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isFilled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isFilled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        (isFilled
                ? ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A80F2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  )
                : OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF27334B),
                    side: const BorderSide(color: Color(0xFFD6DEF4)),
                    backgroundColor: Colors.white,
                  ))
            .copyWith(
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );

    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );

    return isFilled
        ? ElevatedButton(onPressed: onTap, style: style, child: child)
        : OutlinedButton(onPressed: onTap, style: style, child: child);
  }
}
