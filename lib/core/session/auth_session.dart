import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  AuthSession._();

  static const String _accessTokenKey = 'auth.access_token';
  static const String _refreshTokenKey = 'auth.refresh_token';

  static SharedPreferences? _preferences;
  static String? _accessToken;
  static String? _refreshToken;

  static String? get accessToken => _accessToken;

  static String? get refreshToken => _refreshToken;

  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    _accessToken = _preferences?.getString(_accessTokenKey);
    _refreshToken = _preferences?.getString(_refreshTokenKey);
  }

  static Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
  }) async {
    final String? normalizedAccessToken = _normalizeToken(accessToken);
    final String? normalizedRefreshToken = _normalizeToken(refreshToken);

    if (normalizedAccessToken != null) {
      _accessToken = normalizedAccessToken;
      await _preferences?.setString(_accessTokenKey, normalizedAccessToken);
    }

    if (normalizedRefreshToken != null) {
      _refreshToken = normalizedRefreshToken;
      await _preferences?.setString(_refreshTokenKey, normalizedRefreshToken);
    }
  }

  static Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;

    await _preferences?.remove(_accessTokenKey);
    await _preferences?.remove(_refreshTokenKey);
  }

  static String? _normalizeToken(String? token) {
    final String? trimmedToken = token?.trim();

    if (trimmedToken == null || trimmedToken.isEmpty) {
      return null;
    }

    return trimmedToken;
  }
}
