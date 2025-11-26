import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _service = ReportService();

  bool loading = false;
  String? errorMessage;
  int todayCount = 0;
  List<ReportModel> latestReports = [];
  List<ReportModel> allReports = [];
  ReportModel? lastViewedReport;
  // Monthly stats
  List<Map<String, String>> monthlyTopNeighborhoods = [];
  List<double> monthlyDonutValues = [];
  List<String> monthlyDonutLabels = [];
  List<String> monthlyDonutPercents = [];

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

      // determine current user id and the user's display name/full name if available
      final uid = _service.currentUserId;
      String? authorName;
      if (uid.isNotEmpty) {
        try {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            final ud = userDoc.data()! as Map<String, dynamic>;
            authorName = (ud['fullName'] ?? ud['displayName'] ?? ud['email'])?.toString();
          }
        } catch (_) {
          // fallback to FirebaseAuth displayName
          authorName = FirebaseAuth.instance.currentUser?.displayName;
        }
      } else {
        authorName = FirebaseAuth.instance.currentUser?.displayName;
      }

      final report = ReportModel(
        id: _service.generateId(),
        userId: uid,
        authorName: authorName,
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
      // After creating a report, refresh key views so UI (home screen)
      // shows the updated counts and latest reports in real-time.
      await fetchTodayCount();
      await fetchLatestReports(limit: 3);

      // Also insert into in-memory allReports if already loaded to keep
      // other views consistent without forcing a full reload.
      if (allReports.isNotEmpty) {
        allReports.insert(0, report);
      }

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

  /// Fetch number of reports created today and notify listeners
  Future<void> fetchTodayCount() async {
    try {
      final count = await _service.countReportsToday();
      todayCount = count;
      notifyListeners();
    } catch (e) {
      // ignore errors for now; keep previous value
    }
  }

  /// Fetch latest reports (limit) and store them
  Future<void> fetchLatestReports({int limit = 3}) async {
    try {
      final list = await _service.getLatestReports(limit);
      latestReports = list;
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }

  /// Fetch all reports from Firestore and store locally
  Future<void> fetchAllReports() async {
    try {
      final list = await _service.getAllReports();
      allReports = list;
      notifyListeners();
    } catch (e) {
      // ignore for now
    }
  }

  /// Fetch rankings for the specified month (defaults to current month)
  Future<void> fetchMonthlyStats({DateTime? forMonth}) async {
    try {
      final now = forMonth ?? DateTime.now();
      final year = now.year;
      final month = now.month;
      final reports = await _service.getReportsForMonth(year, month);

      // Neighborhood counts
      final Map<String, int> neighCounts = {};
      for (final r in reports) {
        final name = (r.neighborhood).trim();
        if (name.isEmpty) continue;
        neighCounts[name] = (neighCounts[name] ?? 0) + 1;
      }

      final sortedNeigh = neighCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      final List<Map<String, String>> topNeigh = [];
      for (var i = 0; i < sortedNeigh.length; i++) {
        final e = sortedNeigh[i];
        topNeigh.add({'rank': '${i + 1}', 'name': e.key, 'count': '${e.value}'});
      }

      // Hour buckets (4-hour buckets: 0..5)
      final Map<int, int> bucketCounts = {}; // bucket -> count
      for (final r in reports) {
        final local = r.date.toLocal();
        final hour = local.hour; // 0..23
        final bucket = hour ~/ 4; // 0..5
        bucketCounts[bucket] = (bucketCounts[bucket] ?? 0) + 1;
      }

      final totalBucket = bucketCounts.values.fold<int>(0, (p, e) => p + e);
      final sortedBuckets = bucketCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      // prepare donut values and labels for ALL buckets (not only top-3)
      final List<double> donutVals = [];
      final List<String> donutLabels = [];
      final List<String> donutPercs = [];

      // collect fractions and labels for every bucket in sorted order
      final List<double> fractions = [];
      for (var i = 0; i < sortedBuckets.length; i++) {
        final b = sortedBuckets[i];
        final cnt = b.value;
        final fraction = totalBucket > 0 ? (cnt / totalBucket) : 0.0;
        fractions.add(fraction);
        donutVals.add(fraction);
        final startHour = b.key * 4;
        final endHour = b.key * 4 + 3;
        final label = '${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:59';
        donutLabels.add(label);
      }

      // compute integer percentages that sum to 100 by distributing rounding remainder
      if (fractions.isEmpty) {
        for (var i = 0; i < donutVals.length; i++) {
          donutPercs.add('0%');
        }
      } else {
        final rawPercents = fractions.map((f) => f * 100.0).toList();
        final floored = rawPercents.map((r) => r.floor()).toList();
        int sumFloored = floored.fold<int>(0, (p, e) => p + e);
        int remainder = 100 - sumFloored;

        // indices sorted by fractional part descending
        final List<int> idxs = List<int>.generate(rawPercents.length, (i) => i);
        idxs.sort((a, b) {
          final fa = rawPercents[a] - floored[a];
          final fb = rawPercents[b] - floored[b];
          return fb.compareTo(fa);
        });

        // distribute +1 to the elements with largest fractional parts
        for (var j = 0; j < remainder; j++) {
          final ii = idxs[j % idxs.length];
          floored[ii] = floored[ii] + 1;
        }

        for (var v in floored) {
          donutPercs.add('${v}%');
        }
      }

      monthlyTopNeighborhoods = topNeigh;
      monthlyDonutValues = donutVals;
      monthlyDonutLabels = donutLabels;
      monthlyDonutPercents = donutPercs;
      notifyListeners();
    } catch (e) {
      // ignore for now
    }
  }

  /// Mark a report as viewed (used by UI to show 'último reporte visualizado')
  void viewReport(ReportModel r) {
    lastViewedReport = r;
    notifyListeners();
  }
}
