import 'dart:math';
import 'package:flutter/material.dart';

class DonutChart extends StatelessWidget {
  final List<double> values; // should sum to ~1.0
  final List<Color> colors;
  final double size;

  const DonutChart({Key? key, required this.values, required this.colors, this.size = 140}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: DonutPainter(values, colors),
      ),
    );
  }
}

class DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  DonutPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 22.0;

    // draw a full base arc (light grey) so the donut ring is always complete
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22.0
      ..color = Colors.grey.shade200;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 11), -pi / 2, 2 * pi, false, basePaint);

    double start = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] * 2 * pi;
      paint.color = colors[i % colors.length];
      if (sweep > 0) {
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 11), start, sweep, false, paint);
      }
      start += sweep;
    }

    // inner circle to create donut hole
    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - 36, holePaint);
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) {
    if (oldDelegate.values.length != values.length) return true;
    for (var i = 0; i < values.length; i++) {
      if ((oldDelegate.values[i] - values[i]).abs() > 1e-6) return true;
    }
    return false;
  }
}
