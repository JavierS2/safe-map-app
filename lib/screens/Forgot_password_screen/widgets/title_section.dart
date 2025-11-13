import 'package:flutter/material.dart';

class TitleSection extends StatelessWidget {
  const TitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Recupera Tu Contraseña",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
