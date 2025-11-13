import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class ReportItemData {
  final String neighborhood;
  final String dateTime;
  final String type;

  const ReportItemData({
    required this.neighborhood,
    required this.dateTime,
    required this.type,
  });
}

class ReportItemCard extends StatelessWidget {
  final ReportItemData data;
  final VoidCallback onDetailsPressed;

  const ReportItemCard({
    super.key,
    required this.data,
    required this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.04),
          )
        ],
      ),
      child: Row(
        children: [
          // Icono redondo
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.softBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 22,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 10),
          // Barrio + fecha
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.neighborhood,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.dateTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Tipo de incidente
          Expanded(
            flex: 2,
            child: Text(
              data.type,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón "Ver detalles"
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: onDetailsPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
              child: const Text(
                'Ver detalles',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
