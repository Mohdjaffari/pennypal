import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'painters/circular_progress_painter.dart';

/// Reusable mini card for financial summaries (Expenses, Savings, Budget, etc.).
class MiniSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final String trendText;
  final Color? trendColor;
  final bool showProgressDiagram;
  final double progress;
  final VoidCallback? onTap;

  const MiniSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    this.iconBgColor,
    required this.trendText,
    this.trendColor,
    this.showProgressDiagram = false,
    this.progress = 0.65,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final effectiveIconBg = iconBgColor ??
        (isDark ? iconColor.withValues(alpha: 0.22) : iconColor.withValues(alpha: 0.12));
    final effectiveTrendColor = trendColor ?? AppColors.successGreen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderOf(context), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.025),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon squircle + Optional Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: effectiveIconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  if (showProgressDiagram)
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: CustomPaint(
                        painter: CircularProgressPainter(
                          progress: progress,
                          color: iconColor,
                          strokeWidth: 3.2,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondaryOf(context),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),

              // Amount
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  amount,
                  style: TextStyle(
                    color: AppColors.textPrimaryOf(context),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Trend Subtitle
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  trendText,
                  style: TextStyle(
                    color: effectiveTrendColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
