import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createReport(ReportModel report) async {
    await _db.collection("reports").doc(report.id).set(report.toMap());
  }

  /// Count reports created today (local device date interpreted as firestore timestamps)
  Future<int> countReportsToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    final startTs = Timestamp.fromDate(start);
    final endTs = Timestamp.fromDate(end);

    final snap = await _db
        .collection('reports')
        .where('createdAt', isGreaterThanOrEqualTo: startTs)
        .where('createdAt', isLessThanOrEqualTo: endTs)
        .get();

    return snap.size;
  }

  /// Get latest reports limited by [limit], ordered by createdAt descending
  Future<List<ReportModel>> getLatestReports(int limit) async {
    final snap = await _db.collection('reports').orderBy('createdAt', descending: true).limit(limit).get();
    return snap.docs.map((d) => ReportModel.fromMap(d.id, d.data())).toList();
  }

  /// Get all reports ordered by createdAt descending
  Future<List<ReportModel>> getAllReports() async {
    final snap = await _db.collection('reports').orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => ReportModel.fromMap(d.id, d.data())).toList();
  }

  String generateId() {
    return _db.collection("reports").doc().id;
  }

  String get currentUserId {
    return FirebaseFirestore.instance.app.options.projectId;
  }
}
