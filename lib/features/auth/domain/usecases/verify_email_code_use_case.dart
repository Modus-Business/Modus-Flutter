import '../entities/verify_email_code_params.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailCodeUseCase {
  const VerifyEmailCodeUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call(VerifyEmailCodeParams params) {
    return _authRepository.verifyEmailCode(params);
  }
}
