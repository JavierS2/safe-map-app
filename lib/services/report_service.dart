import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createReport(ReportModel report) async {
    await _db.collection("reports").doc(report.id).set(report.toMap());
  }

  String generateId() {
    return _db.collection("reports").doc().id;
  }

  String get currentUserId {
    return FirebaseFirestore.instance.app.options.projectId;
  }
}
