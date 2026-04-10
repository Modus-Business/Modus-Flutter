import 'package:flutter/material.dart';

import '../../../../core/platform/web_url_sync.dart';
import '../../../../routes/app_routes.dart';
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
    _state =
        widget.initialState.mode == AuthMode.signup &&
            widget.initialState.signupRole == null
        ? widget.initialState.copyWith(signupRole: SignupRole.student)
        : widget.initialState;
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
    final AuthFormState nextState = _state.switchMode(mode);
    _updateState(
      mode == AuthMode.signup
          ? nextState.copyWith(signupRole: SignupRole.student)
          : nextState,
    );
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

    _updateState(
      _state
          .copyWith(mode: AuthMode.signup, signupRole: SignupRole.student)
          .resetSignupFlow()
          .copyWith(signupRole: SignupRole.student),
    );
    _syncUrl();
  }

  Future<void> _confirmResetSignupFlow() async {
    final bool? shouldReset = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x80A9B5D3),
      builder: (BuildContext dialogContext) {
        return const _ResetSignupDialog();
      },
    );

    if (shouldReset == true && mounted) {
      _resetSignupFlow();
    }
  }

  void _showPendingMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleLoginSubmit() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.classes);
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
    return 'Join with us';
  }

  String _heroDescription() {
    if (_state.mode == AuthMode.login) {
      return '수업에 참여하거나 수업을 운영하려면 먼저 계정으로\n로그인하세요.';
    }
    return '계정을 만들고 바로 수업 참여 또는 수업 운영을 시작할 수 있습니다.';
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
          onChangeRole: () {
            _updateState(_state.copyWith(signupStep: SignupStep.role));
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
          onReset: _confirmResetSignupFlow,
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

class _ResetSignupDialog extends StatelessWidget {
  const _ResetSignupDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x213B4B8E),
              blurRadius: 34,
              offset: Offset(0, 22),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '회원가입을 처음부터 다시 시작할까요?',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                      color: Color(0xFF1F2743),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF7B88A8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '지금까지 입력한 역할과 회원가입 정보가 모두 초기화됩니다. 계속하려면 다시 입력해야 합니다.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.8,
                color: Color(0xFF8D98B5),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6281F0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  '처음부터 다시',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1F2743),
                  side: const BorderSide(color: Color(0xFFE1E7F4)),
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  '계속 작성',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
