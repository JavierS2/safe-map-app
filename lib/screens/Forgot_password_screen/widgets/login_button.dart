import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/login'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF7E2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          "Inicia Sesión",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
