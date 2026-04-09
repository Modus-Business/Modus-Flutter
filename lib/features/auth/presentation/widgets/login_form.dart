import 'package:flutter/material.dart';

import '../../../../component/layout/responsive_layout.dart';
import '../../../../component/theme/app_colors.dart';
import 'auth_text_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.canSubmit,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
    required this.onSwitchToSignup,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool canSubmit;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onSwitchToSignup;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = ResponsiveLayout.of(context) == ResponsiveSize.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sign in', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 10),
        Text('이메일과 비밀번호를 입력해 인증을 시작합니다.', style: theme.textTheme.bodyMedium),
        SizedBox(height: isMobile ? 22 : 28),
        AuthTextField(
          label: '이메일',
          hintText: 'you@school.edu',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: '비밀번호',
          hintText: '비밀번호를 입력하세요',
          controller: passwordController,
          obscureText: true,
          onChanged: onPasswordChanged,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: canSubmit ? onSubmit : null,
          child: const Text('Sign in'),
        ),
        const SizedBox(height: 20),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 2,
          children: [
            Text(
              '계정이 아직 없으신가요?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryInk.withValues(alpha: 0.72),
              ),
            ),
            TextButton(
              onPressed: onSwitchToSignup,
              child: const Text('회원가입하기'),
            ),
          ],
        ),
      ],
    );
  }
}
