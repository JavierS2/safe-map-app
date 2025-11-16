import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({super.key});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFA9EEFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              obscureText: obscure,
              style: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
              decoration: const InputDecoration(
                hintText: "••••••••",
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => obscure = !obscure),
            child: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
