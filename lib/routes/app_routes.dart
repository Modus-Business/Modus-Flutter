import '../features/auth/domain/entities/auth_mode.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String root = '/';
  static const String classes = '/classes';
  static const String settings = '/settings';
  static const String survey = '/survey';
  static const String classDetailPrefix = '/class';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String auth = '/auth';

  static String get currentLocation => splash;

  static AppRouteConfig resolve(String? rawLocation) {
    final String location = rawLocation == null || rawLocation.isEmpty
        ? root
        : rawLocation;
    final Uri uri = Uri.parse(location);
    final String path = uri.path.isEmpty ? root : uri.path;

    if (path == splash || path == root) {
      return const AppRouteConfig(kind: AppRouteKind.splash);
    }

    if (path == classes) {
      return const AppRouteConfig(kind: AppRouteKind.classes);
    }

    if (path == settings) {
      return const AppRouteConfig(kind: AppRouteKind.settings);
    }

    if (path == survey) {
      return const AppRouteConfig(kind: AppRouteKind.survey);
    }

    if (path.startsWith('$classDetailPrefix/')) {
      final List<String> segments = uri.pathSegments;
      if (segments.length >= 2) {
        return AppRouteConfig(
          kind: AppRouteKind.classDetail,
          classId: segments[1],
        );
      }
    }

    if (path == signup || (path == auth && uri.fragment == 'signup')) {
      return const AppRouteConfig(
        kind: AppRouteKind.auth,
        authMode: AuthMode.signup,
      );
    }

    return const AppRouteConfig(
      kind: AppRouteKind.auth,
      authMode: AuthMode.login,
    );
  }
}

enum AppRouteKind { splash, auth, classes, classDetail, settings, survey }

class AppRouteConfig {
  const AppRouteConfig({required this.kind, this.authMode, this.classId});

  final AppRouteKind kind;
  final AuthMode? authMode;
  final String? classId;
}
