import 'package:flutter/material.dart';

import '../../../../component/layout/responsive_layout.dart';
import '../../../../component/theme/app_colors.dart';
import '../../domain/entities/signup_role.dart';

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
    final ThemeData theme = Theme.of(context);
    final bool isMobile = ResponsiveLayout.of(context) == ResponsiveSize.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('회원가입', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('1 / 3 단계 · 역할 선택', style: theme.textTheme.bodyMedium),
        SizedBox(height: isMobile ? 22 : 26),
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
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: selectedRole != null ? onContinue : null,
          child: const Text('다음'),
        ),
        const SizedBox(height: 20),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 2,
          children: [
            Text(
              '이미 계정이 있으신가요?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryInk.withValues(alpha: 0.72),
              ),
            ),
            TextButton(onPressed: onSwitchToLogin, child: const Text('로그인하기')),
          ],
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
    final bool isMobile = ResponsiveLayout.of(context) == ResponsiveSize.mobile;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(isMobile ? 18 : 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F8FF) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primaryInk : AppColors.border,
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
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryInk,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    role.description,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: AppColors.mutedText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primaryInk : AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}
