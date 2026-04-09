import 'auth_mode.dart';
import 'signup_role.dart';
import 'signup_step.dart';

class AuthFormState {
  const AuthFormState({
    required this.mode,
    required this.signupStep,
    required this.signupRole,
    required this.loginEmail,
    required this.loginPassword,
    required this.fullName,
    required this.signupEmail,
    required this.signupPassword,
    required this.signupPasswordConfirm,
    required this.verificationCode,
  });

  final AuthMode mode;
  final SignupStep signupStep;
  final SignupRole? signupRole;
  final String loginEmail;
  final String loginPassword;
  final String fullName;
  final String signupEmail;
  final String signupPassword;
  final String signupPasswordConfirm;
  final String verificationCode;

  factory AuthFormState.initial({required AuthMode mode}) {
    return AuthFormState(
      mode: mode,
      signupStep: SignupStep.role,
      signupRole: null,
      loginEmail: '',
      loginPassword: '',
      fullName: '',
      signupEmail: '',
      signupPassword: '',
      signupPasswordConfirm: '',
      verificationCode: '',
    );
  }

  AuthFormState copyWith({
    AuthMode? mode,
    SignupStep? signupStep,
    SignupRole? signupRole,
    bool clearSignupRole = false,
    String? loginEmail,
    String? loginPassword,
    String? fullName,
    String? signupEmail,
    String? signupPassword,
    String? signupPasswordConfirm,
    String? verificationCode,
  }) {
    return AuthFormState(
      mode: mode ?? this.mode,
      signupStep: signupStep ?? this.signupStep,
      signupRole: clearSignupRole ? null : signupRole ?? this.signupRole,
      loginEmail: loginEmail ?? this.loginEmail,
      loginPassword: loginPassword ?? this.loginPassword,
      fullName: fullName ?? this.fullName,
      signupEmail: signupEmail ?? this.signupEmail,
      signupPassword: signupPassword ?? this.signupPassword,
      signupPasswordConfirm:
          signupPasswordConfirm ?? this.signupPasswordConfirm,
      verificationCode: verificationCode ?? this.verificationCode,
    );
  }

  AuthFormState switchMode(AuthMode nextMode) {
    return copyWith(mode: nextMode);
  }

  AuthFormState resetSignupFlow() {
    return copyWith(
      signupStep: SignupStep.role,
      clearSignupRole: true,
      fullName: '',
      signupEmail: '',
      signupPassword: '',
      signupPasswordConfirm: '',
      verificationCode: '',
    );
  }

  bool get canSubmitLogin =>
      loginEmail.trim().isNotEmpty && loginPassword.trim().isNotEmpty;

  bool get canContinueProfile =>
      signupRole != null &&
      fullName.trim().isNotEmpty &&
      signupEmail.trim().isNotEmpty &&
      signupPassword.trim().isNotEmpty &&
      signupPasswordConfirm.trim().isNotEmpty &&
      signupPassword == signupPasswordConfirm;

  bool get canCompleteSignup =>
      canContinueProfile && verificationCode.trim().isNotEmpty;
}
