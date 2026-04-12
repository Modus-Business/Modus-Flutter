import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../../core/session/auth_session.dart';
import '../../../../routes/app_routes.dart';
import '../../data/datasources/auth_remote_data_source.dart';

/// 스플래시 화면 – 앱 시작 시 토큰 검증 및 갱신 후 적절한 화면으로 라우팅합니다.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // 로고 페이드인 애니메이션
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    // 토큰 검증을 비동기로 시작
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // 로고가 자연스럽게 보이도록 최소 1.2초 대기
    final Future<void> minDelay = Future<void>.delayed(
      const Duration(milliseconds: 1200),
    );

    String destination = AppRoutes.auth;

    final String? refreshToken = AuthSession.refreshToken;

    if (refreshToken != null && refreshToken.isNotEmpty) {
      // 리프레시 토큰이 있으면 항상 갱신 시도합니다.
      // 액세스 토큰이 살아있어도 만료 여부를 신뢰할 수 없으므로
      // 반드시 서버에서 새 토큰을 발급받습니다.
      destination = await _tryRefresh(refreshToken);
    }
    // 리프레시 토큰이 없으면 바로 로그인으로 이동

    await minDelay;

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(destination);
  }

  Future<String> _tryRefresh(String refreshToken) async {
    try {
      final String baseUrl =
          dotenv.maybeGet('BASE_URL') ??
          dotenv.maybeGet('API_BASE_URL') ??
          '';

      if (baseUrl.isEmpty) {
        return AppRoutes.auth;
      }

      final AuthRemoteDataSourceImpl dataSource = AuthRemoteDataSourceImpl(
        client: http.Client(),
        baseUrl: baseUrl,
      );

      final bool success = await dataSource.refreshTokens(refreshToken);
      return success ? AppRoutes.classes : AppRoutes.auth;
    } catch (_) {
      return AppRoutes.auth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Image.asset(
            'assets/images/modus_text_logo.png',
            width: 180,
          ),
        ),
      ),
    );
  }
}
