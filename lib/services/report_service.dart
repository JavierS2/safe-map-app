import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_model.dart';
import 'notification_service.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createReport(ReportModel report) async {
    await _db.collection("reports").doc(report.id).set(report.toMap());
    // After saving the report, create notifications for relevant users
    try {
      final notif = NotificationService();
      await notif.notifyUsersForReport(report);
    } catch (e) {
      // do not block report creation on notification failures
    }
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

  /// Get reports whose `date` field falls within the given month (year, month)
  Future<List<ReportModel>> getReportsForMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = (month < 12) ? DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1)) : DateTime(year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
    final startTs = Timestamp.fromDate(start);
    final endTs = Timestamp.fromDate(end);

    final snap = await _db.collection('reports').where('date', isGreaterThanOrEqualTo: startTs).where('date', isLessThanOrEqualTo: endTs).get();
    return snap.docs.map((d) => ReportModel.fromMap(d.id, d.data())).toList();
  }

  String generateId() {
    return _db.collection("reports").doc().id;
  }

  String get currentUserId {
    // Return the currently authenticated Firebase user's UID when available.
    try {
      final u = FirebaseAuth.instance.currentUser;
      return u?.uid ?? '';
    } catch (_) {
      return '';
    }
  }
}
