import 'package:flutter/material.dart';

import 'widgets/date_input.dart';
import 'widgets/labeled_field.dart';
import 'widgets/password_input.dart';
import 'widgets/phone_input.dart';
import 'widgets/text_input.dart';
import 'widgets/validators.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<Register> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final birthCtrl = TextEditingController();
  final barrioCtrl = TextEditingController();
  final idCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _showErrors = false;

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
                    const SizedBox(height: 70),
                    const Text(
                      "Crea Tu Cuenta",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAFFFD),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60),
                          ),
                        ),
                        padding: const EdgeInsets.all(30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              LabeledField(
                                label: "Nombre Completo",
                                errorText: _showErrors
                                    ? Validators.validateName(nameCtrl.text)
                                    : null,
                                child: TextInput(
                                  hint: "John Doe",
                                  controller: nameCtrl,
                                  validator: Validators.validateName,
                                ),
                              ),

                              LabeledField(
                                label: "Email",
                                errorText: _showErrors
                                    ? Validators.validateEmail(emailCtrl.text)
                                    : null,
                                child: TextInput(
                                  hint: "example@example.com",
                                  controller: emailCtrl,
                                  validator: Validators.validateEmail,
                                ),
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: LabeledField(
                                      label: "Teléfono",
                                      errorText: _showErrors
                                          ? Validators.validatePhone(
                                              phoneCtrl.text)
                                          : null,
                                      child: PhoneInput(
                                        controller: phoneCtrl,
                                        validator: Validators.validatePhone,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: LabeledField(
                                      label: "Fecha de Nacimiento",
                                      errorText: _showErrors
                                          ? Validators.validateDate(
                                              birthCtrl.text)
                                          : null,
                                      child: DateInput(
                                        controller: birthCtrl,
                                        validator: Validators.validateDate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: LabeledField(
                                      label: "Barrio De Residencia",
                                      // no validator provided; leave errorText null
                                      child: TextInput(
                                        hint: "Bonda",
                                        controller: barrioCtrl,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: LabeledField(
                                      label: "Cédula De Ciudadanía",
                                      // no id validator provided
                                      child: TextInput(
                                        hint: "1234567890",
                                        controller: idCtrl,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              LabeledField(
                                label: "Contraseña",
                                errorText: _showErrors
                                    ? Validators.validatePassword(passCtrl.text)
                                    : null,
                                child: PasswordInput(
                                  controller: passCtrl,
                                  validator: Validators.validatePassword,
                                ),
                              ),

                              LabeledField(
                                label: "Confirmar Contraseña",
                                errorText: _showErrors
                                    ? Validators.confirmPassword(
                                        passCtrl.text, confirmCtrl.text)
                                    : null,
                                child: PasswordInput(
                                  controller: confirmCtrl,
                                  validator: (v) =>
                                      Validators.confirmPassword(
                                          passCtrl.text, v),
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showErrors = true;
                                      });
                                      if (_formKey.currentState!.validate()) {
                                        debugPrint("Formulario válido");
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00CCFF),
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "Registrarse",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),),

                              const SizedBox(height: 20),

                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  child: const Text(
                                    "¿Ya tienes una cuenta? Inicia Sesión",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
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
