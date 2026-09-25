import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import 'transaction_tile.dart';

/// Section displaying recent transaction history.
class RecentTransactionsSection extends StatelessWidget {
  final List<TransactionModel> transactions;
  final VoidCallback? onViewAllPressed;
  final ValueChanged<TransactionModel>? onTransactionTap;

  const RecentTransactionsSection({
    super.key,
    required this.transactions,
    this.onViewAllPressed,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: onViewAllPressed ?? () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // List of Transactions (Rendered as Column items to avoid nested scroll views)
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'No recent transactions found',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          )
        else
          Column(
            children: List.generate(
              transactions.length,
              (index) {
                final tx = transactions[index];
                final isLast = index == transactions.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
                  child: TransactionTile(
                    transaction: tx,
                    onTap: () => onTransactionTap?.call(tx),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
