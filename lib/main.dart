import 'package:flutter/material.dart';

import 'component/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialRoute});

  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modus Auth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: initialRoute ?? AppRoutes.currentLocation,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
