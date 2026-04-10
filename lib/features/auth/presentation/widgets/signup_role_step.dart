import 'package:flutter/material.dart';

import '../../domain/entities/signup_role.dart';
import 'auth_section_badge.dart';

class SignupRoleStep extends StatelessWidget {
  const SignupRoleStep({
    super.key,
    required this.selectedRole,
    required this.onSelectRole,
    required this.onContinue,
    required this.onSwitchToLogin,
  });

  final SignupRole? selectedRole;
  final ValueChanged<SignupRole> onSelectRole;
  final VoidCallback onContinue;
  final VoidCallback onSwitchToLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthSectionBadge(label: 'SIGN UP'),
        const SizedBox(height: 22),
        _RoleOptionCard(
          role: SignupRole.student,
          isSelected: selectedRole == SignupRole.student,
          onTap: () => onSelectRole(SignupRole.student),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedRole == SignupRole.student ? onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6281F0),
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('다음'),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: [
              const Text(
                '이미 계정이 있으신가요?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2743),
                ),
              ),
              TextButton(
                onPressed: onSwitchToLogin,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1F2743),
                ),
                child: const Text('로그인하기'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  final SignupRole role;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C84F1)
                : const Color(0xFFE1E7F4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 118,
              height: 118,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0F4FF),
              ),
              child: Icon(
                Icons.school_outlined,
                size: 54,
                color: isSelected
                    ? const Color(0xFF6281F0)
                    : const Color(0xFF8190BA),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              role.label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2743),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '수업에 참여하고 모둠 활동을 진행할 계정을 만듭니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF8F9BB7),
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
