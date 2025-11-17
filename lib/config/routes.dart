import 'package:flutter/material.dart';
import 'package:safe_map_application/screens/forgot_password_screen/forgot_password_screen.dart';
import 'package:safe_map_application/screens/login/login.dart';
import 'package:safe_map_application/screens/new_password/new_password_screen.dart';
import 'package:safe_map_application/screens/register/register.dart';
// Screens
import 'package:safe_map_application/screens/splash/splash.dart';
import 'package:safe_map_application/screens/welcome/welcome.dart';
import 'package:safe_map_application/screens/home/home_screen.dart';
import 'package:safe_map_application/screens/report/create_report_screen.dart';
import 'package:safe_map_application/screens/report/report_search_screen.dart';
import 'package:safe_map_application/screens/account_settings/account_settings_screen.dart';

class AppRoutes {
  // Rutas nombradas
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const newPassword = '/new-password';
  static const home = '/home';
  static const createReport = '/create-report';
  static const reportSearch = '/report-search';
  static const accountSettings = '/account-settings';

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

      case createReport:
        return MaterialPageRoute(
          builder: (_) => const CreateReportScreen(),
        );

      case reportSearch:
        return MaterialPageRoute(
          builder: (_) => const ReportSearchScreen(),
        );

          case accountSettings:
            return MaterialPageRoute(
              builder: (_) => const AccountSettingsScreen(),
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
