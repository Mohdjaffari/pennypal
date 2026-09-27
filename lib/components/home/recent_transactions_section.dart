import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/language_service.dart';
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
            Text(
              context.tr('recent_transactions'),
              style: TextStyle(
                color: AppColors.textPrimaryOf(context),
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            GestureDetector(
              onTap: onViewAllPressed ?? () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Text(
                  context.tr('see_all'),
                  style: const TextStyle(
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
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderOf(context)),
            ),
            child: Text(
              context.tr('no_transactions_yet'),
              style: TextStyle(
                color: AppColors.textSecondaryOf(context),
                fontSize: 13,
                height: 1.3,
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
