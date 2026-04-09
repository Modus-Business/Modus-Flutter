import 'package:flutter/material.dart';

import '../../../../component/theme/app_colors.dart';

class StudentEmptyGroupState extends StatelessWidget {
  const StudentEmptyGroupState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_2_outlined, size: 56, color: AppColors.mutedText),
          SizedBox(height: 18),
          Text(
            '아직 모둠이 배정되지 않았습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryInk,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '공지와 과제 목록은 상단 액션에서 바로 확인할 수 있습니다.\n채팅과 모둠원 정보는 배정 이후 활성화됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
