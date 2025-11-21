import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = false;
  String? errorMessage;

  // ===========================
  // CREAR REPORTE
  // ===========================
  Future<bool> createReport({
    required String userId,
    required DateTime date,
    required String time,
    required String category,
    required String neighborhood,
    required String details,
    double? lat,
    double? lng,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Crear ID único
      final id = _firestoreService.db.collection("reports").doc().id;

      // Modelo
      final report = ReportModel(
        id: id,
        userId: userId,
        date: date,
        time: time,
        category: category,
        neighborhood: neighborhood,
        details: details,
        lat: lat,
        lng: lng,
        createdAt: DateTime.now(),
      );

      // Guardar en Firestore
      await _firestoreService.saveReport(report);

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
}
