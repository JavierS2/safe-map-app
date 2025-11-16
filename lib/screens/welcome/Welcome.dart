import 'package:flutter/material.dart';
import 'package:safe_map_application/screens/welcome/widgets/logo_widget.dart';
import 'package:safe_map_application/screens/welcome/widgets/primary_button.dart';
import 'package:safe_map_application/screens/welcome/widgets/secondary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.logoImage});

  final ImageProvider? logoImage;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00D4FF),
              Color(0xFF00B8E6),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LogoWidget(
                  logoImage: widget.logoImage ??
                      const AssetImage('assets/images/logo.png'),
                ),

                const SizedBox(height: 16),

                const Text(
                  'SafeMap',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón Iniciar Sesión → /login
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: 'Iniciar Sesión',
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Botón Registrarse → /register
                      SizedBox(
                        width: double.infinity,
                        child: SecondaryButton(
                          label: 'Registrarse',
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
