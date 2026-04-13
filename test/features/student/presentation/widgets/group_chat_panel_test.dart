import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modus_flutter/features/student/domain/entities/student_class.dart';
import 'package:modus_flutter/features/student/presentation/widgets/group_chat_panel.dart';

void main() {
  testWidgets('스크롤 화면 안에서도 채팅 패널이 레이아웃된다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final TextEditingController controller = TextEditingController();
    final ScrollController scrollController = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: GroupChatPanel(
                  groupAssigned: true,
                  messages: const [
                    StudentChatMessage(
                      id: 'message-1',
                      author: '김모두',
                      message: '안녕하세요',
                      sentAt: '오전 10:00',
                      isMine: true,
                    ),
                  ],
                  controller: controller,
                  scrollController: scrollController,
                  editingMessageId: null,
                  onChanged: (_) {},
                  onSend: () {},
                  onInterventionAdvice: () {},
                  onEdit: (_) {},
                  onDelete: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.text('AI 조언'), findsOneWidget);
    expect(find.text('기여도'), findsNothing);
  });
}
