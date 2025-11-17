import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomFormField({Key? key, required this.controller, this.hint, this.keyboardType = TextInputType.text, this.validator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      builder: (FormFieldState<String> state) {
        return TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (v) => state.didChange(v),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.softBlue,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            suffixIcon: state.errorText != null
                ? GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(state.errorText ?? ''),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
                          ],
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
