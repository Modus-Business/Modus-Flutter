import 'package:flutter/material.dart';

import '../../../../component/layout/responsive_layout.dart';

class AuthCardShell extends StatelessWidget {
  const AuthCardShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ResponsiveSize screenSize = ResponsiveLayout.of(context);
    final double horizontalPadding = screenSize == ResponsiveSize.mobile
        ? 18
        : 30;
    final double verticalPadding = screenSize == ResponsiveSize.mobile
        ? 20
        : 30;
    final double radius = screenSize == ResponsiveSize.mobile ? 30 : 38;
    final double maxWidth = screenSize == ResponsiveSize.mobile ? 540 : 620;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x183E5FC6),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}
