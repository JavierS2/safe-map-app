import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import '../report/widgets/report_header.dart';
import 'widgets/avatar_picker.dart';
import 'widgets/field_label.dart';
import 'widgets/custom_form_field.dart';
import 'widgets/phone_field.dart';
import 'widgets/action_buttons.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Layout tuning constants
  // Reduced avatar size to make it less dominant on the screen
  static const double _avatarSize = 92.0;
  final TextEditingController _nameController = TextEditingController(text: 'Eduardo Alfredo Lopez Ortega');
  final TextEditingController _phoneController = TextEditingController(text: '311 899 9504');
  final TextEditingController _emailController = TextEditingController(text: 'example@example.com');
  final TextEditingController _neighborhoodController = TextEditingController(text: 'Bonda');

  bool _pushNotifications = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(
        selectedRoute: AppRoutes.accountSettings,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Reserve space for the bottom nav so the panel doesn't extend behind it
              padding: const EdgeInsets.only(bottom: 68),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header (reuse ReportHeader style)
                      const ReportHeader(title: 'Editar Perfil'),
                      // extend blue so the white panel overlaps in the same way as other screens
                      Container(height: 48, color: AppColors.primary),

                      // White panel with overlapping avatar and form inside
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -32),
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFAFFFD),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40),
                                  ),
                                ),
                                // Added extra top padding so there's a small gap under the avatar
                                padding: EdgeInsets.fromLTRB(20, (_avatarSize / 2) + 28, 20, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 6),
                                    // Name and section title inside the form
                                    Center(
                                      child: Text(
                                        _nameController.text,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        'Configuración De Cuenta',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                                    ),

                                    // Form
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              FieldLabel('Nombre Completo'),
                                              CustomFormField(controller: _nameController, hint: 'Ingresa tu nombre', validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es requerido' : null),
                                              const SizedBox(height: 12),
                                              FieldLabel('Número Telefónico'),
                                              PhoneField(controller: _phoneController, validator: (v) {
                                                final value = _phoneController.text;
                                                if (value.trim().isEmpty) return 'El teléfono es requerido';
                                                if (value.replaceAll(RegExp(r"\s+"), '').length < 7) return 'Número inválido';
                                                return null;
                                              }),
                                              const SizedBox(height: 12),
                                              FieldLabel('Correo Electrónico'),
                                              CustomFormField(controller: _email_controller_fallback(), hint: 'example@example.com', keyboardType: TextInputType.emailAddress, validator: (v) { if (v == null || v.trim().isEmpty) return 'El email es requerido'; final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$"); if (!emailRegex.hasMatch(v)) return 'Email inválido'; return null; }),
                                              const SizedBox(height: 12),
                                              FieldLabel('Barrio De Residencia'),
                                              CustomFormField(controller: _neighborhoodController, hint: 'Barrio', validator: (v) => (v == null || v.trim().isEmpty) ? 'El barrio es requerido' : null),
                                              const SizedBox(height: 18),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Text('Push Notifications', style: TextStyle(fontSize: 14)),
                                                  Switch(
                                                    value: _pushNotifications,
                                                    onChanged: (v) => setState(() => _pushNotifications = v),
                                                    // Thumb should always be white; track white when off and blue when on
                                                    thumbColor: MaterialStateProperty.all(Colors.white),
                                                    trackColor: MaterialStateProperty.resolveWith((states) {
                                                      if (states.contains(MaterialState.selected)) {
                                                        return AppColors.primary;
                                                      }
                                                      return Colors.white;
                                                    }),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 18),
                                              SaveButton(
                                                onPressed: () {
                                                  if (_formKey.currentState?.validate() ?? false) {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado')));
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor corrige los errores')));
                                                  }
                                                },
                                              ),
                                              const SizedBox(height: 12),

                                              // Logout button: white background, red text, proportional to Save button
                                              LogoutButton(
                                                onPressed: () async {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) => AlertDialog(
                                                      title: const Text('Cerrar sesión'),
                                                      content: const Text('¿Estás seguro que quieres cerrar sesión?'),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                                                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red))),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirm == true) {
                                                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                                                  }
                                                },
                                              ),

                                              // removed extra bottom spacer; outer scroll now reserves nav height
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Avatar overlapping the panel (static)
                            Positioned(
                              top: -(_avatarSize / 2),
                              left: 0,
                              right: 0,
                              child: Center(
                                child: AvatarPicker(size: _avatarSize),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Fallback accessor for email controller to avoid accidental legacy name usage
  TextEditingController _email_controller_fallback() => _emailController;
  
}