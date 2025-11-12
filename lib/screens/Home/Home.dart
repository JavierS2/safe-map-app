import 'package:flutter/material.dart';
import 'package:safe_map_application/screens/Home/widgets/logo_widget.dart';
import 'package:safe_map_application/screens/Home/widgets/primary_button.dart';
import 'package:safe_map_application/screens/Home/widgets/secondary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.logoImage});

  final ImageProvider? logoImage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                LogoWidget(logoImage: widget.logoImage ?? const AssetImage('assets/images/logo.png')),
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
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: 'Iniciar Sesión',
                          onPressed: () {
                            _showMessage('Iniciar Sesión');
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SecondaryButton(
                          label: 'Registrarse',
                          onPressed: () {
                            _showMessage('Registrarse');
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

  void _showMessage(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action - Próximamente')),
    );
  }
}


