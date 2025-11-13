import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class IncidentSummaryCard extends StatelessWidget {
  final int totalToday;
  final VoidCallback onReportNow;

  const IncidentSummaryCard({
    super.key,
    required this.totalToday,
    required this.onReportNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.06),
          )
        ],
      ),
      child: Row(
        children: [
          // Lado izquierdo: círculo con número
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryDark,
                      width: 3,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$totalToday',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Incidentes\nReportados Hoy',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          // Separador vertical
          Container(
            width: 1,
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.grey.withOpacity(0.3),
          ),
          // Lado derecho: botón "¡Reporta ahora!"
          Expanded(
            child: GestureDetector(
              onTap: onReportNow,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  '¡Reporta\nahora!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
