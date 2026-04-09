import 'package:flutter/material.dart';

import '../../../../component/layout/responsive_layout.dart';
import '../../../../core/platform/web_url_sync.dart';
import '../../domain/entities/auth_form_state.dart';
import '../../domain/entities/auth_mode.dart';
import '../../domain/entities/signup_role.dart';
import '../../domain/entities/signup_step.dart';
import '../widgets/auth_brand_panel.dart';
import '../widgets/auth_card_shell.dart';
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final ResponsiveSize screenSize = ResponsiveLayout.resolve(
              constraints.maxWidth,
            );
            final bool isCompact = screenSize != ResponsiveSize.desktop;
            final double outerPadding = screenSize == ResponsiveSize.mobile
                ? 16
                : 24;
            final double compactBrandHeight =
                screenSize == ResponsiveSize.mobile ? 250 : 320;
            final double compactGap = screenSize == ResponsiveSize.mobile
                ? 16
                : 20;

            final Widget reactiveBrandPanel = Expanded(
              child: AuthBrandPanel(mode: _state.mode),
            );

            final Widget cardPanel = Expanded(
              child: Align(
                alignment: Alignment.center,
                child: AuthCardShell(child: _buildActiveForm()),
              ),
            );

            final List<Widget> desktopChildren = _state.mode == AuthMode.login
                ? <Widget>[
                    reactiveBrandPanel,
                    const SizedBox(width: 28),
                    cardPanel,
                  ]
                : <Widget>[
                    cardPanel,
                    const SizedBox(width: 28),
                    reactiveBrandPanel,
                  ];

            if (isCompact) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(outerPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenSize == ResponsiveSize.mobile ? 560 : 760,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: compactBrandHeight,
                          child: AuthBrandPanel(
                            mode: _state.mode,
                            isCompact: true,
                          ),
                        ),
                        SizedBox(height: compactGap),
                        AuthCardShell(child: _buildActiveForm()),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1360),
                child: Padding(
                  padding: EdgeInsets.all(outerPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: desktopChildren,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
