import 'package:flutter/material.dart';
import 'package:safe_map_application/screens/Splash/Splash.dart';
import 'package:safe_map_application/config/routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeMap',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
