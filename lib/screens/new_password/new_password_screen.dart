import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/route_history.dart';
import '../../config/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/confirm_button.dart';
import 'widgets/label_text.dart';
import 'widgets/password_field.dart';
import '../register/widgets/validators.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool obscurePass1 = true;
  bool obscurePass2 = true;
  String? _email;
  bool _sent = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _email = args['email'] as String?;
      _sent = args['sent'] as bool? ?? false;
    }
  }

  Future<void> _onChangePassword() async {
    // validate
    String code = _codeCtrl.text.trim();
    // if user pasted the full URL, try to extract oobCode
    final extracted = _extractCode(code);
    if (extracted != null && extracted.isNotEmpty) code = extracted;
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    final v1 = Validators.validatePassword(pass);
    final v2 = Validators.confirmPassword(pass, confirm);
    if (v1 != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(v1)));
      return;
    }
    if (v2 != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(v2)));
      return;
    }
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa el código enviado por correo o pega el enlace')));
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.confirmPasswordReset(code: code, newPassword: pass);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña cambiada correctamente')));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _extractCode(String input) {
    if (input.isEmpty) return null;
    // if looks like a URL, try parsing and getting oobCode param
    if (input.startsWith('http')) {
      try {
        final uri = Uri.parse(input);
        final code = uri.queryParameters['oobCode'] ?? uri.queryParameters['oobcode'] ?? uri.queryParameters['oob_code'];
        if (code != null && code.isNotEmpty) return code;
        // sometimes the full link is encoded in a continueUrl param
        final continueUrl = uri.queryParameters['continueUrl'] ?? uri.queryParameters['url'];
        if (continueUrl != null) {
          final u2 = Uri.tryParse(continueUrl);
          final c2 = u2?.queryParameters['oobCode'];
          if (c2 != null && c2.isNotEmpty) return c2;
        }
      } catch (_) {
        return null;
      }
    }
    // if it's already a code-like string, return as-is
    if (RegExp(r'^[-_A-Za-z0-9]+$').hasMatch(input)) return input;
    return null;
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Portapapeles vacío')));
      return;
    }
    final code = _extractCode(text) ?? text;
    _codeCtrl.text = code;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pegado desde portapapeles')));
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
                          const Center(
                            child: Text(
                              "Nueva Contraseña",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    if (_sent && _email != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Se envió un correo a $_email con instrucciones. Pega el enlace para cambiar la contraseña.', style: const TextStyle(color: Colors.black87), textAlign: TextAlign.center),
                      ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
                        decoration: const BoxDecoration(color: Color(0xFFFAFFFD), borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const LabelText('Código verificación'),
                          TextField(
                            controller: _codeCtrl,
                            decoration: InputDecoration(
                              hintText: 'Pega la URL completa',
                              filled: true,
                              fillColor: const Color(0xFFA9EEFF),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              suffixIcon: IconButton(icon: const Icon(Icons.paste), onPressed: _pasteFromClipboard),
                            ),
                          ),
                          const SizedBox(height: 18),

                          const LabelText('Nueva Contraseña'),
                          PasswordField(obscureText: obscurePass1, onToggle: () => setState(() => obscurePass1 = !obscurePass1), controller: _passCtrl),
                          const SizedBox(height: 18),

                          const LabelText('Confirmar Nueva Contraseña'),
                          PasswordField(obscureText: obscurePass2, onToggle: () => setState(() => obscurePass2 = !obscurePass2), controller: _confirmCtrl),
                          const SizedBox(height: 28),

                          ConfirmButton(label: _loading ? 'Cambiando...' : 'Cambiar Contraseña', onPressed: _loading ? () {} : () => _onChangePassword()),
                        ]),
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
