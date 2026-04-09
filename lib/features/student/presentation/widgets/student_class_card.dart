import 'package:flutter/material.dart';

import '../../domain/entities/student_class.dart';

class StudentClassCard extends StatelessWidget {
  const StudentClassCard({
    super.key,
    required this.studentClass,
    required this.onTap,
  });

  final StudentClass studentClass;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String statusText = studentClass.groupAssigned
        ? '모둠 · ${studentClass.groupName}'
        : '모둠 상태 · 배정 전';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD5DDF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  studentClass.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222C44),
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.2,
                  ),
                ),
              ),
              const Icon(Icons.north_east_rounded, color: Color(0xFF697898)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            studentClass.description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.8,
              color: Color(0xFF6E7D9D),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '#  $statusText',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF728BFF),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6780F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text(
                '자세히 보기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
