import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hint;

  const InputField({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFA9EEFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black45,
            fontFamily: 'Poppins',
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
