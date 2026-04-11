import 'signup_role.dart';

class SignupParams {
  const SignupParams({
    required this.name,
    required this.email,
    required this.verificationCode,
    required this.role,
    required this.password,
    required this.passwordConfirmation,
  });

  final String name;
  final String email;
  final String verificationCode;
  final SignupRole role;
  final String password;
  final String passwordConfirmation;
}
