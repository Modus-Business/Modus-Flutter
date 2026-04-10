import 'package:flutter/material.dart';

import '../features/auth/data/repositories/auth_flow_repository_impl.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/student/data/repositories/student_repository_impl.dart';
import '../features/student/presentation/screens/student_class_detail_screen.dart';
import '../features/student/presentation/screens/student_classes_screen.dart';
import '../features/student/presentation/screens/student_settings_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  const RouteGenerator._();

  static final AuthFlowRepositoryImpl _authFlowRepository =
      const AuthFlowRepositoryImpl();
  static final StudentRepositoryImpl _studentRepository =
      const StudentRepositoryImpl();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final AppRouteConfig config = AppRoutes.resolve(settings.name);
    final profile = _studentRepository.getProfile();

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) {
        switch (config.kind) {
          case AppRouteKind.classes:
            return StudentClassesScreen(
              classes: _studentRepository.getClasses(),
              profile: profile,
              onClassesTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.classes);
              },
              onSettingsTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
              },
              onLogoutTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
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
              return StudentClassesScreen(
                classes: _studentRepository.getClasses(),
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
                  Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
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
                Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
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
                Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
              },
            );
          case AppRouteKind.auth:
            return AuthScreen(
              initialState: _authFlowRepository.buildInitialState(
                mode: config.authMode!,
              ),
            );
        }
      },
    );
  }
}
