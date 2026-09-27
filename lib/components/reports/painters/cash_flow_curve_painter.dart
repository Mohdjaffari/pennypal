import 'package:flutter/material.dart';
import '../../../models/report_chart_models.dart';

/// CustomPainter rendering a smooth Bézier spline with gradient area fill,
/// subtle horizontal grid lines, and interactive highlighted focus point.
class CashFlowCurvePainter extends CustomPainter {
  final List<CashFlowTrendPoint> points;
  final Color lineColor;
  final Color gradientStartColor;
  final Color gridColor;
  final int? selectedIndex;
  final double animationProgress;

  const CashFlowCurvePainter({
    required this.points,
    required this.lineColor,
    required this.gradientStartColor,
    required this.gridColor,
    this.selectedIndex,
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final bottomY = size.height - 24.0;
    final topY = 16.0;
    final chartHeight = bottomY - topY;

    // 1. Draw 3 subtle dashed/solid horizontal grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 2; i++) {
      final y = topY + (chartHeight * i / 2.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.length < 2) return;

    // Calculate (x, y) coordinates for each point
    final List<Offset> coordinates = [];
    final dx = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * dx;
      final targetY = bottomY - (points[i].normalizedHeight * chartHeight);
      // Animate from bottom to target
      final animatedY = bottomY - ((bottomY - targetY) * animationProgress);
      coordinates.add(Offset(x, animatedY));
    }

    // 2. Build Smooth Bézier Spline Path
    final path = Path();
    path.moveTo(coordinates[0].dx, coordinates[0].dy);

    for (int i = 0; i < coordinates.length - 1; i++) {
      final p0 = coordinates[i];
      final p1 = coordinates[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // 3. Fill Gradient underneath the Curve
    final fillPath = Path.from(path)
      ..lineTo(coordinates.last.dx, bottomY)
      ..lineTo(coordinates.first.dx, bottomY)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientStartColor,
          gradientStartColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, topY, size.width, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    // 4. Draw Line Stroke
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // 5. Draw Point Markers
    final pointFillPaint = Paint()..color = Colors.white;
    final pointStrokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < coordinates.length; i++) {
      final pt = coordinates[i];
      final isSelected = selectedIndex == i;

      if (isSelected) {
        // Glowing halo for selected point
        final haloPaint = Paint()
          ..color = lineColor.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 10, haloPaint);
        canvas.drawCircle(pt, 5.5, pointFillPaint);
        canvas.drawCircle(pt, 5.5, pointStrokePaint);
      } else {
        canvas.drawCircle(pt, 3.5, pointFillPaint);
        canvas.drawCircle(pt, 3.5, pointStrokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CashFlowCurvePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.points != points;
  }
}
