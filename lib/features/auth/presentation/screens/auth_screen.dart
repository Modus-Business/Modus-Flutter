import 'package:flutter/material.dart';

import '../../../../core/platform/web_url_sync.dart';
import '../../domain/entities/auth_form_state.dart';
import '../../domain/entities/auth_mode.dart';
import '../../domain/entities/signup_role.dart';
import '../../domain/entities/signup_step.dart';
import '../widgets/auth_card_shell.dart';
import '../widgets/auth_page_intro.dart';
import '../widgets/login_form.dart';
import '../widgets/signup_profile_step.dart';
import '../widgets/signup_role_step.dart';
import '../widgets/signup_verify_step.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.initialState});

  final AuthFormState initialState;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthFormState _state;
  late final TextEditingController _loginEmailController;
  late final TextEditingController _loginPasswordController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _signupEmailController;
  late final TextEditingController _signupPasswordController;
  late final TextEditingController _signupPasswordConfirmController;
  late final TextEditingController _verificationCodeController;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
    _loginEmailController = TextEditingController(text: _state.loginEmail);
    _loginPasswordController = TextEditingController(
      text: _state.loginPassword,
    );
    _fullNameController = TextEditingController(text: _state.fullName);
    _signupEmailController = TextEditingController(text: _state.signupEmail);
    _signupPasswordController = TextEditingController(
      text: _state.signupPassword,
    );
    _signupPasswordConfirmController = TextEditingController(
      text: _state.signupPasswordConfirm,
    );
    _verificationCodeController = TextEditingController(
      text: _state.verificationCode,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUrl();
    });
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _fullNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupPasswordConfirmController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _updateState(AuthFormState nextState) {
    setState(() {
      _state = nextState;
    });
  }

  void _switchMode(AuthMode mode) {
    _updateState(_state.switchMode(mode));
    _syncUrl();
  }

  void _syncUrl() {
    // 웹에서는 화면 상태와 주소를 함께 유지해 직접 진입과 새로고침을 맞춥니다.
    final String location = _state.mode == AuthMode.signup
        ? '/auth#signup'
        : '/auth';
    WebUrlSync.replace(location);
  }

  void _resetSignupFlow() {
    _fullNameController.clear();
    _signupEmailController.clear();
    _signupPasswordController.clear();
    _signupPasswordConfirmController.clear();
    _verificationCodeController.clear();

    _updateState(_state.copyWith(mode: AuthMode.signup).resetSignupFlow());
    _syncUrl();
  }

  void _showPendingMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleLoginSubmit() {
    _showPendingMessage('로그인 연동은 다음 단계에서 연결됩니다.');
  }

  void _handleSignupComplete() {
    _showPendingMessage('회원가입 연동은 다음 단계에서 연결됩니다.');
  }

  String _heroModeLabel() {
    if (_state.mode == AuthMode.login) {
      return 'MODUS SIGN IN';
    }
    return 'MODUS SIGN UP';
  }

  String _heroTitle() {
    if (_state.mode == AuthMode.login) {
      return 'Welcome';
    }

    switch (_state.signupStep) {
      case SignupStep.role:
        return 'Create\nAccount';
      case SignupStep.profile:
        return 'Set Up\nProfile';
      case SignupStep.verify:
        return 'Verify\nEmail';
    }
  }

  String _heroDescription() {
    if (_state.mode == AuthMode.login) {
      return '수업에 참여하거나 수업을 운영하려면 먼저 계정으로\n로그인하세요.';
    }

    switch (_state.signupStep) {
      case SignupStep.role:
        return '수강생 또는 교강사 역할을 먼저 선택해\n회원가입 흐름을 시작하세요.';
      case SignupStep.profile:
        return '프로필과 로그인 정보를 입력해\n이메일 인증 단계로 이동하세요.';
      case SignupStep.verify:
        return '전송된 인증번호를 입력하면\n회원가입 준비가 마무리됩니다.';
    }
  }

  Widget _buildActiveForm() {
    if (_state.mode == AuthMode.login) {
      return LoginForm(
        emailController: _loginEmailController,
        passwordController: _loginPasswordController,
        canSubmit: _state.canSubmitLogin,
        onEmailChanged: (String value) {
          _updateState(_state.copyWith(loginEmail: value));
        },
        onPasswordChanged: (String value) {
          _updateState(_state.copyWith(loginPassword: value));
        },
        onSubmit: _handleLoginSubmit,
        onSwitchToSignup: () => _switchMode(AuthMode.signup),
      );
    }

    switch (_state.signupStep) {
      case SignupStep.role:
        return SignupRoleStep(
          selectedRole: _state.signupRole,
          onSelectRole: (SignupRole role) {
            _updateState(_state.copyWith(signupRole: role));
          },
          onContinue: () {
            _updateState(_state.copyWith(signupStep: SignupStep.profile));
          },
          onSwitchToLogin: () => _switchMode(AuthMode.login),
        );
      case SignupStep.profile:
        return SignupProfileStep(
          role: _state.signupRole!,
          fullNameController: _fullNameController,
          emailController: _signupEmailController,
          passwordController: _signupPasswordController,
          passwordConfirmController: _signupPasswordConfirmController,
          canContinue: _state.canContinueProfile,
          passwordsMatch: _state.signupPassword == _state.signupPasswordConfirm,
          onFullNameChanged: (String value) {
            _updateState(_state.copyWith(fullName: value));
          },
          onEmailChanged: (String value) {
            _updateState(_state.copyWith(signupEmail: value));
          },
          onPasswordChanged: (String value) {
            _updateState(_state.copyWith(signupPassword: value));
          },
          onPasswordConfirmChanged: (String value) {
            _updateState(_state.copyWith(signupPasswordConfirm: value));
          },
          onContinue: () {
            _updateState(_state.copyWith(signupStep: SignupStep.verify));
          },
          onSwitchToLogin: () => _switchMode(AuthMode.login),
        );
      case SignupStep.verify:
        return SignupVerifyStep(
          role: _state.signupRole!,
          email: _state.signupEmail,
          codeController: _verificationCodeController,
          canComplete: _state.canCompleteSignup,
          onCodeChanged: (String value) {
            _updateState(_state.copyWith(verificationCode: value));
          },
          onReset: _resetSignupFlow,
          onComplete: _handleSignupComplete,
          onSwitchToLogin: () => _switchMode(AuthMode.login),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  AuthPageIntro(
                    modeLabel: _heroModeLabel(),
                    title: _heroTitle(),
                    description: _heroDescription(),
                  ),
                  const SizedBox(height: 32),
                  AuthCardShell(child: _buildActiveForm()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
