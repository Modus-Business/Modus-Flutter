import '../entities/send_signup_verification_params.dart';
import '../repositories/auth_repository.dart';

class SendEmailVerificationUseCase {
  const SendEmailVerificationUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call(SendSignupVerificationParams params) {
    return _authRepository.sendEmailVerification(params);
  }
}
