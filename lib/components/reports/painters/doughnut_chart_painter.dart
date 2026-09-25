import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/report_chart_models.dart';

/// Renders a segmented doughnut chart using canvas arcs.
class DoughnutChartPainter extends CustomPainter {
  final List<CategorySpendingData> categories;
  final double strokeWidth;

  const DoughnutChartPainter({
    required this.categories,
    this.strokeWidth = 18.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (categories.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Start at top (-90 degrees)
    double startAngle = -math.pi / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (final category in categories) {
      if (category.percentage <= 0) continue;

      // Calculate sweep angle based on percentage (2 * PI = full circle)
      // Slight visual gap between segments for modern aesthetic
      final sweepAngle = (category.percentage * 2 * math.pi) - 0.08;

      paint.color = category.color;

      if (sweepAngle > 0) {
        canvas.drawArc(
          rect,
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }

      // Advance starting position for next segment
      startAngle += category.percentage * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(covariant DoughnutChartPainter oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
