import 'package:flutter_test/flutter_test.dart';
import 'package:modus_flutter/main.dart';

void main() {
  testWidgets('앱 기본 진입 시 로그인 화면이 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/'));

    expect(find.text('Sign in'), findsNWidgets(2));
    expect(find.text('회원가입하기'), findsOneWidget);
  });
}
