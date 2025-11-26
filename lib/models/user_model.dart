import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;        // String por reglas internacionales
  final DateTime birthDate;  // DateTime
  final String neighborhood;
  final String documentId;   // String por seguridad
  final String role;
  final DateTime createdAt;
  final String? profileImageUrl;
  final bool? pushEnabled;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.neighborhood,
    required this.documentId,
    required this.role,
    required this.createdAt,
    this.profileImageUrl,
    this.pushEnabled,
  });
  // Convertir Firestore → UserModel  
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      fullName: data['fullName'],
      email: data['email'],
      phone: data['phone'],
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      neighborhood: data['neighborhood'],
      documentId: data['documentId'],
      role: data['role'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'] as String?,
      pushEnabled: data['pushEnabled'] as bool? ?? true,
    );
  }
  // Convertir UserModel → Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'neighborhood': neighborhood,
      'documentId': documentId,
      'role': role,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
      'pushEnabled': pushEnabled,
    };
  }
}
