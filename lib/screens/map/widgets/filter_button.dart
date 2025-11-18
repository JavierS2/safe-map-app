import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class PositionedFilterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PositionedFilterButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      top: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Tooltip(
          message: 'Filtros',
          child: FloatingActionButton(
            heroTag: 'filters',
            mini: true,
            backgroundColor: AppColors.primary,
            onPressed: onPressed,
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
