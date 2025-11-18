import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class PositionedMapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenter;

  const PositionedMapControls({
    Key? key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 160,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Acercar',
              child: FloatingActionButton(
                heroTag: 'zoom_in',
                mini: true,
                backgroundColor: AppColors.primary,
                onPressed: onZoomIn,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Tooltip(
              message: 'Alejar',
              child: FloatingActionButton(
                heroTag: 'zoom_out',
                mini: true,
                backgroundColor: AppColors.primary,
                onPressed: onZoomOut,
                child: const Icon(Icons.remove, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Tooltip(
              message: 'Mi ubicación',
              child: FloatingActionButton(
                heroTag: 'center',
                mini: true,
                backgroundColor: AppColors.primary,
                onPressed: onCenter,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
