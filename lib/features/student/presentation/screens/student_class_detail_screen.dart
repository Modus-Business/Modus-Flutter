import 'package:flutter/material.dart';

import '../../data/services/chat_socket_service.dart';
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
  bool _isMemberCardOpen = false;
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
    _loadGroup();
    // 소켓 연결은 _loadGroup()에서 groupId 확보 후 시작
  }

  @override
  void dispose() {
    _chatNotifier.removeListener(_onChatNotifierChanged);
    _draftController.dispose();
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
      }
    } catch (_) {
      // 모둠 조회 실패 시 기존 상태를 유지합니다.
    }
  }

  void _onChatNotifierChanged() {
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
    final String draft = _draftController.text.trim();
    if (draft.isEmpty) return;

    _draftController.clear();
    setState(() {}); // 전송 버튼 비활성화 즉시 반영

    // ChatNotifier를 통해 전송 (chat.send에 content만 포함 - 서버 스펙)
    _chatNotifier.sendMessage(draft);
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
                editingMessageId: _editingMessageId,
                onChanged: (_) => setState(() {}),
                onSend: _handleSend,
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
