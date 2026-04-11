import '../entities/login_params.dart';
import '../entities/send_signup_verification_params.dart';
import '../entities/signup_params.dart';
import '../entities/verify_email_code_params.dart';

abstract class AuthRepository {
  Future<void> login(LoginParams params);
  Future<void> signup(SignupParams params);
  Future<void> sendEmailVerification(SendSignupVerificationParams params);
  Future<void> verifyEmailCode(VerifyEmailCodeParams params);
  Future<void> logout();
}
