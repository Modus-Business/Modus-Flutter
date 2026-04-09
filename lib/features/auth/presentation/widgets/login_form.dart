import 'package:flutter/material.dart';

import 'auth_section_badge.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthSectionBadge(label: 'SIGN IN'),
        const SizedBox(height: 26),
        AuthTextField(
          hintText: '이메일을 입력하세요',
          controller: emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 18),
        AuthTextField(
          hintText: '비밀번호를 입력하세요',
          controller: passwordController,
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          onChanged: onPasswordChanged,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6281F0),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Sign in'),
          ),
        ),
        const SizedBox(height: 26),
        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            runSpacing: 2,
            children: [
              const Text(
                '계정이 없으신가요?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2743),
                ),
              ),
              TextButton(
                onPressed: onSwitchToSignup,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1F2743),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: const Text('회원가입하기  ↗'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
