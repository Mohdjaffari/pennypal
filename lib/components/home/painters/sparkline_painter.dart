import 'package:flutter/material.dart';

/// Draws a smooth curved sparkline graph with gradient fill.
class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final List<Color>? fillColors;

  const SparklinePainter({
    this.data = const [0.2, 0.45, 0.35, 0.65, 0.4, 0.75, 0.55, 0.95],
    this.lineColor = const Color(0x33FFFFFF),
    this.fillColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double y = size.height - (data[i] * size.height * 0.85);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final double prevX = (i - 1) * stepX;
        final double prevY = size.height - (data[i - 1] * size.height * 0.85);
        final double controlPointX = prevX + (x - prevX) / 2;
        path.cubicTo(controlPointX, prevY, controlPointX, y, x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Gradient fill under the path
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final colors = fillColors ??
        [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.0),
        ];

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.fillColors != fillColors;
}
