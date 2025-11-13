import 'package:flutter/material.dart';

class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/forgot-password');
      },
      child: const Text(
        "¿Olvidaste la contraseña?",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
    );
  }
}
