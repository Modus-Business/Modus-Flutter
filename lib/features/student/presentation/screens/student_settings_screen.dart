import 'package:flutter/material.dart';

import '../../../../component/theme/app_colors.dart';
import '../../domain/entities/student_profile.dart';
import '../widgets/student_shell.dart';

class StudentSettingsScreen extends StatelessWidget {
  const StudentSettingsScreen({
    super.key,
    required this.profile,
    required this.onClassesTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  final StudentProfile profile;
  final VoidCallback onClassesTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return StudentShell(
      selectedItem: StudentNavItem.settings,
      onClassesTap: onClassesTap,
      onSettingsTap: onSettingsTap,
      onLogoutTap: onLogoutTap,
      appBarTitle: const Text(
        '설정',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF27334B),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _SettingsCard(
                  title: '프로필 정보',
                  children: [
                    _SettingsRow(label: '본명', value: profile.name),
                    _SettingsRow(label: '역할', value: profile.roleLabel),
                    _SettingsRow(
                      label: '교강사만 보기',
                      value: profile.teacherOnlyVisibility,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsCard(
                  title: '인증 상태',
                  children: [
                    _SettingsRow(label: '이메일', value: profile.email),
                    _SettingsRow(
                      label: '상태',
                      value: profile.isEmailVerified ? '이메일 인증 완료' : '인증 대기',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryInk,
            ),
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryInk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
