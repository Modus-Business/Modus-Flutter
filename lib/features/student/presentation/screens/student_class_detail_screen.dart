import 'package:flutter/material.dart';

import '../../domain/entities/student_class.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/student_repository_registry.dart';
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

  @override
  void initState() {
    super.initState();
    _studentClass = widget.studentClass;
    _loadGroup();
  }

  @override
  void dispose() {
    _draftController.dispose();
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
    } catch (_) {
      // 모둠 조회 실패 시 기존 상세 화면 상태를 유지합니다.
    }
  }

  Future<void> _showSubmissionDialog() async {
    final bool? submitted = await showDialog<bool>(
      context: context,
      builder: (_) => const SubmissionDialog(),
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('과제 제출 연동은 다음 단계에서 연결됩니다.')));
    }
  }

  void _handleSend() {
    final String draft = _draftController.text.trim();
    if (draft.isEmpty) {
      return;
    }

    setState(() {
      // 저장 연동 전 단계라서 화면 상태만 로컬에서 갱신합니다.
      if (_editingMessageId != null) {
        _studentClass = _studentClass.copyWith(
          chatMessages: _studentClass.chatMessages
              .map(
                (StudentChatMessage message) => message.id == _editingMessageId
                    ? message.copyWith(message: draft, sentAt: '방금 전')
                    : message,
              )
              .toList(),
        );
      } else {
        _studentClass = _studentClass.copyWith(
          chatMessages: [
            ..._studentClass.chatMessages,
            StudentChatMessage(
              id: 'm${DateTime.now().millisecondsSinceEpoch}',
              author: '나',
              message: draft,
              sentAt: '방금 전',
              isMine: true,
            ),
          ],
        );
      }

      _editingMessageId = null;
      _draftController.clear();
    });
  }

  void _handleEdit(StudentChatMessage message) {
    setState(() {
      _editingMessageId = message.id;
      _draftController.text = message.message;
    });
  }

  void _handleDelete(StudentChatMessage message) {
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
          final Widget chatArea = GroupChatPanel(
            groupAssigned: _studentClass.groupAssigned,
            messages: _studentClass.chatMessages,
            controller: _draftController,
            editingMessageId: _editingMessageId,
            onChanged: (_) {
              setState(() {});
            },
            onSend: _handleSend,
            onEdit: _handleEdit,
            onDelete: _handleDelete,
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
