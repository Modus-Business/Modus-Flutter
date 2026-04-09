import '../entities/auth_form_state.dart';
import '../entities/auth_mode.dart';

abstract class AuthFlowRepository {
  AuthFormState buildInitialState({required AuthMode mode});
}
