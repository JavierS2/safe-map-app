import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../models/report_model.dart';

class ReportResultCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;

  const ReportResultCard({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.softBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // left image / marker or evidence thumbnail
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: report.evidences != null && report.evidences!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        report.evidences!.first,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, e, st) => const Icon(Icons.broken_image, color: AppColors.primaryDark),
                      ),
                    )
                  : const Icon(Icons.location_on_outlined, color: AppColors.primaryDark, size: 30),
            ),
            const SizedBox(width: 12),
            // main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report.category,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          report.neighborhood,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '${report.date.day.toString().padLeft(2, '0')}/${report.date.month.toString().padLeft(2, '0')}/${report.date.year} - ${report.time}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.details,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // chevron placed to the right and vertically centered
            Center(
              child: Icon(Icons.chevron_right_rounded, color: AppColors.primaryDark),
            ),
          ],
        ),
      ),
    );
  }
}
