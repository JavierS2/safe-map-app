import 'package:flutter/material.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.location_on,
          size: 64,
          color: Colors.white,
        ),
        SizedBox(height: 24),
        Text(
          'SafeMap',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 48),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ],
    );
  }
}
