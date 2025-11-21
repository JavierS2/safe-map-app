import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = false;
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
      );

      

      // 3. Guardarlo en Firestore
      await _firestoreService.saveUser(user);

      print(">>> INICIANDO REGISTRO");
      print("Datos recibidos:");
      print("Nombre: $fullName");
      print("Email: $email");
      print("Password: $password");
      print("Teléfono: $phone");
      print("Barrio: $neighborhood");
      print("Cédula: $documentId");
      print("Fecha nacimiento: $birthDate");


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

  // ===========================
  // LOGOUT
  // ===========================
  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
