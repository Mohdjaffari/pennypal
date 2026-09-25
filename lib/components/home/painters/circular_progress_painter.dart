import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws a subtle circular progress ring for summary cards.
class CircularProgressPainter extends CustomPainter {
  final double progress; // Range 0.0 to 1.0
  final Color color;
  final double strokeWidth;

  const CircularProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (strokeWidth / 2);

    // Background track ring
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at 12 o'clock
      progress.clamp(0.0, 1.0) * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
