import 'package:flutter/material.dart';

import 'widgets/date_input.dart';
import 'widgets/labeled_field.dart';
import 'widgets/password_input.dart';
import 'widgets/phone_input.dart';
import 'widgets/text_input.dart';
import 'widgets/validators.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<Register> {

  // ==============================
  // CONTROLADORES REALES QUE TU UI NECESITA
  // ==============================

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final birthCtrl = TextEditingController();    
  final barrioCtrl = TextEditingController();   
  final idCtrl = TextEditingController();       

  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();  

  // Form Key y flags
  final _formKey = GlobalKey<FormState>();
  bool _showErrors = false;

  // Fecha real convertida
  DateTime? birthDate;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    birthCtrl.dispose();
    barrioCtrl.dispose();
    idCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  // Convertir fecha del TextField → DateTime
  void _convertBirthDate() {
    if (birthCtrl.text.isEmpty) return;

    try {
      final parts = birthCtrl.text.split("/");
      birthDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (e) {
      birthDate = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

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

                              // NOMBRE
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

                              // EMAIL
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

                              // TELÉFONO & FECHA
                              Row(
                                children: [
                                  Expanded(
                                    child: LabeledField(
                                      label: "Teléfono",
                                      errorText: _showErrors
                                          ? Validators.validatePhone(phoneCtrl.text)
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
                                          ? Validators.validateDate(birthCtrl.text)
                                          : null,
                                      child: DateInput(
                                        controller: birthCtrl,
                                        validator: Validators.validateDate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // BARRIO & CÉDULA
                              Row(
                                children: [
                                  Expanded(
                                    child: LabeledField(
                                      label: "Barrio de Residencia",
                                      child: TextInput(
                                        controller: barrioCtrl,
                                        hint: "Bonda",
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: LabeledField(
                                      label: "Cédula",
                                      child: TextInput(
                                        controller: idCtrl,
                                        hint: "1234567890",
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // CONTRASEÑA
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

                              // CONFIRMAR CONTRASEÑA
                              LabeledField(
                                label: "Confirmar Contraseña",
                                errorText: _showErrors
                                    ? Validators.confirmPassword(
                                        passCtrl.text, confirmCtrl.text)
                                    : null,
                                child: PasswordInput(
                                  controller: confirmCtrl,
                                  validator: (v) =>
                                      Validators.confirmPassword(passCtrl.text, v),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // BOTÓN REGISTRARSE
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {

                                    _convertBirthDate();
                                    setState(() => _showErrors = true);

                                    if (!_formKey.currentState!.validate() ||
                                        birthDate == null) {
                                      return;
                                    }

                                    bool ok = await auth.registerUser(
                                      fullName: nameCtrl.text,
                                      email: emailCtrl.text,
                                      password: passCtrl.text,
                                      phone: phoneCtrl.text,
                                      birthDate: birthDate!,
                                      neighborhood: barrioCtrl.text,
                                      documentId: idCtrl.text,
                                    );

                                    if (ok) {
                                      Navigator.pushNamed(context, "/home");
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(auth.errorMessage ?? "Error"),
                                        ),
                                      );
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
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, "/login");
                                  },
                                  child: const Text(
                                    "¿Ya tienes una cuenta? Inicia sesión",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
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
