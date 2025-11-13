import 'package:flutter/material.dart';

class PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const PhoneInput({
    super.key,
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
        keyboardType: TextInputType.phone,
        controller: controller,
        validator: validator,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "+573001234567",
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black45,
          ),
        ),
      ),
    );
  }
}
