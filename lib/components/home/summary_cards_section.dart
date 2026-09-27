import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/language_service.dart';
import 'mini_summary_card.dart';

/// Section rendering Total Expenses and Total Savings cards side by side.
class SummaryCardsSection extends StatelessWidget {
  final String expensesAmount;
  final String expensesTrend;
  final String savingsAmount;
  final String savingsTrend;
  final VoidCallback? onExpensesTap;
  final VoidCallback? onSavingsTap;

  const SummaryCardsSection({
    super.key,
    this.expensesAmount = 'Rs. 8,230',
    this.expensesTrend = '- 8% this month',
    this.savingsAmount = 'Rs. 3,200',
    this.savingsTrend = '+ 20% this month',
    this.onExpensesTap,
    this.onSavingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Row(
      children: [
        // 1. Total Expenses Card
        Expanded(
          child: MiniSummaryCard(
            title: context.tr('total_expenses'),
            amount: expensesAmount,
            icon: Icons.arrow_downward_rounded,
            iconColor: AppColors.primaryPink,
            iconBgColor: isDark ? AppColors.darkPrimaryPinkLight : AppColors.primaryPinkLight,
            trendText: expensesTrend,
            trendColor: AppColors.primaryPink,
            onTap: onExpensesTap,
          ),
        ),
        const SizedBox(width: 14),

        // 2. Total Savings Card with Progress Ring
        Expanded(
          child: MiniSummaryCard(
            title: context.tr('total_savings'),
            amount: savingsAmount,
            icon: Icons.account_balance_rounded,
            iconColor: AppColors.primaryBlue,
            iconBgColor: isDark ? AppColors.darkPrimaryBlueLight : AppColors.primaryBlueLight,
            trendText: savingsTrend,
            trendColor: AppColors.successGreen,
            showProgressDiagram: true,
            progress: 0.65,
            onTap: onSavingsTap,
          ),
        ),
      ],
    );
  }
}
