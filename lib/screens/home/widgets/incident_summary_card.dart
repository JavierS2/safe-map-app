import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../theme/app_colors.dart';

class IncidentSummaryCard extends StatelessWidget {
  final int totalToday;
  final VoidCallback onReportNow;
  final Color backgroundColor;

  const IncidentSummaryCard({
    super.key,
    required this.totalToday,
    required this.onReportNow,
    this.backgroundColor = AppColors.cardBackground,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkBg = backgroundColor.computeLuminance() < 0.5;
    // If the card is dark (e.g. AppColors.primary) the circle should match
    // the card background (no darker fill), keep the border as accent.
    final Color circleBg = isDarkBg ? backgroundColor : AppColors.primary.withOpacity(0.08);
    final Color numberColor = isDarkBg ? Colors.white : AppColors.primaryDark;
    // Make divider more visible on dark backgrounds
    final Color dividerColor = isDarkBg ? Colors.white.withOpacity(0.95) : Colors.grey.withOpacity(0.3);
    // Keep the label color as the original secondary text color
    final Color labelColor = AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
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
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(72, 72),
                        painter: _RingPainter(
                          progress: (totalToday / 100).clamp(0.0, 1.0),
                          accent: AppColors.accentOrange,
                          backgroundStroke: isDarkBg ? Colors.white : AppColors.primary.withOpacity(0.08),
                          strokeWidth: 3,
                        ),
                      ),
                      // Inner fill matches the card background so it looks like
                      // the ring is on top of the card.
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: circleBg,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        '$totalToday',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: numberColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Incidentes\nReportados Hoy',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          // Separador vertical
          Container(
            width: 2,
            height: 85,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: dividerColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isDarkBg
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                    ]
                  : null,
            ),
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

class _RingPainter extends CustomPainter {
  final double progress;
  final Color accent;
  final Color backgroundStroke;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.accent,
    required this.backgroundStroke,
    this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = backgroundStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // full background ring
    canvas.drawArc(rect, 0, math.pi * 2, false, bgPaint);

    // foreground arc (progress)
    final double sweep = (progress.clamp(0.0, 1.0)) * math.pi * 2;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.progress != progress || old.accent != accent || old.backgroundStroke != backgroundStroke || old.strokeWidth != strokeWidth;
  }
}
