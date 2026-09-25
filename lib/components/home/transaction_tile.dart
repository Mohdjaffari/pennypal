import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';

/// Single item tile representing a financial transaction.
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Category Icon Squircle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: transaction.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  transaction.icon,
                  color: transaction.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Title & Date/Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      transaction.date,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction Amount
              Text(
                transaction.isExpense
                    ? '- ${transaction.formattedAmount}'
                    : '+ ${transaction.formattedAmount}',
                style: TextStyle(
                  color: transaction.isExpense
                      ? AppColors.textPrimary
                      : AppColors.successGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
