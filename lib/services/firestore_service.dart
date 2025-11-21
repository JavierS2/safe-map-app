import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
    FirebaseFirestore get db => _db;
  // ======================================================
  // USUARIOS
  // ======================================================

  // Crear o guardar usuario
  Future<void> saveUser(UserModel user) async {
    await _db.collection("users").doc(user.uid).set(user.toMap());
  }

  // Leer usuario por UID
Future<Map<String, dynamic>?> getUser(String uid) async {
  final doc = await _db.collection("users").doc(uid).get();
  if (!doc.exists) return null;
  return doc.data(); 
}


  // Actualizar usuario
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection("users").doc(uid).update(data);
  }

  // Eliminar usuario
  Future<void> deleteUser(String uid) async {
    await _db.collection("users").doc(uid).delete();
  }

  // ======================================================
  // REPORTES
  // ======================================================

  // Crear reporte
  Future<void> saveReport(ReportModel report) async {
    await _db.collection("reports").doc(report.id).set(report.toMap());
  }

  // Obtener todos los reportes
  Stream<List<ReportModel>> getReports() {
    return _db
        .collection("reports")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Obtener reportes por usuario
  Stream<List<ReportModel>> getReportsByUser(String uid) {
    return _db
        .collection("reports")
        .where("userId", isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Actualizar estado del reporte
  Future<void> updateReportStatus(String reportId, String status) async {
    await _db.collection("reports").doc(reportId).update({
      "status": status,
    });
  }

  // Eliminar reporte
  Future<void> deleteReport(String reportId) async {
    await _db.collection("reports").doc(reportId).delete();
  }

}
