import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a notification document for a specific user
  Future<void> _createNotificationForUser(String uid, Map<String, dynamic> data) async {
    final ref = _db.collection('users').doc(uid).collection('notifications').doc();
    await ref.set(data);
  }

  /// Find users that live in the same neighborhood (excluding the report author)
  Future<List<String>> _findUserIdsByNeighborhood(String neighborhood, {String? excludeUid}) async {
    final snap = await _db.collection('users').where('neighborhood', isEqualTo: neighborhood).get();
    final uids = <String>[];
    for (final d in snap.docs) {
      final uid = d.id;
      if (excludeUid != null && uid == excludeUid) continue;
      uids.add(uid);
    }
    return uids;
  }

  /// Notify relevant users when a new report is created.
  /// - Creates a notification for the report author (confirmation)
  /// - Creates notifications for users in the same neighborhood
  Future<void> notifyUsersForReport(ReportModel report) async {
    final now = Timestamp.now();

    // 1) Confirmation for author
    final authorNotif = {
      'title': 'Tu reporte fue registrado',
      'body': 'Hiciste un reporte: ${report.category} en ${report.neighborhood}.',
      'reportId': report.id,
      'createdAt': now,
      'read': false,
    };
    if (report.userId.isNotEmpty) {
      await _createNotificationForUser(report.userId, authorNotif);
    }

    // 2) Notify users in same neighborhood (exclude author)
    try {
      final uids = await _findUserIdsByNeighborhood(report.neighborhood, excludeUid: report.userId);
      final batch = _db.batch();
      for (final uid in uids) {
        final ref = _db.collection('users').doc(uid).collection('notifications').doc();
        batch.set(ref, {
          'title': 'Nuevo reporte en tu barrio',
          'body': '${report.category} reportado en ${report.neighborhood}.',
          'reportId': report.id,
          'createdAt': now,
          'read': false,
        });
      }
      if (uids.isNotEmpty) await batch.commit();
    } catch (e) {
      // ignore notification errors to not block report creation
    }

    // 3) Add a city-level broadcast notification (does not replace per-user notifications)
    try {
      await _db.collection('city_notifications').add({
        'title': 'Nuevo reporte en la ciudad',
        'body': '${report.category} reportado en ${report.neighborhood}.',
        'reportId': report.id,
        'neighborhood': report.neighborhood,
        'createdAt': now,
      });
    } catch (e) {
      // ignore errors here as well
    }
  }
}
