import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_chart_models.dart';

/// Professional multi-mode chart component for the All Expenses screen.
/// Allows toggling between:
/// 1. [Daily Spending]: Interactive vertical bar chart
/// 2. [Category Share]: Custom circular donut chart with legend
class ExpensesChartSection extends StatefulWidget {
  final List<BarChartDataPoint> dailyData;
  final List<CategorySpendingData> categoryData;
  final double totalSpent;

  const ExpensesChartSection({
    super.key,
    required this.dailyData,
    required this.categoryData,
    required this.totalSpent,
  });

  @override
  State<ExpensesChartSection> createState() => _ExpensesChartSectionState();
}

class _ExpensesChartSectionState extends State<ExpensesChartSection> {
  int _selectedChartTab = 0; // 0: Daily Bars, 1: Category Donut
  int _selectedBarIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Header with Toggle Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedChartTab == 0 ? 'Daily Spending' : 'Category Breakdown',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _chartTabItem(
                      index: 0,
                      icon: Icons.bar_chart_rounded,
                      label: 'Daily',
                    ),
                    _chartTabItem(
                      index: 1,
                      icon: Icons.pie_chart_outline_rounded,
                      label: 'Share',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Render active chart view
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _selectedChartTab == 0
                ? _buildDailyBarChart()
                : _buildCategoryDonutChart(),
          ),
        ],
      ),
    );
  }

  Widget _chartTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedChartTab == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedChartTab = index;
        _selectedBarIndex = -1;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.primaryPink : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Daily Bar Chart View
  Widget _buildDailyBarChart() {
    return Column(
      key: const ValueKey('daily_bar'),
      children: [
        if (_selectedBarIndex >= 0 &&
            _selectedBarIndex < widget.dailyData.length) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryPinkLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${widget.dailyData[_selectedBarIndex].label}: ${widget.dailyData[_selectedBarIndex].formattedAmount ?? 'Rs. 0'}',
              style: const TextStyle(
                color: AppColors.primaryPink,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ] else ...[
          const Text(
            'Tap a day to view spending',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Bars Track
        SizedBox(
          height: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.dailyData.length, (index) {
              final point = widget.dailyData[index];
              final isBarSelected = _selectedBarIndex == index;
              final barHeight = (point.percentage * 110).clamp(8.0, 110.0);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBarIndex = isBarSelected ? -1 : index;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Animated Bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 22,
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: isBarSelected
                            ? AppColors.pinkGradient
                            : LinearGradient(
                                colors: [
                                  point.color.withValues(alpha: 0.9),
                                  point.color,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isBarSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primaryPink.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Day Label
                    Text(
                      point.label,
                      style: TextStyle(
                        color: isBarSelected
                            ? AppColors.primaryPink
                            : AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight:
                            isBarSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // 2. Category Donut Chart View
  Widget _buildCategoryDonutChart() {
    return Column(
      key: const ValueKey('category_donut'),
      children: [
        Row(
          children: [
            // Donut Canvas
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: _CategoryDonutPainter(
                      data: widget.categoryData,
                      strokeWidth: 14.0,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Rs. ${(widget.totalSpent / 1000).toStringAsFixed(1)}k',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),

            // Legend column
            Expanded(
              child: Column(
                children: widget.categoryData.take(4).map((cat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: cat.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cat.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${cat.percentageInt}%',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Painter for drawing the segmented multi-category donut chart
class _CategoryDonutPainter extends CustomPainter {
  final List<CategorySpendingData> data;
  final double strokeWidth;

  const _CategoryDonutPainter({
    required this.data,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;

    for (final slice in data) {
      final sweepAngle = slice.percentage * 2 * math.pi;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _CategoryDonutPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.strokeWidth != strokeWidth;
  }
}
