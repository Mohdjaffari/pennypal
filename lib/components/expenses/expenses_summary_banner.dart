import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Banner component summarizing total expenses for the selected timeframe.
class ExpensesSummaryBanner extends StatelessWidget {
  final double totalAmount;
  final int transactionCount;
  final String periodLabel;
  final String trendLabel;
  final bool isTrendGood; // Spending decrease is good!

  const ExpensesSummaryBanner({
    super.key,
    required this.totalAmount,
    required this.transactionCount,
    this.periodLabel = 'This Month',
    this.trendLabel = '-8% vs last month',
    this.isTrendGood = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Expenses ($periodLabel)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isTrendGood
                      ? AppColors.successGreenLight
                      : AppColors.expenseRedLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTrendGood
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: isTrendGood
                          ? AppColors.successGreen
                          : AppColors.expenseRed,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trendLabel,
                      style: TextStyle(
                        color: isTrendGood
                            ? AppColors.successGreen
                            : AppColors.expenseRed,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Total Expense Large Figure
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rs. ${totalAmount.toInt()}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$transactionCount recorded',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
