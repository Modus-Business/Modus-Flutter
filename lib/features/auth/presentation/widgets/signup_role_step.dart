import 'package:flutter/material.dart';

import '../../../../component/theme/app_colors.dart';
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
        const SizedBox(height: 18),
        const Text(
          '1 / 3 단계 · 역할 선택',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF7B88A8),
          ),
        ),
        const SizedBox(height: 22),
        ...SignupRole.values.map(
          (SignupRole role) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RoleOptionCard(
              role: role,
              isSelected: selectedRole == role,
              onTap: () => onSelectRole(role),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedRole != null ? onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6281F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5FF) : const Color(0xFFF7F9FF),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C84F1)
                : const Color(0xFFE1E7F4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2743),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    role.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8F9BB7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF6C84F1) : AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}
