import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../domain/entities/student_class.dart';
import '../../domain/entities/student_upload_file.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/student_repository_registry.dart';

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
          if (assignments.isEmpty)
            const _ModalCard(
              title: '등록된 과제가 없습니다',
              description: '아직 등록된 과제가 없습니다.',
              footer: '과제 등록 후 이곳에서 확인할 수 있습니다.',
            )
          else
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
          if (announcements.isEmpty)
            const _ModalCard(
              title: '등록된 공지가 없습니다',
              description: '아직 등록된 공지가 없습니다.',
              footer: '공지 등록 후 이곳에서 확인할 수 있습니다.',
            )
          else
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
  const SubmissionDialog({
    super.key,
    required this.groupId,
    this.onUploadFile,
    this.onSubmit,
  });

  final String groupId;
  final Future<StudentPresignedUpload> Function(StudentUploadFile file)?
  onUploadFile;
  final Future<void> Function({required String fileUrl, required String link})?
  onSubmit;

  @override
  State<SubmissionDialog> createState() => _SubmissionDialogState();
}

class _SubmissionDialogState extends State<SubmissionDialog> {
  final TextEditingController _linkController = TextEditingController();
  StudentUploadFile? _selectedFile;
  StudentSubmission? _existingSubmission;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchSubmission();
  }

  Future<void> _fetchSubmission() async {
    final StudentRepository? repository = StudentRepositoryRegistry.repository;

    if (repository == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final StudentSubmission? submission = await repository.fetchMySubmission(
        widget.groupId,
      );
      if (mounted) {
        setState(() {
          _existingSubmission = submission;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _extractFileName(String url) {
    if (url.isEmpty) return '';
    try {
      String fileName = Uri.parse(url).pathSegments.last;
      fileName = Uri.decodeComponent(fileName);

      // S3 업로드 시 붙는 'UUID-timestamp-random-' 형태의 접두사 제거 정규식
      final RegExp prefixExp = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-\d+-\d+-',
      );
      if (prefixExp.hasMatch(fileName)) {
        fileName = fileName.replaceFirst(prefixExp, '');
      }
      return fileName;
    } catch (_) {
      return url;
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _SheetDialog(
        title: '조회 중...',
        child: SizedBox(
          height: 150,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF6A80F2)),
          ),
        ),
      );
    }

    if (_existingSubmission != null) {
      final StudentSubmission sub = _existingSubmission!;
      return _SheetDialog(
        title: '내 제출 확인',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '제출이 완료된 과제입니다.',
              style: TextStyle(
                color: Color(0xFF7D87A0),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            if (sub.fileUrl.isNotEmpty) ...[
              const Text(
                '첨부 파일',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF8B95B0),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_file_rounded,
                      size: 20,
                      color: Color(0xFF6A80F2),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _extractFileName(sub.fileUrl),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF27334B),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            if (sub.link.isNotEmpty) ...[
              const Text(
                '제출 링크',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF8B95B0),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sub.link,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5D76E8),
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 18),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '제출 일자',
                    style: TextStyle(color: Color(0xFF7D87A0), fontSize: 14),
                  ),
                  Text(
                    sub.submittedAt,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF27334B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _DialogButton(
              label: '확인',
              isFilled: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }

    final bool hasSelectedFile = _selectedFile != null;
    final bool canSubmit =
        !_isSubmitting &&
        (hasSelectedFile || _linkController.text.trim().isNotEmpty);

    return _SheetDialog(
      title: '과제 제출',
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogButton(
              label: hasSelectedFile ? '파일 다시 선택' : '파일 선택',
              isFilled: false,
              icon: Icons.attach_file_rounded,
              onTap: _isSubmitting ? null : _handleFileSelectTap,
            ),
            if (hasSelectedFile) ...[
              const SizedBox(height: 10),
              Text(
                '첨부된 파일: ${_selectedFile!.fileName}',
                style: const TextStyle(
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
              label: _isSubmitting ? '제출 중' : '제출하기',
              isFilled: true,
              onTap: canSubmit ? _handleSubmit : null,
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

  Future<void> _handleFileSelectTap() async {
    /* 실제 기기 테스트 시 아래 주석을 해제하고 더미 코드를 지워주세요.
    final FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final PlatformFile pickedFile = result.files.single;
    final byteData = pickedFile.bytes;

    if (byteData == null || byteData.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('선택한 파일을 읽을 수 없습니다.')));
      return;
    }

    final String fileName = pickedFile.name;
    final int fileSize = pickedFile.size;
    */

    // --- 가상 기기 테스트용 더미 파일 ---
    final String fileName = 'dummy_assignment_result.pdf';
    final int fileSize = 1048576; // 1MB
    final Uint8List byteData = Uint8List.fromList(
      List<int>.filled(fileSize, 0),
    );
    // ----------------------------

    final StudentUploadFile file = StudentUploadFile(
      fileName: fileName,
      contentType: _contentTypeFor(fileName),
      bytes: byteData,
      size: fileSize,
    );

    setState(() {
      _selectedFile = file;
    });
  }

  Future<void> _handleSubmit() async {
    final String link = _linkController.text.trim();

    if (_selectedFile == null && link.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('과제 파일 또는 링크를 입력해주세요.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String fileUrl = '';

      if (_selectedFile != null && widget.onUploadFile != null) {
        final StudentPresignedUpload presignedUpload =
            await widget.onUploadFile!(_selectedFile!);

        fileUrl = presignedUpload.fileUrl?.trim() ?? '';
        if (fileUrl.isEmpty) {
          throw Exception('파일 URL을 확인할 수 없습니다.');
        }
      }

      if (widget.onSubmit != null) {
        await widget.onSubmit!(fileUrl: fileUrl, link: link);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('과제 제출에 실패했습니다.')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _contentTypeFor(String fileName) {
    final String extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'zip':
        return 'application/zip';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
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
