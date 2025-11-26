import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/register/widgets/validators.dart';
import 'widgets/title_section.dart';
import 'widgets/input_field.dart';
import 'widgets/next_button.dart';
import 'widgets/login_button.dart';
import 'widgets/register_link.dart';
import '../../config/route_history.dart';
import '../../config/routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // preserve original visual layout while wiring controllers
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _docCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _docCtrl.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    // basic validation: email format and cedula length
    final emailError = Validators.validateEmail(_emailCtrl.text.trim());
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }

    final ced = _docCtrl.text.trim();
    // cedula: numeric only and length between 6 and 20
    if (ced.isEmpty || !RegExp(r'^\d+$').hasMatch(ced) || ced.length < 6 || ced.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cédula inválida')));
      return;
    }

    setState(() => _loading = true);
    try {
      final email = _emailCtrl.text.trim();
      final docId = _docCtrl.text.trim();

      // Query Firestore for a user with matching email and documentId
      final qs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('documentId', isEqualTo: docId)
          .limit(1)
          .get();

      if (qs.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se encontró un usuario con esos datos')));
        setState(() => _loading = false);
        return;
      }

      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Navigate to new password screen with info
      Navigator.pushNamed(context, '/new-password', arguments: {'email': email, 'sent': true});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
                    const SizedBox(height: 20),
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
                          const Center(child: TitleSection()),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAFFFD),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Email",
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(height: 10),

                            InputField(hint: "example@example.com", controller: _emailCtrl, keyboardType: TextInputType.emailAddress),

                            const SizedBox(height: 25),

                            const Text(
                              "Cédula de ciudadanía",
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(height: 10),

                            InputField(hint: "1234567890", controller: _docCtrl, keyboardType: TextInputType.number),

                            const SizedBox(height: 30),

                            NextButton(onPressed: _loading ? null : _onNext),

                            const SizedBox(height: 25),

                            const Center(child: LoginButton()),

                            const SizedBox(height: 30),

                            const Center(child: RegisterLink()),

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
