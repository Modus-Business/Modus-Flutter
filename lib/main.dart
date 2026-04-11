import 'package:flutter/material.dart';

import 'component/theme/app_theme.dart';
import 'core/config/app_env.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
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
