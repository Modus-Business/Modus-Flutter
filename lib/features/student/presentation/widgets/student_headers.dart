import 'package:flutter/material.dart';

import '../../../../component/theme/app_colors.dart';

class StudentGeneralHeader extends StatelessWidget {
  const StudentGeneralHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.profileName,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String profileName;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stacked = constraints.maxWidth < 760;
          final Widget titleSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset('assets/images/modus_logo.png'),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Modus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryInk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryInk,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          );

          final List<Widget> actions = [
            _ProfileChip(name: profileName),
            if (trailing != null) SizedBox(width: 144, child: trailing!),
          ];

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleSection,
                const SizedBox(height: 18),
                Wrap(spacing: 12, runSpacing: 12, children: actions),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleSection),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  actions.first,
                  if (actions.length > 1) ...[
                    const SizedBox(height: 16),
                    actions[1],
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class StudentDetailHeader extends StatelessWidget {
  const StudentDetailHeader({
    super.key,
    required this.title,
    required this.groupLabel,
    required this.profileName,
    required this.onAssignmentsTap,
    required this.onAnnouncementsTap,
    required this.onSubmissionTap,
  });

  final String title;
  final String groupLabel;
  final String profileName;
  final VoidCallback onAssignmentsTap;
  final VoidCallback onAnnouncementsTap;
  final VoidCallback onSubmissionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stacked = constraints.maxWidth < 760;
          final Widget titleSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset('assets/images/modus_logo.png'),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Modus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryInk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryInk,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentMint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  groupLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.classroomGreenDark,
                  ),
                ),
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stacked) ...[
                titleSection,
                const SizedBox(height: 16),
                _ProfileChip(name: profileName),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleSection),
                    const SizedBox(width: 16),
                    _ProfileChip(name: profileName),
                  ],
                ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 128,
                    child: OutlinedButton.icon(
                      onPressed: onAssignmentsTap,
                      icon: const Icon(Icons.assignment_outlined),
                      label: const Text('모둠 과제'),
                    ),
                  ),
                  SizedBox(
                    width: 112,
                    child: OutlinedButton.icon(
                      onPressed: onAnnouncementsTap,
                      icon: const Icon(Icons.campaign_outlined),
                      label: const Text('공지'),
                    ),
                  ),
                  SizedBox(
                    width: 128,
                    child: ElevatedButton.icon(
                      onPressed: onSubmissionTap,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('과제 제출'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.boardBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.classroomGreen,
            child: Text(
              '박',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryInk,
            ),
          ),
        ],
      ),
    );
  }
}
