import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modus_flutter/main.dart';

void main() {
  testWidgets('모둠이 있는 수업 상세에서 채팅과 모둠원 카드가 보인다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp(initialRoute: '/class/product-studio'));

    expect(find.textContaining('프로덕트 스튜디오 /'), findsOneWidget);
    expect(find.text('공지'), findsOneWidget);
    expect(find.text('과제 제출'), findsOneWidget);
    expect(find.text('모둠원'), findsOneWidget);
  });

  testWidgets('모둠이 없는 수업 상세에서는 empty state가 보인다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp(initialRoute: '/class/design-writing'));

    expect(find.textContaining('디자인 라이팅 워크숍 / 모둠 배정 전'), findsOneWidget);
    expect(find.text('아직 모둠이 배정되지 않았습니다.'), findsOneWidget);
    expect(find.text('모둠 배정 후에 팀원 정보를 확인할 수 있습니다.'), findsOneWidget);
  });

  testWidgets('설정 화면에서 프로필과 인증 상태를 확인할 수 있다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/settings'));

    expect(find.text('설정'), findsWidgets);
    expect(find.text('모두달리기42'), findsWidgets);
    expect(find.text('이메일 인증 완료'), findsOneWidget);
  });
}
