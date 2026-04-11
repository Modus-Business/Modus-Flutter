import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  static const String _envFileName = 'assets/env/.env';

  static Future<void> load() async {
    // 앱 시작 전에 공용 환경 변수를 한 번만 로드합니다.
    await dotenv.load(fileName: _envFileName);
  }

  static String get(String key, {String fallback = ''}) {
    return dotenv.maybeGet(key) ?? fallback;
  }

  static String require(String key) {
    final String? value = dotenv.maybeGet(key);

    if (value == null || value.isEmpty) {
      throw StateError('$key 환경 변수가 설정되지 않았습니다.');
    }

    return value;
  }
}
