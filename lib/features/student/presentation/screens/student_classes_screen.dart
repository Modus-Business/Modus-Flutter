import 'package:flutter/material.dart';

import '../../domain/entities/student_class.dart';
import '../../domain/entities/student_profile.dart';
import '../widgets/student_class_card.dart';
import '../widgets/student_join_class_dialog.dart';
import '../widgets/student_shell.dart';

class StudentClassesScreen extends StatelessWidget {
  const StudentClassesScreen({
    super.key,
    required this.classes,
    required this.profile,
    required this.onClassesTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
    required this.onClassTap,
    required this.onJoinClass,
  });

  final List<StudentClass> classes;
  final StudentProfile profile;
  final VoidCallback onClassesTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;
  final ValueChanged<String> onClassTap;
  final Future<bool> Function(String classCode) onJoinClass;

  @override
  Widget build(BuildContext context) {
    return StudentShell(
      selectedItem: StudentNavItem.classes,
      onClassesTap: onClassesTap,
      onSettingsTap: onSettingsTap,
      onLogoutTap: onLogoutTap,
      appBarTitle: const SizedBox.shrink(),
      showProfileAvatar: false,
      onPrimaryActionTap: () async {
        final String? classCode = await showDialog<String>(
          context: context,
          barrierColor: const Color(0x66C5D0F2),
          builder: (_) => const StudentJoinClassDialog(),
        );

        if (classCode == null || classCode.trim().isEmpty || !context.mounted) {
          return;
        }

        final bool joined = await onJoinClass(classCode);

        if (joined && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('수업에 참여했습니다.')));
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('수업 참여에 실패했습니다. 수업 코드를 확인해주세요.')),
          );
        }
      },
      primaryActionIcon: Icons.add_rounded,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 34),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFD8E1F5)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _DateChip(),
                      SizedBox(height: 18),
                      Text(
                        '참여 중인 수업',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2743),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                  child: Column(
                    children: [
                      for (final StudentClass item in classes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: StudentClassCard(
                            studentClass: item,
                            onTap: () => onClassTap(item.id),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(0xFF728BFF),
            ),
            SizedBox(width: 8),
            Text(
              '오늘: 2026. 04. 09. (목)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF728BFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
