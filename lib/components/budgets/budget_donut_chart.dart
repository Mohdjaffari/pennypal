import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Circular progress ring chart displaying the overall monthly budget consumption,
/// directly matching Screen 4 ("Budgets") from the PennyPal Figma board.
class BudgetDonutChart extends StatelessWidget {
  final double totalSpent;
  final double totalLimit;
  final String monthTitle;

  const BudgetDonutChart({
    super.key,
    this.totalSpent = 8230,
    this.totalLimit = 15000,
    this.monthTitle = 'This Month',
  });

  double get _progressRatio =>
      totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;

  int get _usagePercentage => (_progressRatio * 100).round();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          // Donut Ring Canvas with Center Content
          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(170, 170),
                  painter: _BudgetRingPainter(
                    progress: _progressRatio,
                    strokeWidth: 16.0,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      monthTitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${totalSpent.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'of ${totalLimit.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Percentage Used Subtitle
          Text(
            '$_usagePercentage% used',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Canvas painter drawing the circular budget consumption ring with rounded caps
class _BudgetRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  const _BudgetRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track ring
    final trackPaint = Paint()
      ..color = AppColors.primaryPink.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    final progressPaint = Paint()
      ..shader = AppColors.pinkGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2, // Start at 12 o'clock
      progress.clamp(0.0, 1.0) * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BudgetRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
