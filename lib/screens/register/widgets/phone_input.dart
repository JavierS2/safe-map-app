import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      decoration: BoxDecoration(
        color: const Color(0xFFA9EEFF),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // static +57 prefix
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '+57',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          // input for the 10 digits
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              controller: controller,
              validator: validator,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '3001234567',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.black45,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
                errorStyle: TextStyle(height: 0, fontSize: 0),
                errorMaxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
