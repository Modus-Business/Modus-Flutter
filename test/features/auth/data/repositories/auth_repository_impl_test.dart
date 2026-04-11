import 'package:flutter_test/flutter_test.dart';
import 'package:modus_flutter/core/session/auth_session.dart';
import 'package:modus_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:modus_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:modus_flutter/features/auth/domain/entities/login_params.dart';
import 'package:modus_flutter/features/auth/domain/entities/send_signup_verification_params.dart';
import 'package:modus_flutter/features/auth/domain/entities/signup_params.dart';
import 'package:modus_flutter/features/auth/domain/entities/verify_email_code_params.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(AuthSession.clear);

  test('로그아웃 시 refreshToken으로 서버 요청을 보내고 로컬 세션을 삭제한다', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await AuthSession.initialize();
    await AuthSession.saveTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );

    final _FakeAuthRemoteDataSource remoteDataSource =
        _FakeAuthRemoteDataSource();
    final AuthRepositoryImpl repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    await repository.logout();

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    expect(remoteDataSource.requestedRefreshToken, 'refresh-token');
    expect(AuthSession.accessToken, isNull);
    expect(AuthSession.refreshToken, isNull);
    expect(preferences.getString('auth.access_token'), isNull);
    expect(preferences.getString('auth.refresh_token'), isNull);
  });
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  String? requestedRefreshToken;

  @override
  Future<void> login(LoginParams params) async {}

  @override
  Future<void> signup(SignupParams params) async {}

  @override
  Future<void> sendEmailVerification(
    SendSignupVerificationParams params,
  ) async {}

  @override
  Future<void> verifyEmailCode(VerifyEmailCodeParams params) async {}

  @override
  Future<void> logout(String refreshToken) async {
    requestedRefreshToken = refreshToken;
  }
}
