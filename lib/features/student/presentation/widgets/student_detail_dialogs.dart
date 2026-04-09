import 'package:flutter/material.dart';

import '../../domain/entities/student_class.dart';

class AssignmentListDialog extends StatelessWidget {
  const AssignmentListDialog({super.key, required this.assignments});

  final List<StudentAssignment> assignments;

  @override
  Widget build(BuildContext context) {
    return _SheetDialog(
      title: '모둠 과제',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List<Widget>.generate(assignments.length, (int index) {
            final StudentAssignment item = assignments[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == assignments.length - 1 ? 0 : 12,
              ),
              child: _ModalCard(
                title: item.title,
                description: '마감 ${item.dueDateLabel}',
                footer: item.status.label,
              ),
            );
          }),
          const SizedBox(height: 20),
          _DialogButton(
            label: '닫기',
            isFilled: false,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class AnnouncementListDialog extends StatelessWidget {
  const AnnouncementListDialog({super.key, required this.announcements});

  final List<StudentAnnouncement> announcements;

  @override
  Widget build(BuildContext context) {
    return _SheetDialog(
      title: '공지',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List<Widget>.generate(announcements.length, (int index) {
            final StudentAnnouncement item = announcements[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == announcements.length - 1 ? 0 : 12,
              ),
              child: _ModalCard(
                title: item.title,
                description: item.summary,
                footer: item.dateLabel,
              ),
            );
          }),
          const SizedBox(height: 20),
          _DialogButton(
            label: '닫기',
            isFilled: false,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class SubmissionDialog extends StatefulWidget {
  const SubmissionDialog({super.key});

  @override
  State<SubmissionDialog> createState() => _SubmissionDialogState();
}

class _SubmissionDialogState extends State<SubmissionDialog> {
  final TextEditingController _linkController = TextEditingController();
  bool _attachMockFile = false;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit =
        _attachMockFile || _linkController.text.trim().isNotEmpty;

    return _SheetDialog(
      title: '과제 제출',
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogButton(
              label: _attachMockFile ? '파일 선택됨' : '파일 업로드',
              isFilled: false,
              icon: Icons.attach_file_rounded,
              onTap: () {
                setState(() {
                  _attachMockFile = !_attachMockFile;
                });
              },
            ),
            if (_attachMockFile) ...[
              const SizedBox(height: 10),
              const Text(
                '업로드 대기 파일: product-notes.pdf',
                style: TextStyle(
                  color: Color(0xFF7D87A0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                labelText: '링크 입력',
                hintText: 'https://...',
                filled: true,
                fillColor: const Color(0xFFF5F7FF),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFFD9E1F3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFF6A80F2)),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            _DialogButton(
              label: '제출하기',
              isFilled: true,
              onTap: canSubmit ? () => Navigator.of(context).pop(true) : null,
            ),
            const SizedBox(height: 12),
            _DialogButton(
              label: '닫기',
              isFilled: false,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetDialog extends StatelessWidget {
  const _SheetDialog({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 390),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x213C4C8B),
              blurRadius: 34,
              offset: Offset(0, 22),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF27334B),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF7D87A0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalCard extends StatelessWidget {
  const _ModalCard({
    required this.title,
    required this.description,
    required this.footer,
  });

  final String title;
  final String description;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9E1F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF27334B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Color(0xFF7D87A0),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            footer,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8B95B0),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.isFilled,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isFilled;
  final VoidCallback? onTap;
  final IconData? icon;

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
                    side: const BorderSide(color: Color(0xFFD9E1F3)),
                    backgroundColor: Colors.white,
                  ))
            .copyWith(
              minimumSize: const WidgetStatePropertyAll(Size.fromHeight(58)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );

    final Widget child = icon == null
        ? Text(
            label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      child: isFilled
          ? ElevatedButton(onPressed: onTap, style: style, child: child)
          : OutlinedButton(onPressed: onTap, style: style, child: child),
    );
  }
}
