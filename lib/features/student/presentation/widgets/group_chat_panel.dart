import 'package:flutter/material.dart';

import '../../domain/entities/student_class.dart';

class GroupChatPanel extends StatelessWidget {
  const GroupChatPanel({
    super.key,
    required this.groupAssigned,
    required this.messages,
    required this.controller,
    required this.editingMessageId,
    required this.onChanged,
    required this.onSend,
    required this.onEdit,
    required this.onDelete,
  });

  final bool groupAssigned;
  final List<StudentChatMessage> messages;
  final TextEditingController controller;
  final String? editingMessageId;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final ValueChanged<StudentChatMessage> onEdit;
  final ValueChanged<StudentChatMessage> onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size viewportSize = MediaQuery.sizeOf(context);
        final double chatWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : viewportSize.width;
        // 스크롤 화면 안에서는 높이 제약이 없으므로 채팅 목록의 Expanded가 계산 가능한 높이를 갖게 한다.
        final double panelHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : (viewportSize.height * 0.58).clamp(380.0, 560.0).toDouble();

        return SizedBox(
          height: panelHeight,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFF),
              border: Border.all(color: const Color(0xFFD9E1F3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (editingMessageId != null)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(6, 4, 6, 12),
                    child: Text(
                      '메시지 수정 중',
                      style: TextStyle(
                        color: Color(0xFF6A80F2),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                // 메시지 영역 (스크롤 가능)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F7FF),
                      border: Border(
                        left: BorderSide(color: Color(0xFFD9E1F3)),
                        top: BorderSide(color: Color(0xFFD9E1F3)),
                        right: BorderSide(color: Color(0xFFD9E1F3)),
                      ),
                    ),
                    child: !groupAssigned
                        ? const _EmptyState(message: '모둠이 배정되면 채팅이 활성화됩니다.')
                        : messages.isEmpty
                        ? const _EmptyState(
                            message: '메시지가 아직 없습니다.\n인사를 나눠보세요!',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == messages.length - 1 ? 0 : 20,
                                ),
                                child: _ChatBubble(
                                  message: message,
                                  maxWidth: chatWidth * 0.75,
                                  onEdit: onEdit,
                                  onDelete: onDelete,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                // 입력창 영역
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      left: BorderSide(color: Color(0xFFD9E1F3)),
                      right: BorderSide(color: Color(0xFFD9E1F3)),
                      bottom: BorderSide(color: Color(0xFFD9E1F3)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        onChanged: onChanged,
                        enabled: groupAssigned,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          hintText: '메시지를 입력하세요.',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7D87A0),
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: Color(0xFF27334B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap:
                                controller.text.trim().isNotEmpty &&
                                    groupAssigned
                                ? onSend
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    controller.text.trim().isNotEmpty &&
                                        groupAssigned
                                    ? const Color(0xFFB7C5FF)
                                    : const Color(0xFFE3E9FA),
                              ),
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                color:
                                    controller.text.trim().isNotEmpty &&
                                        groupAssigned
                                    ? Colors.white
                                    : const Color(0xFF92A0BE),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF7D87A0),
            fontWeight: FontWeight.w600,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.maxWidth,
    required this.onEdit,
    required this.onDelete,
  });

  final StudentChatMessage message;
  final double maxWidth;
  final ValueChanged<StudentChatMessage> onEdit;
  final ValueChanged<StudentChatMessage> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message.isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: message.isMine
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Text(
              '${message.author}  ${message.sentAt}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7F8CAB),
              ),
            ),
            if (message.isMine) ...[
              const SizedBox(width: 6),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x123E5BA5),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.fromBorderSide(
                    BorderSide(color: Color(0xFFD5DDF1)),
                  ),
                ),
                child: PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'edit') {
                      onEdit(message);
                    } else if (value == 'delete') {
                      onDelete(message);
                    }
                  },
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: Color(0xFF7B88A8),
                    size: 22,
                  ),
                  itemBuilder: (BuildContext context) => const [
                    PopupMenuItem<String>(value: 'edit', child: Text('수정')),
                    PopupMenuItem<String>(value: 'delete', child: Text('삭제')),
                    PopupMenuItem<String>(value: 'cancel', child: Text('취소')),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFD5DDF1)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x083E5BA5),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message.message,
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
                color: Color(0xFF27334B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
