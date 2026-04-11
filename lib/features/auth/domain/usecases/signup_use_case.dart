import '../entities/signup_params.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase {
  const SignupUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call(SignupParams params) {
    return _authRepository.signup(params);
  }
}
