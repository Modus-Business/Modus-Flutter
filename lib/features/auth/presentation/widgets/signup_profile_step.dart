import 'package:flutter/material.dart';

import '../../../../component/layout/responsive_layout.dart';
import '../../../../component/theme/app_colors.dart';
import '../../domain/entities/signup_role.dart';
import 'auth_text_field.dart';

class SignupProfileStep extends StatelessWidget {
  const SignupProfileStep({
    super.key,
    required this.role,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmController,
    required this.canContinue,
    required this.passwordsMatch,
    required this.onFullNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onPasswordConfirmChanged,
    required this.onContinue,
    required this.onSwitchToLogin,
  });

  final SignupRole role;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;
  final bool canContinue;
  final bool passwordsMatch;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onPasswordConfirmChanged;
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
        Text('2 / 3 단계 · 프로필 입력', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8FF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '선택한 역할: ${role.label}',
            style: const TextStyle(
              color: AppColors.primaryInk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 20 : 24),
        AuthTextField(
          label: '본명',
          hintText: '홍길동',
          controller: fullNameController,
          onChanged: onFullNameChanged,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: '이메일',
          hintText: 'you@school.edu',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: '비밀번호',
          hintText: '비밀번호를 입력하세요',
          controller: passwordController,
          obscureText: true,
          onChanged: onPasswordChanged,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: '비밀번호 확인',
          hintText: '비밀번호를 다시 입력하세요',
          controller: passwordConfirmController,
          obscureText: true,
          onChanged: onPasswordConfirmChanged,
        ),
        if (!passwordsMatch && passwordConfirmController.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            '비밀번호가 일치하지 않습니다.',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        SizedBox(height: isMobile ? 20 : 24),
        ElevatedButton(
          onPressed: canContinue ? onContinue : null,
          child: const Text('이메일 인증으로 계속'),
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
