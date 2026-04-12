import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_flow_repository_impl.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/login_use_case.dart';
import '../features/auth/domain/usecases/logout_use_case.dart';
import '../features/auth/domain/usecases/send_email_verification_use_case.dart';
import '../features/auth/domain/usecases/signup_use_case.dart';
import '../features/auth/domain/usecases/verify_email_code_use_case.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/student/data/datasources/student_remote_data_source.dart';
import '../features/student/data/repositories/student_repository_impl.dart';
import '../features/student/presentation/screens/student_class_detail_screen.dart';
import '../features/student/presentation/screens/student_classes_route_screen.dart';
import '../features/student/presentation/screens/student_settings_screen.dart';
import '../features/survey/data/datasources/survey_remote_data_source.dart';
import '../features/survey/data/repositories/survey_repository_impl.dart';
import '../features/survey/domain/usecases/submit_survey_use_case.dart';
import '../features/survey/presentation/screens/student_survey_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  const RouteGenerator._();

  static final AuthFlowRepositoryImpl _authFlowRepository =
      const AuthFlowRepositoryImpl();
  static final http.Client _httpClient = http.Client();
  static final AuthRepositoryImpl _authRepository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(
      client: _httpClient,
      baseUrl: _baseUrl,
    ),
  );
  static final LoginUseCase _loginUseCase = LoginUseCase(_authRepository);
  static final LogoutUseCase _logoutUseCase = LogoutUseCase(_authRepository);
  static final SendEmailVerificationUseCase _sendEmailVerificationUseCase =
      SendEmailVerificationUseCase(_authRepository);
  static final SignupUseCase _signupUseCase = SignupUseCase(_authRepository);
  static final VerifyEmailCodeUseCase _verifyEmailCodeUseCase =
      VerifyEmailCodeUseCase(_authRepository);
  static final StudentRepositoryImpl _studentRepository = StudentRepositoryImpl(
    remoteDataSource: StudentRemoteDataSourceImpl(
      client: _httpClient,
      baseUrl: _baseUrl,
    ),
  );
  static final SurveyRepositoryImpl _surveyRepository = SurveyRepositoryImpl(
    remoteDataSource: SurveyRemoteDataSourceImpl(
      client: _httpClient,
      baseUrl: _baseUrl,
    ),
  );
  static final SubmitSurveyUseCase _submitSurveyUseCase = SubmitSurveyUseCase(
    _surveyRepository,
  );

  static String get _baseUrl {
    if (!dotenv.isInitialized) {
      return 'http://localhost:8080';
    }

    // 기존 .env 설정명을 그대로 쓰되, 이전 키도 함께 허용합니다.
    return dotenv.maybeGet('BASE_URL') ??
        dotenv.maybeGet('API_BASE_URL') ??
        'http://localhost:8080';
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final AppRouteConfig config = AppRoutes.resolve(settings.name);
    final profile = _studentRepository.getProfile();

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) {
        switch (config.kind) {
          case AppRouteKind.classes:
            return StudentClassesRouteScreen(
              repository: _studentRepository,
              profile: profile,
              onClassesTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.classes);
              },
              onSettingsTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
              },
              onLogoutTap: () {
                unawaited(_logoutAndNavigate(context));
              },
              onClassTap: (String classId) {
                Navigator.of(context).pushNamed('/class/$classId');
              },
            );
          case AppRouteKind.classDetail:
            final studentClass = _studentRepository.getClassById(
              config.classId!,
            );
            if (studentClass == null) {
              return StudentClassesRouteScreen(
                repository: _studentRepository,
                profile: profile,
                onClassesTap: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.classes);
                },
                onSettingsTap: () {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRoutes.settings);
                },
                onLogoutTap: () {
                  unawaited(_logoutAndNavigate(context));
                },
                onClassTap: (String classId) {
                  Navigator.of(context).pushNamed('/class/$classId');
                },
              );
            }

            return StudentClassDetailScreen(
              studentClass: studentClass,
              profile: profile,
              onClassesTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.classes);
              },
              onSettingsTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
              },
              onLogoutTap: () {
                unawaited(_logoutAndNavigate(context));
              },
            );
          case AppRouteKind.settings:
            return StudentSettingsScreen(
              profile: profile,
              onClassesTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.classes);
              },
              onSettingsTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
              },
              onLogoutTap: () {
                unawaited(_logoutAndNavigate(context));
              },
            );
          case AppRouteKind.survey:
            return StudentSurveyScreen(
              submitSurveyUseCase: _submitSurveyUseCase,
              onCompleted: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.classes);
              },
            );
          case AppRouteKind.splash:
            return const SplashScreen();
          case AppRouteKind.auth:
            return AuthScreen(
              initialState: _authFlowRepository.buildInitialState(
                mode: config.authMode!,
              ),
              loginUseCase: _loginUseCase,
              signupUseCase: _signupUseCase,
              sendEmailVerificationUseCase: _sendEmailVerificationUseCase,
              verifyEmailCodeUseCase: _verifyEmailCodeUseCase,
            );
        }
      },
    );
  }

  static Future<void> _logoutAndNavigate(BuildContext context) async {
    await _logoutUseCase();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
  }
}
