import 'package:flutter_test/flutter_test.dart';
import 'package:modus_flutter/main.dart';

void main() {
  testWidgets('/signup 진입 시 회원가입 역할 선택이 열린다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/signup'));

    expect(find.text('수강생'), findsOneWidget);
    expect(find.text('교강사'), findsNothing);
    expect(find.text('다음'), findsOneWidget);
  });

  testWidgets('/classes 진입 시 학생 수업 목록이 열린다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/classes'));

    expect(find.text('참여 중인 수업'), findsOneWidget);
    expect(find.text('프로덕트 스튜디오'), findsNothing);
  });
}
