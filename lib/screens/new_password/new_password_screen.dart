import 'package:flutter/material.dart';

import 'widgets/confirm_button.dart';
import 'widgets/label_text.dart';
import 'widgets/password_field.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool obscurePass1 = true;
  bool obscurePass2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00CCFF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    const Text(
                      "Nueva Contraseña",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 40),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 30),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAFFFD),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Nueva contraseña
                            const LabelText("Nueva Contraseña"),
                            PasswordField(
                              obscureText: obscurePass1,
                              onToggle: () => setState(() =>
                                  obscurePass1 = !obscurePass1),
                            ),

                            const SizedBox(height: 25),

                            /// Confirmar contraseña
                            const LabelText("Confirmar Nueva Contraseña"),
                            PasswordField(
                              obscureText: obscurePass2,
                              onToggle: () => setState(() =>
                                  obscurePass2 = !obscurePass2),
                            ),

                            const SizedBox(height: 40),

                            /// BOTÓN
                            ConfirmButton(
                              label: "Cambiar Contraseña",
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
