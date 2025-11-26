import 'package:flutter/material.dart';

import 'widgets/date_input.dart';
import 'widgets/labeled_field.dart';
import 'widgets/password_input.dart';
import 'widgets/phone_input.dart';
import 'widgets/text_input.dart';
import '../report/widgets/barrios_santa_marta.dart';
import 'widgets/validators.dart';

import 'package:provider/provider.dart';
import 'package:flutter/services.dart' as services;
import '../../providers/auth_provider.dart';
import '../../config/route_history.dart';
import '../../config/routes.dart';

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
                    const SizedBox(height: 8),
                    Container(
                      height: 96,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                  return;
                                }
                                final current = ModalRoute.of(context)?.settings.name;
                                final prev = appRouteObserver.previousMeaningfulRoute(current) ??
                                    (appRouteObserver.lastRoute != null && appRouteObserver.lastRoute != current
                                        ? appRouteObserver.lastRoute
                                        : null);
                                if (prev != null && prev.isNotEmpty && prev != current) {
                                  Navigator.pushReplacementNamed(context, prev);
                                  return;
                                }
                                Navigator.pushReplacementNamed(context, AppRoutes.home);
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const Center(
                            child: Text(
                              "Crea Tu Cuenta",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
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
                                label: "Nombre completo",
                                errorText: _showErrors
                                    ? Validators.validateName(nameCtrl.text)
                                    : null,
                                  child: TextInput(
                                  hint: "John Doe",
                                  controller: nameCtrl,
                                  validator: Validators.validateName,
                                  inputFormatters: [
                                    services.FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ\s]")),
                                  ],
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
                                      label: "Fecha de nacimiento",
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
                                      label: "Barrio de residencia",
                                      child: BarrioSearchField(controller: barrioCtrl, pillStyle: true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: LabeledField(
                                      label: "Cédula",
                                      child: TextInput(
                                          controller: idCtrl,
                                          hint: "1234567890",
                                          inputFormatters: [
                                            services.FilteringTextInputFormatter.digitsOnly,
                                            services.LengthLimitingTextInputFormatter(10),
                                          ],
                                          keyboardType: TextInputType.number,
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
                                label: "Confirmar contraseña",
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

                                    // Ensure neighborhood is provided
                                    if ((barrioCtrl.text.trim()).isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El barrio es requerido')));
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
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso. Revisa tu correo para confirmar tu cuenta.')));
                                      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
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
