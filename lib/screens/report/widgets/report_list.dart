import 'package:flutter/material.dart';
import 'report_result_card.dart';

class ReportList extends StatelessWidget {
  final List<Map<String, String>> reports;
  final void Function(Map<String, String>)? onTap;

  const ReportList({required this.reports, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reports.map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ReportResultCard(
            title: r['type'] ?? '',
            neighborhood: r['neighborhood'] ?? '',
            dateTime: r['dateTime'] ?? '',
            description: r['description'] ?? 'Arrebato de celular en zona turística.',
            onTap: () => onTap?.call(r),
          ),
        );
      }).toList(),
    );
  }
}
