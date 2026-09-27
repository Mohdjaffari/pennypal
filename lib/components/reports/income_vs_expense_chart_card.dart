import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_chart_models.dart';

/// Interactive Income vs Expense Paired Bar Chart.
/// Shows side-by-side comparison bars for cash in vs cash out across time slots
/// with interactive tap selection and detailed breakdown tooltips.
class IncomeVsExpenseChartCard extends StatefulWidget {
  final List<ComparisonBarDataPoint> dataPoints;
  final String title;
  final String period;

  const IncomeVsExpenseChartCard({
    super.key,
    required this.dataPoints,
    this.title = 'Income vs Expenses',
    this.period = 'Weekly',
  });

  @override
  State<IncomeVsExpenseChartCard> createState() => _IncomeVsExpenseChartCardState();
}

class _IncomeVsExpenseChartCardState extends State<IncomeVsExpenseChartCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = AppColors.surfaceOf(context);
    final border = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    // Calculate period totals
    final totalIncome = widget.dataPoints.fold<double>(0, (s, p) => s + p.incomeAmount);
    final totalExpense = widget.dataPoints.fold<double>(0, (s, p) => s + p.expenseAmount);
    final netCash = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title and Dynamic Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap any column for detailed breakdown',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: netCash >= 0
                      ? AppColors.successGreen.withValues(alpha: isDark ? 0.2 : 0.12)
                      : AppColors.expenseRed.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      netCash >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: netCash >= 0 ? AppColors.successGreen : AppColors.expenseRed,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      netCash >= 0 ? '+Rs. ${netCash.toInt()}' : '-Rs. ${netCash.abs().toInt()}',
                      style: TextStyle(
                        color: netCash >= 0 ? AppColors.successGreen : AppColors.expenseRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Legend Bar
          Row(
            children: [
              _buildLegendPill(
                color: AppColors.successGreen,
                label: 'Income (Inflow)',
                amount: 'Rs. ${totalIncome.toInt()}',
                textColor: textPrimary,
              ),
              const SizedBox(width: 16),
              _buildLegendPill(
                color: AppColors.primaryPink,
                label: 'Expenses (Outflow)',
                amount: 'Rs. ${totalExpense.toInt()}',
                textColor: textPrimary,
              ),
            ],
          ),

          // Active Tooltip Info when tapped
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _selectedIndex != null
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 14),
            secondChild: _selectedIndex != null
                ? _buildInspectionCard(widget.dataPoints[_selectedIndex!], isDark)
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 10),

          // Double Bar Chart Area
          SizedBox(
            height: 180,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barAreaHeight = (constraints.maxHeight - 38).clamp(10.0, constraints.maxHeight);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(widget.dataPoints.length, (index) {
                    final point = widget.dataPoints[index];
                    final isSelected = _selectedIndex == index;

                    final incomeH = (barAreaHeight * point.incomePct).clamp(8.0, barAreaHeight);
                    final expenseH = (barAreaHeight * point.expensePct).clamp(8.0, barAreaHeight);

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedIndex = isSelected ? null : index;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Paired Columns wrapped in Expanded so it will never overflow
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          color: (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.04)),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: AppColors.primaryBlue.withValues(alpha: 0.4),
                                            width: 1,
                                          ),
                                        )
                                      : null,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Income Bar (Green)
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeOutCubic,
                                        width: 10,
                                        height: incomeH,
                                        decoration: BoxDecoration(
                                          color: AppColors.successGreen,
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: [
                                            if (isSelected)
                                              BoxShadow(
                                                color: AppColors.successGreen.withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      // Expense Bar (Rose)
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeOutCubic,
                                        width: 10,
                                        height: expenseH,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryPink,
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: [
                                            if (isSelected)
                                              BoxShadow(
                                                color: AppColors.primaryPink.withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // X-axis label
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                point.label,
                                style: TextStyle(
                                  color: isSelected ? AppColors.primaryBlue : textSecondary,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill({
    required Color color,
    required String label,
    required String amount,
    required Color textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInspectionCard(ComparisonBarDataPoint point, bool isDark) {
    final net = point.netFlow;
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  point.label,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Income: ${point.formattedIncome}',
                    style: const TextStyle(
                      color: AppColors.successGreen,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Spent: ${point.formattedExpense}',
                    style: const TextStyle(
                      color: AppColors.primaryPink,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            net >= 0 ? '+Rs. ${net.toInt()}' : '-Rs. ${net.abs().toInt()}',
            style: TextStyle(
              color: net >= 0 ? AppColors.successGreen : AppColors.expenseRed,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
