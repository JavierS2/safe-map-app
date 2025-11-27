import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Provider
import 'package:safe_map_application/providers/auth_provider.dart';

// Rutas nombradas
import 'package:safe_map_application/config/routes.dart';

// Widgets personalizados
import 'widgets/EmailInput.dart';
import 'widgets/password_field.dart';
import 'widgets/forgot_password_link.dart';
import 'widgets/register_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para obtener email y contraseña
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00CCFF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    const Text(
                      "Inicia Sesión",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

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
                          children: [
                            const Text(
                              "Email",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// Campo email con controller
                            EmailInput(controller: emailCtrl),

                            const SizedBox(height: 25),

                            const Text(
                              "Contraseña",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// Campo contraseña con controller
                            PasswordInput(controller: passwordCtrl),

                            const SizedBox(height: 30),

                            // BOTÓN INICIAR SESIÓN (muestra carga cuando auth.isLoading)
                            SizedBox(
                              width: double.infinity,
                              child: Consumer<AuthProvider>(builder: (context, auth, _) {
                                return ElevatedButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () async {
                                          final success = await auth.login(
                                            emailCtrl.text.trim(),
                                            passwordCtrl.text.trim(),
                                          );

                                          if (!success) {
                                            // If failure due to unverified email, show dialog with resend option
                                            if (auth.errorMessage != null && auth.errorMessage!.contains('confirma tu correo')) {
                                              // Show dialog offering to resend verification
                                              showDialog<void>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Email no verificado'),
                                                  content: const Text('Tu correo no ha sido verificado. ¿Deseas reenviar el correo de verificación?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(ctx).pop(),
                                                      child: const Text('Cerrar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(ctx).pop();
                                                        final ok = await auth.resendVerificationEmail(emailCtrl.text.trim(), passwordCtrl.text.trim());
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text(ok ? 'Correo de verificación reenviado' : (auth.errorMessage ?? 'Error enviando correo'))),
                                                        );
                                                      },
                                                      child: const Text('Reenviar'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    auth.errorMessage ?? "Error al iniciar sesión",
                                                  ),
                                                ),
                                              );
                                            }
                                            return;
                                          }

                                          // Redirige SIEMPRE a home
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            AppRoutes.home,
                                            (_) => false,
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00CCFF),
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Iniciar Sesión",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                );
                              }),
                            ),

                            const SizedBox(height: 18),

                            const Center(
                              child: ForgotPasswordLink(),
                            ),

                            const SizedBox(height: 30),

                            const Center(
                              child: RegisterButton(),
                            ),

                            const SizedBox(height: 40),
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
