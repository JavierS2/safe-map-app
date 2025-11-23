import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _service = ReportService();

  bool loading = false;
  String? errorMessage;

  Future<bool> sendReport({
    required DateTime date,
    required String time,
    required String category,
    required String neighborhood,
    required String details,
    required double lat,
    required double lng,
    required List<String> evidences,
  }) async {
    try {
      loading = true;
      notifyListeners();

      final report = ReportModel(
        id: _service.generateId(),
        userId: _service.currentUserId,
        date: date,
        time: time,
        category: category,
        neighborhood: neighborhood,
        details: details,
        lat: lat,
        lng: lng,
        status: "pendiente",
        createdAt: DateTime.now(),
        evidences: evidences,
      );

      await _service.createReport(report);

      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      loading = false;
      errorMessage = "Error al enviar reporte: $e";
      notifyListeners();
      return false;
    }
  }
}
