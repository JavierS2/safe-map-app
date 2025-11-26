import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const NextButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed ?? () => Navigator.pushNamed(context, '/new-password'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00CCFF),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          "Siguiente",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
