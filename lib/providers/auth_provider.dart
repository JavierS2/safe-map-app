import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = false;
  bool isUpdatingProfile = false;
  String? errorMessage;
  UserModel? currentUserData;

  // Usuario actual de Firebase
  get currentUser => _authService.currentUser;

  // ===========================
  // REGISTRO
  // ===========================
  Future<bool> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required DateTime birthDate,
    required String neighborhood,
    required String documentId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // 1. Registrar en Firebase Auth
      final firebaseUser = await _authService.registerUser(email, password);
      if (firebaseUser == null) {
        errorMessage = "Error creando usuario.";
        isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Crear modelo de usuario
      final user = UserModel(
        uid: firebaseUser.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        birthDate: birthDate,
        neighborhood: neighborhood,
        documentId: documentId,
        role: "ciudadano",
        createdAt: DateTime.now(),
        pushEnabled: true,
      );

      

      // 3. Guardarlo en Firestore
      await _firestoreService.saveUser(user);

      // 4. Enviar correo de verificación si es posible
      try {
        await firebaseUser.sendEmailVerification();
      } catch (_) {
        // no bloquear el registro si el envío falla; el frontend mostrará instrucciones
      }

      isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }



  }

  // ===========================
  // LOGIN
  // ===========================
 Future<bool> login(String email, String password) async {
  try {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // 1. Login Firebase Auth
    final user = await _authService.loginUser(email, password);
    if (user == null) {
      errorMessage = "Credenciales incorrectas";
      isLoading = false;
      notifyListeners();
      return false;
    }

    // Ensure email is verified. Firebase allows signing in with unverified
    // emails by default, so we must enforce it here if the app requires
    // verified accounts.
    try {
      await user.reload(); // refresh emailVerified status
    } catch (_) {
      // ignore reload errors
    }
    final refreshed = _authService.currentUser ?? user;
    if (!refreshed.emailVerified) {
      // Sign out the unverified user to avoid leaving an unauthenticated state
      try {
        await _authService.logout();
      } catch (_) {}
      errorMessage = "Por favor confirma tu correo antes de iniciar sesión.";
      isLoading = false;
      notifyListeners();
      return false;
    }

    // 2. Obtener datos Firestore (Map)
    final data = await _firestoreService.getUser(user.uid);
    if (data == null) {
      errorMessage = "El usuario no tiene perfil en Firestore.";
      isLoading = false;
      notifyListeners();
      return false;
    }

    // 3. Convertir Map -> UserModel
    currentUserData = UserModel.fromMap(data);

    isLoading = false;
    notifyListeners();
    return true;

  } catch (e) {
    errorMessage = "Email o contraseña incorrectos";
    isLoading = false;
    notifyListeners();
    return false;
  }

  }

  /// Attempt to resend the verification email by signing in, sending the
  /// verification, and signing out again. Returns true on success.
  Future<bool> resendVerificationEmail(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final user = await _authService.loginUser(email, password);
      if (user == null) {
        errorMessage = 'Credenciales incorrectas';
        isLoading = false;
        notifyListeners();
        return false;
      }

      try {
        await user.sendEmailVerification();
      } catch (e) {
        // ignore send errors but report failure
        errorMessage = 'Error enviando correo de verificación';
        await _authService.logout();
        isLoading = false;
        notifyListeners();
        return false;
      }

      await _authService.logout();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch current user document from Firestore and populate `currentUserData`.
  Future<void> fetchCurrentUserData() async {
    try {
      isLoading = true;
      notifyListeners();
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) {
        isLoading = false;
        notifyListeners();
        return;
      }
      final data = await _firestoreService.getUser(firebaseUser.uid);
      if (data == null) {
        isLoading = false;
        notifyListeners();
        return;
      }
      currentUserData = UserModel.fromMap(data);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Update current user's profile fields in Firestore and locally.
  Future<bool> updateProfile({required String fullName, required String phone, required String neighborhood, String? email, String? profileImageUrl, bool? pushEnabled}) async {
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null || currentUserData == null) return false;

      isUpdatingProfile = true;
      notifyListeners();

      final uid = firebaseUser.uid;

      final Map<String, dynamic> data = {
        'fullName': fullName,
        'phone': phone,
        'neighborhood': neighborhood,
      };

      // If email needs update in Firestore profile (not Auth), include it
      if (email != null && email.trim().isNotEmpty) {
        data['email'] = email.trim();
      }
      if (profileImageUrl != null && profileImageUrl.trim().isNotEmpty) {
        data['profileImageUrl'] = profileImageUrl.trim();
      }
      if (pushEnabled != null) {
        data['pushEnabled'] = pushEnabled;
      }

      await _firestoreService.updateUser(uid, data);

      // update local model preserving other fields
      currentUserData = UserModel(
        uid: currentUserData!.uid,
        fullName: fullName,
        email: email ?? currentUserData!.email,
        profileImageUrl: profileImageUrl ?? currentUserData!.profileImageUrl,
        phone: phone,
        birthDate: currentUserData!.birthDate,
        neighborhood: neighborhood,
        documentId: currentUserData!.documentId,
        role: currentUserData!.role,
        createdAt: currentUserData!.createdAt,
        pushEnabled: pushEnabled ?? currentUserData!.pushEnabled,
      );

      isUpdatingProfile = false;
      notifyListeners();
      return true;
    } catch (e) {
      isUpdatingProfile = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===========================
  // LOGOUT
  // ===========================
  /// Logout but ensure the `isLoading` spinner is visible for a minimum
  /// duration so the UI has time to show the loading indicator.
  Future<void> logout() async {
    const minVisible = Duration(milliseconds: 600);
    final start = DateTime.now();
    try {
      isLoading = true;
      notifyListeners();
      await _authService.logout();
      final elapsed = DateTime.now().difference(start);
      if (elapsed < minVisible) {
        await Future.delayed(minVisible - elapsed);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}
