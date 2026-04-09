import '../features/auth/domain/entities/auth_mode.dart';

class AppRoutes {
  const AppRoutes._();

  static const String root = '/';
  static const String classes = '/classes';
  static const String settings = '/settings';
  static const String classDetailPrefix = '/class';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String auth = '/auth';

  static String get currentLocation {
    final String path = Uri.base.path.isEmpty ? root : Uri.base.path;
    final String fragment = Uri.base.fragment;
    return fragment.isEmpty ? path : '$path#$fragment';
  }

  static AppRouteConfig resolve(String? rawLocation) {
    final String location = rawLocation == null || rawLocation.isEmpty
        ? root
        : rawLocation;
    final Uri uri = Uri.parse(location);
    final String path = uri.path.isEmpty ? root : uri.path;

    if (path == root) {
      return const AppRouteConfig(
        kind: AppRouteKind.auth,
        authMode: AuthMode.login,
      );
    }

    if (path == classes) {
      return const AppRouteConfig(kind: AppRouteKind.classes);
    }

    if (path == settings) {
      return const AppRouteConfig(kind: AppRouteKind.settings);
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

enum AppRouteKind { auth, classes, classDetail, settings }

class AppRouteConfig {
  const AppRouteConfig({required this.kind, this.authMode, this.classId});

  final AppRouteKind kind;
  final AuthMode? authMode;
  final String? classId;
}
