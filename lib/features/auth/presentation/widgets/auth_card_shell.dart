import 'package:flutter/material.dart';

import '../../../../component/layout/responsive_layout.dart';
import '../../../../component/theme/app_colors.dart';

class AuthCardShell extends StatelessWidget {
  const AuthCardShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ResponsiveSize screenSize = ResponsiveLayout.of(context);
    final double horizontalPadding = screenSize == ResponsiveSize.mobile
        ? 20
        : 32;
    final double verticalPadding = screenSize == ResponsiveSize.mobile
        ? 24
        : 32;
    final double radius = screenSize == ResponsiveSize.mobile ? 24 : 32;
    final double maxWidth = screenSize == ResponsiveSize.mobile ? 560 : 520;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F202124),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset('assets/images/modus_logo.png'),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modus',
                      style: TextStyle(
                        color: AppColors.primaryInk,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Classroom-ready authentication',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
