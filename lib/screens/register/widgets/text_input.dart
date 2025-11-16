import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const TextInput({
    super.key,
    required this.hint,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFA9EEFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}
