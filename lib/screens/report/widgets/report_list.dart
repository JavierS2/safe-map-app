import 'package:flutter/material.dart';
import '../../../models/report_model.dart';
import 'report_result_card.dart';

class ReportList extends StatelessWidget {
  final List<ReportModel> reports;
  final void Function(ReportModel)? onTap;

  const ReportList({required this.reports, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reports.map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ReportResultCard(
            report: r,
            onTap: () => onTap?.call(r),
          ),
        );
      }).toList(),
    );
  }
}
