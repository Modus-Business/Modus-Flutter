import '../entities/login_params.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call(LoginParams params) {
    return _authRepository.login(params);
  }
}
