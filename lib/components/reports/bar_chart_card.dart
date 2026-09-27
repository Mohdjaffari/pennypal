import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_chart_models.dart';

/// Responsive bar chart card visualizing spending over time.
class BarChartCard extends StatelessWidget {
  final List<BarChartDataPoint> dataPoints;
  final String title;
  final String? subtitle;

  const BarChartCard({
    super.key,
    required this.dataPoints,
    this.title = 'Spending Overview',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderOf(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondaryOf(context),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: AppColors.textPrimaryOf(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Bar Chart Canvas
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight - 28; // Space for X-axis labels

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: dataPoints.map((point) {
                    final barHeight = (availableHeight * point.percentage).clamp(8.0, availableHeight);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Tooltip or amount indicator on high values
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          width: 14,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: point.color,
                            borderRadius: BorderRadius.circular(7),
                            boxShadow: [
                              BoxShadow(
                                color: point.color.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Label
                        Text(
                          point.label,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
