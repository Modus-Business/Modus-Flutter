import 'package:flutter/material.dart';

import '../../../../component/theme/app_colors.dart';
import '../../domain/entities/auth_mode.dart';

class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key, required this.mode, this.isCompact = false});

  final AuthMode mode;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String headline = mode == AuthMode.login
        ? '수업 도구에 들어가기 전,\n가장 먼저 정리되는 인증 경험'
        : '학생과 교강사 모두,\n하나의 인증 화면에서 시작하는 가입 흐름';
    final String description = mode == AuthMode.login
        ? 'Google Classroom 계열의 교육 서비스처럼 단정하고 익숙한 구조를 바탕으로, 로그인과 가입 전환을 한 화면에서 관리합니다.'
        : '역할 선택, 프로필 입력, 이메일 인증을 차례대로 보여 주어 교육용 서비스에 맞는 안정적인 가입 경험을 만듭니다.';

    return Container(
      padding: EdgeInsets.all(isCompact ? 24 : 32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F202124),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool denseMode = isCompact || constraints.maxHeight < 760;
          final bool veryDenseMode = constraints.maxHeight < 420;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BrandBanner(isCompact: denseMode),
                SizedBox(height: denseMode ? 18 : 28),
                Text(
                  headline,
                  style:
                      (denseMode
                              ? theme.textTheme.headlineMedium
                              : theme.textTheme.displaySmall)
                          ?.copyWith(
                            fontSize: denseMode ? 24 : null,
                            height: 1.2,
                          ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.mutedText,
                    fontSize: denseMode ? 14 : 16,
                  ),
                ),
                SizedBox(height: denseMode ? 18 : 24),
                _ClassroomPreview(
                  isCompact: denseMode,
                  veryCompact: veryDenseMode,
                ),
                if (!veryDenseMode) ...[
                  SizedBox(height: denseMode ? 16 : 24),
                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoChip(label: 'Web Auth Only'),
                      _InfoChip(label: 'Student / Teacher Role'),
                      _InfoChip(label: 'Responsive Layout'),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BrandBanner extends StatelessWidget {
  const _BrandBanner({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 18 : 22,
        vertical: isCompact ? 16 : 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.classroomGreen,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: isCompact ? 50 : 62,
            height: isCompact ? 50 : 62,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset('assets/images/modus_logo.png'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Image.asset(
              'assets/images/modus_text_logo.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              height: isCompact ? 42 : 48,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassroomPreview extends StatelessWidget {
  const _ClassroomPreview({required this.isCompact, required this.veryCompact});

  final bool isCompact;
  final bool veryCompact;

  @override
  Widget build(BuildContext context) {
    final Widget statusBoard = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.boardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: const [
          _PreviewTopBar(),
          SizedBox(height: 16),
          _PreviewRow(
            color: AppColors.classroomGreen,
            title: '학생 로그인',
            subtitle: '이메일과 비밀번호로 빠르게 진입',
          ),
          SizedBox(height: 12),
          _PreviewRow(
            color: AppColors.accentBlue,
            title: '교강사 회원가입',
            subtitle: '역할 선택과 프로필 입력 흐름 제공',
          ),
          SizedBox(height: 12),
          _PreviewRow(
            color: AppColors.accentGold,
            title: '이메일 인증',
            subtitle: '마지막 단계에서 코드 검증 준비',
          ),
        ],
      ),
    );

    if (veryCompact) {
      return statusBoard;
    }

    final Widget sideSummary = Column(
      children: const [
        _SummaryCard(
          title: 'Student',
          description: '수업 참여 전용 진입 흐름',
          color: AppColors.accentBlue,
        ),
        SizedBox(height: 12),
        _SummaryCard(
          title: 'Teacher',
          description: '수업 개설 전용 가입 흐름',
          color: AppColors.classroomGreen,
        ),
      ],
    );

    if (isCompact) {
      return Column(
        children: [statusBoard, const SizedBox(height: 12), sideSummary],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: statusBoard),
        const SizedBox(width: 14),
        Expanded(flex: 2, child: sideSummary),
      ],
    );
  }
}

class _PreviewTopBar extends StatelessWidget {
  const _PreviewTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset('assets/images/modus_logo.png'),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auth Dashboard',
                style: TextStyle(
                  color: AppColors.primaryInk,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Single screen mode switch',
                style: TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _Pill(label: 'WEB'),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.description,
    required this.color,
  });

  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentMint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.classroomGreenDark,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.boardBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryInk,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
