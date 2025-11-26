import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final bool obscureText;
  final VoidCallback onToggle;
  final TextEditingController? controller;
  final String? hint;

  const PasswordField({
    super.key,
    required this.obscureText,
    required this.onToggle,
    this.controller,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFA9EEFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint ?? "••••••••",
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.black45,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
