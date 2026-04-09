import 'package:flutter/material.dart';

import '../../domain/entities/signup_role.dart';
import 'auth_section_badge.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthSectionBadge(label: 'SIGN UP'),
        const SizedBox(height: 18),
        const Text(
          '2 / 3 단계 · 프로필 입력',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF7B88A8),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE6ECFF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '선택한 역할: ${role.label}',
            style: const TextStyle(
              color: Color(0xFF4865D6),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: '본명',
          hintText: '본명을 입력하세요',
          controller: fullNameController,
          icon: Icons.person_outline_rounded,
          onChanged: onFullNameChanged,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: '이메일',
          hintText: '이메일을 입력하세요',
          controller: emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: '비밀번호',
          hintText: '비밀번호를 입력하세요',
          controller: passwordController,
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          onChanged: onPasswordChanged,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: '비밀번호 확인',
          hintText: '비밀번호를 다시 입력하세요',
          controller: passwordConfirmController,
          icon: Icons.lock_person_outlined,
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
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canContinue ? onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6281F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: const Text('이메일 인증으로 계속'),
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
