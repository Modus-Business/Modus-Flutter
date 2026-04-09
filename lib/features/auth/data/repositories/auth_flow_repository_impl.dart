import '../../domain/entities/auth_form_state.dart';
import '../../domain/entities/auth_mode.dart';
import '../../domain/repositories/auth_flow_repository.dart';

class AuthFlowRepositoryImpl implements AuthFlowRepository {
  const AuthFlowRepositoryImpl();

  @override
  AuthFormState buildInitialState({required AuthMode mode}) {
    return AuthFormState.initial(mode: mode);
  }
}
