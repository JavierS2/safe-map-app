import 'package:flutter/material.dart';
import '../../../models/report_model.dart';
import '../../../theme/app_colors.dart';

class ReportMarker extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;

  const ReportMarker({Key? key, required this.report, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a Stack so the tip overlaps the circle and appears to come out of it
    const double circleSize = 44.0;
    const double tipSize = 12.0;
    const double totalWidth = 56.0;
    const double totalHeight = 72.0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: totalWidth,
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Circle centered horizontally at top
            Positioned(
              top: 0,
              left: (totalWidth - circleSize) / 2,
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                // show only an exclamation sign (no inner circle)
                child: const Center(
                  child: Text('!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ),
            ),
            // Tip positioned so it slightly overlaps the circle bottom
            Positioned(
              top: circleSize - (tipSize / 3),
              left: (totalWidth - tipSize) / 2,
              // make the small triangular tip white as requested
              child: _PinTip(color: Colors.white, size: tipSize),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinTip extends StatelessWidget {
  final Color color;
  final double size;

  const _PinTip({Key? key, required this.color, this.size = 10}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TrianglePainter(color: color),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    // fill with the provided color (no white stroke around the small tip)
    final fill = Paint()..style = PaintingStyle.fill..color = color;
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// _DashedArrowPainter removed — not used any more

