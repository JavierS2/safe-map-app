import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import '../../services/cloudinary_service.dart';
import '../../services/cloudinary_uploader.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import '../report/widgets/report_header.dart';
import 'widgets/avatar_picker.dart';
import 'widgets/field_label.dart';
import 'widgets/custom_form_field.dart';
import 'widgets/phone_field.dart';
import 'widgets/action_buttons.dart';
import '../report/widgets/barrios_santa_marta.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Layout tuning constants
  static const double _avatarSize = 92.0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  XFile? _pickedImage;
  final CloudinaryService _cloudinary = CloudinaryService();
  bool _isSaving = false;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.fetchCurrentUserData();
      final user = auth.currentUserData;
      if (user != null) {
        setState(() {
          _nameController.text = user.fullName;
          _phoneController.text = user.phone;
          _emailController.text = user.email;
          _neighborhoodController.text = user.neighborhood;
          _pickedImage = null;
          _pushNotifications = user.pushEnabled ?? true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(
        selectedRoute: AppRoutes.accountSettings,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 68),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const ReportHeader(title: 'Editar Perfil'),
                          Container(height: 48, color: AppColors.primary),

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
                                    padding: EdgeInsets.fromLTRB(20, (_avatarSize / 2) + 28, 20, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 6),
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
                                            'Configuración de cuenta',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                          ),
                                        ),

                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Form(
                                              key: _formKey,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  FieldLabel('Nombre completo'),
                                                  CustomFormField(controller: _nameController, hint: 'Ingresa tu nombre', validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es requerido' : null),
                                                  const SizedBox(height: 12),
                                                  FieldLabel('Número telefónico'),
                                                  PhoneField(controller: _phoneController, validator: (v) {
                                                    final value = _phoneController.text;
                                                    if (value.trim().isEmpty) return 'El teléfono es requerido';
                                                    if (value.replaceAll(RegExp(r"\s+"), '').length < 7) return 'Número inválido';
                                                    return null;
                                                  }),
                                                  const SizedBox(height: 12),
                                                  FieldLabel('Correo electrónico'),
                                                  CustomFormField(controller: _email_controller_fallback(), hint: 'example@example.com', keyboardType: TextInputType.emailAddress, validator: (v) { if (v == null || v.trim().isEmpty) return 'El email es requerido'; final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$"); if (!emailRegex.hasMatch(v)) return 'Email inválido'; return null; }),
                                                  const SizedBox(height: 12),
                                                  FieldLabel('Barrio de residencia'),
                                                  // use the BarrioSearchField but render as a pill like Register,
                                                  // adjusted to match account settings colors and radii
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    child: BarrioSearchField(
                                                      controller: _neighborhoodController,
                                                      pillStyle: true,
                                                      pillColor: AppColors.softBlue,
                                                      pillRadius: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 18),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      const Text('Push Notifications', style: TextStyle(fontSize: 14)),
                                                      Switch(
                                                        value: _pushNotifications,
                                                        onChanged: (v) => setState(() => _pushNotifications = v),
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
                                                    isLoading: _isSaving,
                                                    onPressed: () async {
                                                      if (_isSaving) return;
                                                      if (!(_formKey.currentState?.validate() ?? false)) {
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor corrige los errores')));
                                                        return;
                                                      }
                                                        // Ensure neighborhood is set (BarrioSearchField isn't a FormField)
                                                        if ((_neighborhoodController.text.trim()).isEmpty) {
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El barrio es requerido')));
                                                          return;
                                                        }

                                                      setState(() => _isSaving = true);

                                                      // Save pressed

                                                      final auth = Provider.of<AuthProvider>(context, listen: false);
                                                      String? uploadedUrl;
                                                      try {
                                                        if (_pickedImage != null) {
                                                          if (kIsWeb) {
                                                            final bytes = await _pickedImage!.readAsBytes();
                                                            // picked bytes length available if needed for diagnostics
                                                            if (bytes.length > 1024 * 1024) {
                                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La imagen excede el tamaño máximo de 1 MB')));
                                                              setState(() => _isSaving = false);
                                                              return;
                                                            }
                                                            // Upload from web directly to Cloudinary via browser POST (no extra packages)
                                                            uploadedUrl = await uploadBytesToCloudinary(bytes, _pickedImage!.name, folder: 'users/${auth.currentUser?.uid ?? 'unknown'}');
                                                          } else {
                                                            final file = File(_pickedImage!.path);
                                                            final size = await file.length();
                                                            // file size checked above
                                                            if (size > 1024 * 1024) {
                                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La imagen excede el tamaño máximo de 1 MB')));
                                                              setState(() => _isSaving = false);
                                                              return;
                                                            }
                                                            // Upload native files to Cloudinary (existing account uses Cloudinary)
                                                            uploadedUrl = await _cloudinary.uploadFile(file: file, isVideo: false, folder: 'users/${auth.currentUser?.uid ?? 'unknown'}');
                                                          }
                                                        }
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error subiendo imagen: $e')));
                                                      }

                                                      final success = await auth.updateProfile(
                                                        fullName: _nameController.text.trim(),
                                                        phone: _phoneController.text.trim(),
                                                        neighborhood: _neighborhoodController.text.trim(),
                                                        email: _emailController.text.trim(),
                                                        profileImageUrl: uploadedUrl,
                                                        pushEnabled: _pushNotifications,
                                                      );
                                                      

                                                      if (success) {
                                                        await auth.fetchCurrentUserData();
                                                        final updated = auth.currentUserData;
                                                        if (updated != null) {
                                                          setState(() {
                                                            _nameController.text = updated.fullName;
                                                            _phoneController.text = updated.phone;
                                                            _emailController.text = updated.email;
                                                            _neighborhoodController.text = updated.neighborhood;
                                                            _pickedImage = null;
                                                          });
                                                        }
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
                                                      } else {
                                                        print('auth.updateProfile failed: ${auth.errorMessage}');
                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Error al actualizar')));
                                                      }
                                                      setState(() => _isSaving = false);
                                                    },
                                                  ),
                                                  const SizedBox(height: 12),

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
                                                        final auth = Provider.of<AuthProvider>(context, listen: false);
                                                        await auth.logout();
                                                        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                                                      }
                                                    },
                                                  ),

                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Positioned(
                                  top: -(_avatarSize / 2),
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: AvatarPicker(
                                      size: _avatarSize,
                                      imageUrl: auth.currentUserData?.profileImageUrl,
                                      onImageChanged: (file) => setState(() => _pickedImage = file),
                                    ),
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

            if (auth.isLoading) ...[
              Positioned.fill(child: ModalBarrier(color: Colors.black26, dismissible: false)),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  TextEditingController _email_controller_fallback() => _emailController;
  
}