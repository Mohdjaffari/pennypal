import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import 'receipt_image_viewer.dart';

/// Modal Bottom Sheet displaying full receipt & breakdown information for a transaction.
class ExpenseDetailSheet extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ExpenseDetailSheet({
    super.key,
    required this.transaction,
    this.onDelete,
    this.onEdit,
  });

  static Future<void> show(
    BuildContext context, {
    required TransactionModel transaction,
    VoidCallback? onDelete,
    VoidCallback? onEdit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseDetailSheet(
        transaction: transaction,
        onDelete: onDelete,
        onEdit: onEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppColors.surfaceOf(context);
    final cardBg = AppColors.surfaceMutedOf(context);
    final borderColor = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                  color: borderColor,
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
                    color: isDark ? transaction.color.withValues(alpha: 0.2) : transaction.backgroundColor,
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
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        transaction.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
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
                        ? (isDark ? const Color(0xFFF87171) : AppColors.expenseRed)
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
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _detailRow(
                    label: 'Date',
                    value: transaction.date,
                    icon: Icons.calendar_today_outlined,
                    textSecondary: textSecondary,
                    textPrimary: textPrimary,
                  ),
                  Divider(height: 20, color: borderColor),
                  _detailRow(
                    label: 'Payment Method',
                    value: transaction.paymentMethod,
                    icon: Icons.credit_card_rounded,
                    textSecondary: textSecondary,
                    textPrimary: textPrimary,
                  ),
                  if (transaction.note.isNotEmpty) ...[
                    Divider(height: 20, color: borderColor),
                    _detailRow(
                      label: 'Note',
                      value: transaction.note,
                      icon: Icons.notes_rounded,
                      textSecondary: textSecondary,
                      textPrimary: textPrimary,
                    ),
                  ],
                  Divider(height: 20, color: borderColor),
                  _detailRow(
                    label: 'Receipt',
                    value: transaction.hasReceipt ? 'Attached' : 'None',
                    icon: Icons.receipt_long_rounded,
                    valueColor: transaction.hasReceipt
                        ? AppColors.primaryBlue
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                    textSecondary: textSecondary,
                    textPrimary: textPrimary,
                  ),
                  if (transaction.hasReceipt &&
                      transaction.receiptPath != null &&
                      transaction.receiptPath!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => ReceiptImageViewer.showPreview(
                        context,
                        transaction.receiptPath!,
                        title: '${transaction.title} Receipt',
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            ReceiptImageViewer(
                              receiptPath: transaction.receiptPath!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Receipt Image Attached',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Tap to view and zoom',
                                    style: TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.zoom_in_rounded,
                              color: AppColors.primaryBlue,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons (Delete, Edit & Done)
            Row(
              children: [
                if (onDelete != null)
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete?.call();
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expenseRed),
                    tooltip: 'Delete',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.expenseRed, width: 1.2),
                      ),
                    ),
                  ),
                if (onDelete != null) const SizedBox(width: 10),
                if (onEdit != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit?.call();
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                if (onEdit != null) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
    required Color textSecondary,
    required Color textPrimary,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: textSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
