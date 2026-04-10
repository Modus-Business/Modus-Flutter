import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modus_flutter/main.dart';

void main() {
  testWidgets('로그인 버튼을 누르면 학생 수업 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/login'));

    await tester.enterText(find.byType(TextField).at(0), 'student@modus.app');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('참여 중인 수업'), findsOneWidget);
    expect(find.text('프로덕트 스튜디오'), findsOneWidget);
  });

  testWidgets('모바일 폭에서도 회원가입 플로우가 단계적으로 동작한다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp(initialRoute: '/signup'));

    await tester.tap(find.text('수강생'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('수강생 계정'), findsOneWidget);
    expect(find.text('역할 변경'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '홍길동');
    await tester.enterText(find.byType(TextField).at(1), 'student@modus.app');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.enterText(find.byType(TextField).at(3), 'password123');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('이메일 인증으로 계속'));
    await tester.tap(find.text('이메일 인증으로 계속'));
    await tester.pumpAndSettle();

    expect(find.text('수강생 계정 인증'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pumpAndSettle();

    expect(find.text('수강생 계정 인증'), findsOneWidget);
    expect(find.text('처음부터 다시'), findsOneWidget);
  });

  testWidgets('회원가입 초기화 버튼을 누르면 확인 모달이 열린다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp(initialRoute: '/signup'));

    await tester.tap(find.text('수강생'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '홍길동');
    await tester.enterText(find.byType(TextField).at(1), 'student@modus.app');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.enterText(find.byType(TextField).at(3), 'password123');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('이메일 인증으로 계속'));
    await tester.tap(find.text('이메일 인증으로 계속'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('처음부터 다시'));
    await tester.tap(find.text('처음부터 다시'));
    await tester.pumpAndSettle();

    expect(find.text('회원가입을 처음부터 다시 시작할까요?'), findsOneWidget);
    expect(find.text('계속 작성'), findsOneWidget);
  });

  testWidgets('회원가입 중 로그인하기를 누르면 로그인 화면으로 복귀한다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/signup'));

    await tester.ensureVisible(find.text('로그인하기'));
    await tester.tap(find.text('로그인하기'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.text('회원가입하기  ↗'), findsOneWidget);
  });

  testWidgets('데스크톱 폭에서도 로그인 화면이 정상 렌더링된다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp(initialRoute: '/login'));

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.text('회원가입하기  ↗'), findsOneWidget);
  });
}
