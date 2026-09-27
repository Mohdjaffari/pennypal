import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Data model representing a Payment Method option in PennyPal.
class PaymentMethodItem {
  final String name;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String subtitle;

  const PaymentMethodItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.subtitle,
  });
}

/// Modal Bottom Sheet for selecting a Payment Method for an expense.
class PaymentMethodPickerSheet extends StatelessWidget {
  final String selectedMethod;

  const PaymentMethodPickerSheet({
    super.key,
    required this.selectedMethod,
  });

  static const List<PaymentMethodItem> methods = [
    PaymentMethodItem(
      name: 'Debit Card',
      icon: Icons.credit_card_rounded,
      color: AppColors.primaryBlue,
      backgroundColor: AppColors.primaryBlueLight,
      subtitle: 'Bank account direct debit',
    ),
    PaymentMethodItem(
      name: 'Credit Card',
      icon: Icons.credit_score_rounded,
      color: AppColors.purple,
      backgroundColor: AppColors.purpleLight,
      subtitle: 'Visa / Mastercard ending in 4242',
    ),
    PaymentMethodItem(
      name: 'Cash',
      icon: Icons.payments_outlined,
      color: AppColors.successGreen,
      backgroundColor: AppColors.successGreenLight,
      subtitle: 'Physical currency & petty cash',
    ),
    PaymentMethodItem(
      name: 'UPI / Digital Wallet',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.primaryPink,
      backgroundColor: AppColors.primaryPinkLight,
      subtitle: 'Instant mobile app payments',
    ),
    PaymentMethodItem(
      name: 'Net Banking',
      icon: Icons.account_balance_rounded,
      color: AppColors.shoppingOrange,
      backgroundColor: AppColors.shoppingOrangeLight,
      subtitle: 'Direct online bank transfer',
    ),
  ];

  static Future<PaymentMethodItem?> show(
    BuildContext context,
    String currentSelected,
  ) {
    return showModalBottomSheet<PaymentMethodItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentMethodPickerSheet(
        selectedMethod: currentSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppColors.surfaceOf(context);
    final borderColor = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
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
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: textSecondary, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: borderColor),

            // List of Payment Methods
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                itemCount: methods.length,
                separatorBuilder: (_, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final method = methods[index];
                  final isSelected = method.name == selectedMethod;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, method),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryPink.withValues(alpha: isDark ? 0.2 : 0.05)
                              : (isDark ? AppColors.darkSurfaceMuted.withValues(alpha: 0.35) : Colors.transparent),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryPink
                                : (isDark ? borderColor : Colors.transparent),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Squircle Icon
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? method.color.withValues(alpha: 0.2)
                                    : method.backgroundColor,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(
                                method.icon,
                                color: method.color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Name & Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primaryPink
                                          : textPrimary,
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    method.subtitle,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Selected indicator
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryPink,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
