import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../models/report_model.dart';

class ReportInfoCard extends StatelessWidget {
  final ReportModel report;
  final String? authorName;
  const ReportInfoCard({Key? key, required this.report, this.authorName}) : super(key: key);

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  String _shortenId(String id) {
    if (id.length <= 10) return id;
    return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }

  Widget _infoRow(IconData icon, String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayAuthor = (authorName != null && authorName!.isNotEmpty)
        ? (() {
            final parts = authorName!.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
            if (parts.isEmpty) return null;
            if (parts.length == 1) return _capitalize(parts.first);
            return '${_capitalize(parts.first)} ${_capitalize(parts.last)}';
          })()
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: Text(report.category, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)))],),
          const SizedBox(height: 8),
          _infoRow(Icons.person_outline, 'Reportado por', displayAuthor ?? (report.userId.isNotEmpty ? _shortenId(report.userId) : 'Usuario'), context),
          const SizedBox(height: 4),
          _infoRow(Icons.calendar_today_outlined, 'Fecha',
              '${report.date.day.toString().padLeft(2, '0')}/${report.date.month.toString().padLeft(2, '0')}/${report.date.year} - ${report.time}',
              context),
          _infoRow(Icons.place_outlined, 'Barrio', report.neighborhood, context),
          if (report.lat != null && report.lng != null)
            _infoRow(Icons.location_pin, 'Coordenadas', '${report.lat!.toStringAsFixed(6)}, ${report.lng!.toStringAsFixed(6)}', context),
        ],
      ),
    );
  }
}
