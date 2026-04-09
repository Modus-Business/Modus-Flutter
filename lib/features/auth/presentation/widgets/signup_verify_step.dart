import 'package:flutter/material.dart';

import '../../../../component/layout/responsive_layout.dart';
import '../../domain/entities/signup_role.dart';
import 'auth_section_badge.dart';
import 'auth_text_field.dart';

class SignupVerifyStep extends StatelessWidget {
  const SignupVerifyStep({
    super.key,
    required this.role,
    required this.email,
    required this.codeController,
    required this.canComplete,
    required this.onCodeChanged,
    required this.onReset,
    required this.onComplete,
    required this.onSwitchToLogin,
  });

  final SignupRole role;
  final String email;
  final TextEditingController codeController;
  final bool canComplete;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onReset;
  final VoidCallback onComplete;
  final VoidCallback onSwitchToLogin;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveLayout.of(context) == ResponsiveSize.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthSectionBadge(label: 'SIGN UP'),
        const SizedBox(height: 18),
        const Text(
          '3 / 3 단계 · 이메일 인증',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF7B88A8),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5FC),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE1E7F4)),
          ),
          child: Text(
            '${role.label} 계정 생성을 위해\n$email 로 전송된 인증번호를 입력하세요.',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: Color(0xFF7B88A8),
            ),
          ),
        ),
        const SizedBox(height: 24),
        AuthTextField(
          hintText: '6자리 인증번호',
          controller: codeController,
          icon: Icons.verified_user_outlined,
          keyboardType: TextInputType.number,
          onChanged: onCodeChanged,
        ),
        const SizedBox(height: 24),
        if (isMobile) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE1E7F4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text('처음부터 다시'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canComplete ? onComplete : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6281F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text('회원가입'),
            ),
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReset,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE1E7F4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text('처음부터 다시'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: canComplete ? onComplete : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6281F0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text('회원가입'),
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),
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
