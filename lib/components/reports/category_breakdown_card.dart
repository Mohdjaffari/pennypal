import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_chart_models.dart';
import 'painters/doughnut_chart_painter.dart';

/// Card showing spending breakdown by category with a doughnut chart and legend.
class CategoryBreakdownCard extends StatelessWidget {
  final List<CategorySpendingData> categories;
  final String title;

  const CategoryBreakdownCard({
    super.key,
    required this.categories,
    this.title = 'Spending by Category',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimaryOf(context),
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Row(
            children: [
              // Left: Doughnut Chart with center icon
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: DoughnutChartPainter(
                        categories: categories,
                        strokeWidth: 16.0,
                      ),
                    ),
                    Icon(
                      Icons.pie_chart_rounded,
                      color: AppColors.textSecondaryOf(context),
                      size: 26,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Right: Category Legend Items
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: categories.map((cat) => _buildLegendItem(context, cat)).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, CategorySpendingData category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          // Color indicator dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),

          // Category Name
          Expanded(
            child: Text(
              category.name,
              style: TextStyle(
                color: AppColors.textPrimaryOf(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Percentage Text
          Text(
            '${category.percentageInt}%',
            style: TextStyle(
              color: AppColors.textSecondaryOf(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
