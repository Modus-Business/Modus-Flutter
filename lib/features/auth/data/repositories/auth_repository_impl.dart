import '../../../../core/session/auth_session.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/send_signup_verification_params.dart';
import '../../domain/entities/signup_params.dart';
import '../../domain/entities/verify_email_code_params.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<void> login(LoginParams params) async {
    try {
      await _remoteDataSource.login(params);
    } on AuthRemoteException catch (error) {
      throw AuthFailure(error.message, type: _mapFailureType(error.type));
    }
  }

  @override
  Future<void> signup(SignupParams params) async {
    try {
      await _remoteDataSource.signup(params);
    } on AuthRemoteException catch (error) {
      throw AuthFailure(error.message, type: _mapFailureType(error.type));
    }
  }

  @override
  Future<void> sendEmailVerification(
    SendSignupVerificationParams params,
  ) async {
    try {
      await _remoteDataSource.sendEmailVerification(params);
    } on AuthRemoteException catch (error) {
      throw AuthFailure(error.message, type: _mapFailureType(error.type));
    }
  }

  @override
  Future<void> verifyEmailCode(VerifyEmailCodeParams params) async {
    try {
      await _remoteDataSource.verifyEmailCode(params);
    } on AuthRemoteException catch (error) {
      throw AuthFailure(error.message, type: _mapFailureType(error.type));
    }
  }

  @override
  Future<void> logout() async {
    final String? refreshToken = AuthSession.refreshToken;

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _remoteDataSource.logout(refreshToken);
      }
    } on AuthRemoteException {
      // 서버 로그아웃 실패와 관계없이 로컬 세션은 반드시 제거합니다.
    } finally {
      await AuthSession.clear();
    }
  }

  AuthFailureType _mapFailureType(AuthRemoteExceptionType type) {
    switch (type) {
      case AuthRemoteExceptionType.invalidCredentials:
        return AuthFailureType.invalidCredentials;
      case AuthRemoteExceptionType.network:
        return AuthFailureType.network;
      case AuthRemoteExceptionType.server:
        return AuthFailureType.server;
      case AuthRemoteExceptionType.configuration:
        return AuthFailureType.configuration;
      case AuthRemoteExceptionType.unknown:
        return AuthFailureType.unknown;
    }
  }
}
