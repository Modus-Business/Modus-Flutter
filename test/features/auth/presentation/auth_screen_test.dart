import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modus_flutter/features/auth/domain/entities/auth_form_state.dart';
import 'package:modus_flutter/features/auth/domain/entities/auth_mode.dart';
import 'package:modus_flutter/features/auth/domain/entities/login_params.dart';
import 'package:modus_flutter/features/auth/domain/entities/send_signup_verification_params.dart';
import 'package:modus_flutter/features/auth/domain/entities/signup_params.dart';
import 'package:modus_flutter/features/auth/domain/entities/verify_email_code_params.dart';
import 'package:modus_flutter/features/auth/domain/failures/auth_failure.dart';
import 'package:modus_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:modus_flutter/features/auth/domain/usecases/login_use_case.dart';
import 'package:modus_flutter/features/auth/domain/usecases/send_email_verification_use_case.dart';
import 'package:modus_flutter/features/auth/domain/usecases/signup_use_case.dart';
import 'package:modus_flutter/features/auth/domain/usecases/verify_email_code_use_case.dart';
import 'package:modus_flutter/features/auth/presentation/screens/auth_screen.dart';
import 'package:modus_flutter/main.dart';
import 'package:modus_flutter/routes/app_routes.dart';

void main() {
  testWidgets('로그인 버튼을 누르면 학생 수업 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.classes: (BuildContext context) =>
              const Scaffold(body: Text('classes')),
        },
        home: AuthScreen(
          initialState: AuthFormState.initial(mode: AuthMode.login),
          loginUseCase: LoginUseCase(const _FakeAuthRepository()),
          signupUseCase: SignupUseCase(const _FakeAuthRepository()),
          sendEmailVerificationUseCase: SendEmailVerificationUseCase(
            const _FakeAuthRepository(),
          ),
          verifyEmailCodeUseCase: VerifyEmailCodeUseCase(
            const _FakeAuthRepository(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'student@modus.app');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('classes'), findsOneWidget);
  });

  testWidgets('로그인 실패 시 에러 메시지를 보여준다', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(
          initialState: AuthFormState.initial(mode: AuthMode.login),
          loginUseCase: LoginUseCase(
            const _FakeAuthRepository(
              loginFailure: AuthFailure('이메일 또는 비밀번호를 확인해주세요.'),
            ),
          ),
          signupUseCase: SignupUseCase(const _FakeAuthRepository()),
          sendEmailVerificationUseCase: SendEmailVerificationUseCase(
            const _FakeAuthRepository(),
          ),
          verifyEmailCodeUseCase: VerifyEmailCodeUseCase(
            const _FakeAuthRepository(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'student@modus.app');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('이메일 또는 비밀번호를 확인해주세요.'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('모바일 폭에서도 회원가입 플로우가 단계적으로 동작한다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildAuthTestApp(
        mode: AuthMode.signup,
        repository: const _FakeAuthRepository(),
      ),
    );

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

  testWidgets('회원가입 성공 시 로그인 화면으로 전환되고 안내 메시지를 보여준다', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(
          initialState: AuthFormState.initial(mode: AuthMode.signup),
          loginUseCase: LoginUseCase(const _FakeAuthRepository()),
          signupUseCase: SignupUseCase(const _FakeAuthRepository()),
          sendEmailVerificationUseCase: SendEmailVerificationUseCase(
            const _FakeAuthRepository(),
          ),
          verifyEmailCodeUseCase: VerifyEmailCodeUseCase(
            const _FakeAuthRepository(),
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('수강생'));
    await tester.tap(find.text('수강생'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '홍길동');
    await tester.enterText(find.byType(TextField).at(1), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'Password123!');
    await tester.enterText(find.byType(TextField).at(3), 'Password123!');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('이메일 인증으로 계속'));
    await tester.tap(find.text('이메일 인증으로 계속'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('회원가입'));
    await tester.tap(find.text('회원가입'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('회원가입하기  ↗'), findsOneWidget);
  });

  testWidgets('회원가입 실패 시 에러 메시지를 보여준다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(
          initialState: AuthFormState.initial(mode: AuthMode.signup),
          loginUseCase: LoginUseCase(const _FakeAuthRepository()),
          signupUseCase: SignupUseCase(
            const _FakeAuthRepository(
              signupFailure: AuthFailure('이미 사용 중인 이메일입니다.'),
            ),
          ),
          sendEmailVerificationUseCase: SendEmailVerificationUseCase(
            const _FakeAuthRepository(),
          ),
          verifyEmailCodeUseCase: VerifyEmailCodeUseCase(
            const _FakeAuthRepository(),
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('수강생'));
    await tester.tap(find.text('수강생'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '홍길동');
    await tester.enterText(find.byType(TextField).at(1), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'Password123!');
    await tester.enterText(find.byType(TextField).at(3), 'Password123!');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('이메일 인증으로 계속'));
    await tester.tap(find.text('이메일 인증으로 계속'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('회원가입'));
    await tester.tap(find.text('회원가입'));
    await tester.pumpAndSettle();

    expect(find.text('이미 사용 중인 이메일입니다.'), findsOneWidget);
    expect(find.text('수강생 계정 인증'), findsOneWidget);
  });

  testWidgets('인증번호 발송 실패 시 프로필 단계에서 에러 메시지를 보여준다', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(
          initialState: AuthFormState.initial(mode: AuthMode.signup),
          loginUseCase: LoginUseCase(const _FakeAuthRepository()),
          signupUseCase: SignupUseCase(const _FakeAuthRepository()),
          sendEmailVerificationUseCase: SendEmailVerificationUseCase(
            const _FakeAuthRepository(
              sendVerificationFailure: AuthFailure('인증번호 발송에 실패했습니다.'),
            ),
          ),
          verifyEmailCodeUseCase: VerifyEmailCodeUseCase(
            const _FakeAuthRepository(),
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('수강생'));
    await tester.tap(find.text('수강생'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '홍길동');
    await tester.enterText(find.byType(TextField).at(1), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'Password123!');
    await tester.enterText(find.byType(TextField).at(3), 'Password123!');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('이메일 인증으로 계속'));
    await tester.tap(find.text('이메일 인증으로 계속'));
    await tester.pumpAndSettle();

    expect(find.text('인증번호 발송에 실패했습니다.'), findsOneWidget);
    expect(find.text('수강생 계정'), findsOneWidget);
  });

  testWidgets('인증 코드 검증 실패 시 verify 단계에서 에러 메시지를 보여준다', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(
          initialState: AuthFormState.initial(mode: AuthMode.signup),
          loginUseCase: LoginUseCase(const _FakeAuthRepository()),
          signupUseCase: SignupUseCase(
            const _FakeAuthRepository(
              signupFailure: AuthFailure('인증 코드가 올바르지 않습니다.'),
            ),
          ),
          sendEmailVerificationUseCase: SendEmailVerificationUseCase(
            const _FakeAuthRepository(),
          ),
          verifyEmailCodeUseCase: VerifyEmailCodeUseCase(
            const _FakeAuthRepository(),
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('수강생'));
    await tester.tap(find.text('수강생'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '홍길동');
    await tester.enterText(find.byType(TextField).at(1), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'Password123!');
    await tester.enterText(find.byType(TextField).at(3), 'Password123!');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('이메일 인증으로 계속'));
    await tester.tap(find.text('이메일 인증으로 계속'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'A1b2C3');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('회원가입'));
    await tester.tap(find.text('회원가입'));
    await tester.pumpAndSettle();

    expect(find.text('인증 코드가 올바르지 않습니다.'), findsOneWidget);
    expect(find.text('수강생 계정 인증'), findsOneWidget);
  });

  testWidgets('회원가입 초기화 버튼을 누르면 확인 모달이 열린다', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildAuthTestApp(
        mode: AuthMode.signup,
        repository: const _FakeAuthRepository(),
      ),
    );

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

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository({
    this.loginFailure,
    this.signupFailure,
    this.sendVerificationFailure,
  });

  final AuthFailure? loginFailure;
  final AuthFailure? signupFailure;
  final AuthFailure? sendVerificationFailure;

  @override
  Future<void> login(LoginParams params) async {
    if (loginFailure != null) {
      throw loginFailure!;
    }
  }

  @override
  Future<void> signup(SignupParams params) async {
    if (signupFailure != null) {
      throw signupFailure!;
    }
  }

  @override
  Future<void> sendEmailVerification(
    SendSignupVerificationParams params,
  ) async {
    if (sendVerificationFailure != null) {
      throw sendVerificationFailure!;
    }
  }

  @override
  Future<void> verifyEmailCode(VerifyEmailCodeParams params) async {}

  @override
  Future<void> logout() async {}
}

Widget _buildAuthTestApp({
  required AuthMode mode,
  required _FakeAuthRepository repository,
}) {
  return MaterialApp(
    home: AuthScreen(
      initialState: AuthFormState.initial(mode: mode),
      loginUseCase: LoginUseCase(repository),
      signupUseCase: SignupUseCase(repository),
      sendEmailVerificationUseCase: SendEmailVerificationUseCase(repository),
      verifyEmailCodeUseCase: VerifyEmailCodeUseCase(repository),
    ),
  );
}
