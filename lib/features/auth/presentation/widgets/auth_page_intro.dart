import 'package:flutter/material.dart';

import '../../../../component/layout/responsive_layout.dart';

class AuthPageIntro extends StatelessWidget {
  const AuthPageIntro({
    super.key,
    required this.modeLabel,
    required this.title,
    required this.description,
  });

  final String modeLabel;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveLayout.of(context) == ResponsiveSize.mobile;

    return Column(
      children: [
        Image.asset(
          'assets/images/modus_text_logo.png',
          width: isMobile ? 170 : 210,
          fit: BoxFit.contain,
        ),
        SizedBox(height: isMobile ? 24 : 28),
        Text(
          modeLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 5,
            color: const Color(0xFF8BA2FF),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 42 : 56,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: const Color(0xFF1F2743),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
            height: 1.7,
            color: const Color(0xFF7B88A8),
          ),
        ),
      ],
    );
  }
}
