import 'package:flutter/material.dart';

import '../../../../component/layout/responsive_layout.dart';
import '../../../../component/theme/app_colors.dart';
import '../../domain/entities/signup_role.dart';
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
    final ThemeData theme = Theme.of(context);
    final bool isMobile = ResponsiveLayout.of(context) == ResponsiveSize.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('회원가입', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('3 / 3 단계 · 이메일 인증', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '${role.label} 계정 생성을 위해\n$email 로 전송된 인증번호를 입력하세요.',
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          ),
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: '인증번호',
          hintText: '6자리 인증번호',
          controller: codeController,
          keyboardType: TextInputType.number,
          onChanged: onCodeChanged,
        ),
        const SizedBox(height: 24),
        isMobile
            ? Column(
                children: [
                  OutlinedButton(
                    onPressed: onReset,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('처음부터 다시'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: canComplete ? onComplete : null,
                    child: const Text('회원가입'),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReset,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('처음부터 다시'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canComplete ? onComplete : null,
                      child: const Text('회원가입'),
                    ),
                  ),
                ],
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
