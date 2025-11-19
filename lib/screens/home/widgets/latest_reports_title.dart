import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class LatestReportsTitle extends StatelessWidget {
  const LatestReportsTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Últimos reportes',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
      ),
    );
  }
}
