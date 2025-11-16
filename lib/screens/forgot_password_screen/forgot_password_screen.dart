import 'package:flutter/material.dart';

import 'widgets/input_field.dart';
import 'widgets/login_button.dart';
import 'widgets/next_button.dart';
import 'widgets/register_link.dart';
import 'widgets/title_section.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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

                    const TitleSection(),

                    const SizedBox(height: 60),

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
                          children: const [
                            Text(
                              "Email",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),

                            InputField(hint: "example@example.com"),

                            SizedBox(height: 25),

                            Text(
                              "Cédula De Ciudadanía",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),

                            InputField(hint: "1234567890"),

                            SizedBox(height: 30),

                            NextButton(),

                            SizedBox(height: 25),

                            Center(child: LoginButton()),

                            SizedBox(height: 30),

                            Center(child: RegisterLink()),

                            SizedBox(height: 40),
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
