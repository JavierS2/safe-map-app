import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;               // ID generado para Firestore
  final String userId;           // UID del usuario que creó el reporte
  final DateTime date;           // Fecha del incidente
  final String time;             // Hora en texto (ej: "11:45 PM")
  final String category;         // Categoría (Hurto, Robo, etc.)
  final String neighborhood;     // Barrio escogido por el usuario
  final String details;          // Descripción del incidente
  final double? lat;             // Latitud (opcional si usuario no está en el lugar)
  final double? lng;             // Longitud
  final String status;           // pendiente, validado, en proceso, cerrado
  final DateTime createdAt;      // Registro del momento en que se creó
  final String? authorName;      // Nombre completo del autor al momento de crear
  final List<String>? evidences; // URLs de evidencias (Cloudinary)

  ReportModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.category,
    required this.neighborhood,
    required this.details,
    this.lat,
    this.lng,
    this.status = "pendiente",
    required this.createdAt,
    this.authorName,
    this.evidences,
  });

  // Convertir Firestore → ReportModel
  factory ReportModel.fromMap(String id, Map<String, dynamic> data) {
    return ReportModel(
      id: id,
      userId: data['userId'],
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'],
      category: data['category'],
      neighborhood: data['neighborhood'],
      details: data['details'],
      lat: data['lat']?.toDouble(),
      lng: data['lng']?.toDouble(),
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      authorName: data['authorName'] as String?,
      evidences: (data['evidences'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  // Convertir ReportModel → Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'time': time,
      'category': category,
      'neighborhood': neighborhood,
      'details': details,
      'lat': lat,
      'lng': lng,
      'status': status,
      'createdAt': createdAt,
      'authorName': authorName,
      'evidences': evidences ?? [],
    };
  }
}