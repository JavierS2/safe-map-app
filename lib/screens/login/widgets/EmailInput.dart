import 'package:flutter/material.dart';

class EmailInput extends StatelessWidget {
  const EmailInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFA9EEFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
        decoration: InputDecoration(
          hintText: "example@example.com",
          hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.black45),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
