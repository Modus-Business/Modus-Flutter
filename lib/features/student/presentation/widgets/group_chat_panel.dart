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
    return Container(
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
          Container(
            padding: const EdgeInsets.fromLTRB(10, 18, 10, 18),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F7FF),
              border: Border(
                left: BorderSide(color: Color(0xFFD9E1F3)),
                top: BorderSide(color: Color(0xFFD9E1F3)),
                right: BorderSide(color: Color(0xFFD9E1F3)),
              ),
            ),
            child: groupAssigned
                ? Column(
                    children: List<Widget>.generate(messages.length, (
                      int index,
                    ) {
                      final StudentChatMessage message = messages[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == messages.length - 1 ? 0 : 22,
                        ),
                        child: _ChatBubble(
                          message: message,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        ),
                      );
                    }),
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      '모둠이 배정되면 채팅이 활성화됩니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF7D87A0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
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
                  minLines: 2,
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
                    height: 1.6,
                    color: Color(0xFF27334B),
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: controller.text.trim().isNotEmpty && groupAssigned
                      ? onSend
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.text.trim().isNotEmpty && groupAssigned
                          ? const Color(0xFFB7C5FF)
                          : const Color(0xFFE3E9FA),
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: controller.text.trim().isNotEmpty && groupAssigned
                          ? Colors.white
                          : const Color(0xFF92A0BE),
                    ),
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

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.onEdit,
    required this.onDelete,
  });

  final StudentChatMessage message;
  final ValueChanged<StudentChatMessage> onEdit;
  final ValueChanged<StudentChatMessage> onDelete;

  @override
  Widget build(BuildContext context) {
    final double panelWidth = MediaQuery.sizeOf(context).width;
    // 모바일에서도 말풍선이 과하게 넓어지지 않도록 화면 비율 기준으로 맞춥니다.
    final double bubbleMaxWidth = message.isMine
        ? panelWidth * 0.7
        : panelWidth * 0.76;

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
          constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
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
