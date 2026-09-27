import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Top KPI metric cards for Reports screen displaying Total Income, Total Expenses,
/// Net Cash Flow, and Savings Rate % with responsive design.
class ReportKpiSummaryCards extends StatelessWidget {
  final String totalIncome;
  final String totalExpenses;
  final String netSavings;
  final String savingsRate;
  final String incomeTrend;
  final String expenseTrend;

  const ReportKpiSummaryCards({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netSavings,
    required this.savingsRate,
    this.incomeTrend = '+14% vs prev',
    this.expenseTrend = '-6% vs prev',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Total Inflow & Total Outflow
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context: context,
                title: 'Total Income',
                amount: totalIncome,
                trend: incomeTrend,
                isPositive: true,
                icon: Icons.arrow_upward_rounded,
                accentColor: AppColors.successGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                context: context,
                title: 'Total Spent',
                amount: totalExpenses,
                trend: expenseTrend,
                isPositive: true, // Lower expenses is good
                icon: Icons.arrow_downward_rounded,
                accentColor: AppColors.primaryPink,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Row 2: Net Savings & Savings Rate
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context: context,
                title: 'Net Savings',
                amount: netSavings,
                trend: 'Cash retained',
                isPositive: true,
                icon: Icons.account_balance_wallet_outlined,
                accentColor: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                context: context,
                title: 'Savings Rate',
                amount: savingsRate,
                trend: 'Of total income',
                isPositive: true,
                icon: Icons.pie_chart_outline_rounded,
                accentColor: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required String title,
    required String amount,
    required String trend,
    required bool isPositive,
    required IconData icon,
    required Color accentColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = AppColors.surfaceOf(context);
    final border = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Trend Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              Flexible(
                child: Text(
                  trend,
                  style: TextStyle(
                    color: isPositive ? AppColors.successGreen : AppColors.expenseRed,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(
              color: textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
