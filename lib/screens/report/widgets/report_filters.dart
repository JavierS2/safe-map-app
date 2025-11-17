import 'package:flutter/material.dart';
import 'filter_pill.dart';

class ReportFilters extends StatelessWidget {
  final String categoryLabel;
  final String neighborhoodLabel;
  final String dateLabel;
  final String timeLabel;
  final VoidCallback? onCategoryTap;
  final VoidCallback? onNeighborhoodTap;
  final VoidCallback? onDateTap;
  final VoidCallback? onTimeTap;

  const ReportFilters({
    required this.categoryLabel,
    required this.neighborhoodLabel,
    required this.dateLabel,
    required this.timeLabel,
    this.onCategoryTap,
    this.onNeighborhoodTap,
    this.onDateTap,
    this.onTimeTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterPill(icon: Icons.category_outlined, label: categoryLabel, onTap: onCategoryTap),
        FilterPill(icon: Icons.place_outlined, label: neighborhoodLabel, onTap: onNeighborhoodTap),
        FilterPill(icon: Icons.calendar_today_outlined, label: dateLabel, onTap: onDateTap),
        FilterPill(icon: Icons.access_time_outlined, label: timeLabel, onTap: onTimeTap),
      ],
    );
  }
}
