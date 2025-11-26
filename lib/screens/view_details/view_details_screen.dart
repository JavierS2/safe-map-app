import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import '../report/widgets/report_header.dart';
import '../../models/report_model.dart';
import 'widgets/report_info_card.dart';
import 'widgets/evidence_carousel.dart';
import 'widgets/description_card.dart';

class ViewDetailsScreen extends StatefulWidget {
  const ViewDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ViewDetailsScreen> createState() => _ViewDetailsScreenState();
}

class _ViewDetailsScreenState extends State<ViewDetailsScreen> {
  ReportModel? _report;
  String? _authorName;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? reportId;

      if (args is Map && args['reportId'] != null) {
        reportId = args['reportId'] as String;
      } else if (args is String) {
        reportId = args;
      }

      if (reportId == null || reportId.isEmpty) {
        setState(() {
          _error = 'Reporte inválido';
          _loading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('reports').doc(reportId).get();
      if (!doc.exists || doc.data() == null) {
        setState(() {
          _error = 'Reporte no encontrado';
          _loading = false;
        });
        return;
      }

      final data = doc.data()! as Map<String, dynamic>;
      final report = ReportModel.fromMap(doc.id, data);

      // Prefer embedded authorName in the report document (saved at creation time).
      // If not present, fall back to reading users/{userId} and normalizing.
      String? authorName = report.authorName;
      if (authorName != null && authorName.isNotEmpty) {
        authorName = authorName.trim();
        final parts = authorName.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
        if (parts.isEmpty) {
          authorName = null;
        } else if (parts.length == 1) {
          authorName = '${parts.first[0].toUpperCase()}${parts.first.substring(1).toLowerCase()}';
        } else {
          authorName = '${parts.first[0].toUpperCase()}${parts.first.substring(1).toLowerCase()} ${parts.last[0].toUpperCase()}${parts.last.substring(1).toLowerCase()}';
        }
      } else {
        try {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(report.userId).get();
          if (userDoc.exists && userDoc.data() != null) {
            final ud = userDoc.data()! as Map<String, dynamic>;
            String? raw = (ud['fullName'] ?? ud['displayName'] ?? ud['email'])?.toString();
            if (raw != null && raw.isNotEmpty) {
              raw = raw.trim();
              if (raw.contains('@')) {
                raw = raw.split('@').first.replaceAll(RegExp(r'[._]+'), ' ');
              }
              final parts = raw.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
              if (parts.isEmpty) {
                authorName = null;
              } else if (parts.length == 1) {
                authorName = '${parts.first[0].toUpperCase()}${parts.first.substring(1).toLowerCase()}';
              } else {
                authorName = '${parts.first[0].toUpperCase()}${parts.first.substring(1).toLowerCase()} ${parts.last[0].toUpperCase()}${parts.last.substring(1).toLowerCase()}';
              }
            }
          }
        } catch (_) {
          authorName = null;
        }
      }

      setState(() {
        _report = report;
        _authorName = authorName;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando reporte';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // allow the body to extend beneath the bottom navigation bar
      extendBody: true,
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(selectedRoute: AppRoutes.viewDetails),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ReportHeader(title: 'Detalles del reporte'),
            Container(height: 48, color: AppColors.primary),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -32),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFFFD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 8),
                                  ReportInfoCard(report: _report!, authorName: _authorName),
                                  const SizedBox(height: 12),
                                  EvidenceCarousel(evidences: _report?.evidences),
                                  const SizedBox(height: 12),
                                  DescriptionCard(description: _report!.details),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                          onPressed: () {
                                            if (_report != null && _report!.lat != null && _report!.lng != null) {
                                              Navigator.pushNamed(context, AppRoutes.map, arguments: {'reportId': _report!.id});
                                            } else {
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 12),
                                            child: Text('Ver en el mapa', style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// Fullscreen viewers are provided in widgets/fullscreen_viewers.dart
