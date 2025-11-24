import 'package:flutter/material.dart';
import '../../../models/report_model.dart';
import '../../../theme/app_colors.dart';

class ReportDetailsSheet extends StatelessWidget {
  final ReportModel report;

  const ReportDetailsSheet({Key? key, required this.report}) : super(key: key);

  String _formatDateTime(DateTime t) {
    return '${t.day.toString().padLeft(2, '0')}.${t.month.toString().padLeft(2, '0')} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Widget _row(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: const Color.fromARGB(255, 155, 154, 154), borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Icon(Icons.report, size: 34, color: Colors.black54)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report.category, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                                child: Text(report.category, style: const TextStyle(color: AppColors.primary)),
                              ),
                            ]),
                            const SizedBox(height: 6),
                            // Brief description shown under the title area (compact)
                            Builder(builder: (_) {
                              final desc = report.details.trim();
                              final brief = desc.isNotEmpty
                                  ? (desc.length > 120 ? '${desc.substring(0, 120).trim()}…' : desc)
                                  : 'Sin descripción disponible.';
                              return Text(
                                brief,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, color: Colors.black54),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _row(Icons.location_on, report.neighborhood),
              const SizedBox(height: 8),
              _row(Icons.pin_drop, 'Lat: ${report.lat?.toStringAsFixed(5) ?? '-'}, Lng: ${report.lng?.toStringAsFixed(5) ?? '-'}'),
              const SizedBox(height: 8),
              _row(Icons.calendar_today, _formatDateTime(report.createdAt)),

              if (report.details.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(report.details, style: const TextStyle(fontSize: 14)),
              ],

              const SizedBox(height: 14),

              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Cerrar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
