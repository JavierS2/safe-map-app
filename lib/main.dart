import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_map_application/screens/splash/splash.dart';
import 'package:safe_map_application/config/routes.dart';
import 'package:safe_map_application/config/route_history.dart';

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
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const SplashScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
      navigatorObservers: [appRouteObserver],
    );
  }
}
