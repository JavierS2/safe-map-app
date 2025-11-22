import 'package:flutter/material.dart';

class EmailInput extends StatelessWidget {
  final TextEditingController controller;

  const EmailInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFA9EEFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
        decoration: const InputDecoration(
          hintText: "example@example.com",
          hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.black45),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
