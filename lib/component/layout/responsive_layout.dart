import 'package:flutter/widgets.dart';

enum ResponsiveSize { mobile, tablet, desktop }

class ResponsiveLayout {
  const ResponsiveLayout._();

  static ResponsiveSize resolve(double width) {
    if (width < 720) {
      return ResponsiveSize.mobile;
    }
    if (width < 1100) {
      return ResponsiveSize.tablet;
    }
    return ResponsiveSize.desktop;
  }

  static ResponsiveSize of(BuildContext context) {
    return resolve(MediaQuery.sizeOf(context).width);
  }
}
