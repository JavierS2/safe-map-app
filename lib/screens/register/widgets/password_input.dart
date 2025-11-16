import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const PasswordInput({
    super.key,
    required this.controller,
    this.validator,
  });

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
            child: TextFormField(
              controller: widget.controller,
              validator: widget.validator,
              obscureText: obscure,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "••••••••",
                hintStyle: TextStyle(fontFamily: 'Poppins'),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
                errorStyle: TextStyle(height: 0, fontSize: 0),
                errorMaxLines: 1,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => obscure = !obscure),
            child: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
          )
        ],
      ),
    );
  }
}
