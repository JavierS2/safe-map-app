import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterLink extends StatelessWidget {
  const RegisterLink({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.black87,
        ),
        children: [
          const TextSpan(text: "¿No tienes una cuenta? "),
          TextSpan(
            text: "Regístrate",
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.pushNamed(context, '/register'),
          ),
        ],
      ),
    );
  }
}
