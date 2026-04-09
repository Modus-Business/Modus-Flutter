import 'package:flutter_test/flutter_test.dart';
import 'package:modus_flutter/main.dart';

void main() {
  testWidgets('/signup 진입 시 회원가입 역할 선택이 열린다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/signup'));

    expect(find.text('1 / 3 단계 · 역할 선택'), findsOneWidget);
    expect(find.text('수강생'), findsOneWidget);
    expect(find.text('교강사'), findsOneWidget);
  });

  testWidgets('/login 진입 시 로그인 화면이 열린다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/login'));

    expect(find.text('Sign in'), findsNWidgets(2));
    expect(find.text('이메일'), findsOneWidget);
  });
}
