import '../features/auth/domain/entities/auth_mode.dart';

class AppRoutes {
  const AppRoutes._();

  static const String root = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String auth = '/auth';

  static String get currentLocation {
    final String path = Uri.base.path.isEmpty ? root : Uri.base.path;
    final String fragment = Uri.base.fragment;
    return fragment.isEmpty ? path : '$path#$fragment';
  }

  static AuthRouteConfig resolve(String? rawLocation) {
    final String location = rawLocation == null || rawLocation.isEmpty
        ? root
        : rawLocation;
    final Uri uri = Uri.parse(location);
    final String path = uri.path.isEmpty ? root : uri.path;

    if (path == signup || (path == auth && uri.fragment == 'signup')) {
      return const AuthRouteConfig(mode: AuthMode.signup);
    }

    return const AuthRouteConfig(mode: AuthMode.login);
  }
}

class AuthRouteConfig {
  const AuthRouteConfig({required this.mode});

  final AuthMode mode;
}
