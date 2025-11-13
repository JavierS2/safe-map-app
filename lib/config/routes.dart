import 'package:flutter/material.dart';
import 'package:safe_map_application/screens/Forgot_password_screen/Forgot_password_screen.dart';
import 'package:safe_map_application/screens/Login/Login.dart';
import 'package:safe_map_application/screens/NewPassword/New_password_screen.dart';
import 'package:safe_map_application/screens/Register/Register.dart';
// Screens
import 'package:safe_map_application/screens/Splash/Splash.dart';
import 'package:safe_map_application/screens/Welcome/Welcome.dart';
import 'package:safe_map_application/screens/home/home_screen.dart';

class AppRoutes {
  // Rutas nombradas
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const newPassword = '/new-password';
  static const home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const Register(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      case newPassword:
        return MaterialPageRoute(
          builder: (_) => const NewPasswordScreen(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'No route defined for ${settings.name}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
    }
  }
}
