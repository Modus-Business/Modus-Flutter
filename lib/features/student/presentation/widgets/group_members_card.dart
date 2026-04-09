import 'package:flutter/material.dart';

import '../../domain/entities/student_class.dart';

class GroupMembersCard extends StatelessWidget {
  const GroupMembersCard({
    super.key,
    required this.groupAssigned,
    required this.isOpen,
    required this.onToggle,
    required this.group,
    required this.classCode,
  });

  final bool groupAssigned;
  final bool isOpen;
  final VoidCallback onToggle;
  final StudentGroup? group;
  final String classCode;

  @override
  Widget build(BuildContext context) {
    final int memberCount = group?.members.length ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9E1F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Row(
                children: [
                  const Icon(
                    Icons.groups_2_outlined,
                    color: Color(0xFF6A80F2),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '모둠원',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF27334B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF2F5FF),
                    ),
                    child: Text(
                      '$memberCount',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7D87A0),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF7D87A0),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          if (!groupAssigned) ...[
            const Divider(height: 1, color: Color(0xFFD9E1F3)),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '모둠 배정 후에 팀원 정보를 확인할 수 있습니다.',
                style: TextStyle(
                  height: 1.6,
                  color: Color(0xFF7D87A0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else if (isOpen && group != null) ...[
            const Divider(height: 1, color: Color(0xFFD9E1F3)),
            ...List<Widget>.generate(group!.members.length, (int index) {
              final String member = group!.members[index];
              return Container(
                height: 110,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFD9E1F3))),
                  color: Color(0xFFF9FBFF),
                ),
                child: Row(
                  children: [
                    _AvatarCircle(color: _memberColor(index)),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        member,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF27334B),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DashedDivider(),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Text(
                        '#',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6A80F2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '수업 코드 $classCode',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF27334B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (groupAssigned) ...[
            const Divider(height: 1, color: Color(0xFFD9E1F3)),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '헤더를 눌러 모둠원 목록을 펼쳐보세요.',
                style: TextStyle(
                  height: 1.6,
                  color: Color(0xFF7D87A0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _memberColor(int index) {
    const List<Color> colors = [
      Color(0xFFDCE6FF),
      Color(0xFFDFF7E8),
      Color(0xFFFBE4D7),
      Color(0xFFE5DBFF),
    ];

    return colors[index % colors.length];
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int segmentCount = (constraints.maxWidth / 10).floor();

        return Row(
          children: List<Widget>.generate(
            segmentCount,
            (int index) => Expanded(
              child: Container(
                height: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: index.isEven
                    ? const Color(0xFFD9E1F3)
                    : Colors.transparent,
              ),
            ),
          ),
        );
      },
    );
  }
}
