import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';

/// Modal Bottom Sheet displaying full receipt & breakdown information for a transaction.
class ExpenseDetailSheet extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onDelete;

  const ExpenseDetailSheet({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required TransactionModel transaction,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseDetailSheet(
        transaction: transaction,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category squircle & Amount Header
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: transaction.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    transaction.icon,
                    color: transaction.color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        transaction.category,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  transaction.isExpense
                      ? '- ${transaction.formattedAmount}'
                      : '+ ${transaction.formattedAmount}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: transaction.isExpense
                        ? AppColors.textPrimary
                        : AppColors.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metadata card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _detailRow(
                    label: 'Date',
                    value: transaction.date,
                    icon: Icons.calendar_today_outlined,
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  _detailRow(
                    label: 'Payment Method',
                    value: transaction.paymentMethod,
                    icon: Icons.credit_card_rounded,
                  ),
                  if (transaction.note.isNotEmpty) ...[
                    const Divider(height: 20, color: AppColors.border),
                    _detailRow(
                      label: 'Note',
                      value: transaction.note,
                      icon: Icons.notes_rounded,
                    ),
                  ],
                  const Divider(height: 20, color: AppColors.border),
                  _detailRow(
                    label: 'Receipt',
                    value: transaction.hasReceipt ? 'Attached (1 scan)' : 'None',
                    icon: Icons.receipt_long_rounded,
                    valueColor: transaction.hasReceipt
                        ? AppColors.primaryBlue
                        : AppColors.textMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons (Delete & Close)
            Row(
              children: [
                if (onDelete != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete?.call();
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expenseRed,
                        side: const BorderSide(color: AppColors.expenseRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
