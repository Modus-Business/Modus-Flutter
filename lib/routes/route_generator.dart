import 'package:flutter/material.dart';

import '../features/auth/data/repositories/auth_flow_repository_impl.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  const RouteGenerator._();

  static final AuthFlowRepositoryImpl _authFlowRepository =
      const AuthFlowRepositoryImpl();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final AuthRouteConfig config = AppRoutes.resolve(settings.name);

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => AuthScreen(
        initialState: _authFlowRepository.buildInitialState(mode: config.mode),
      ),
    );
  }
}
