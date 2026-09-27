import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Data class representing an Income Source option.
class IncomeSourceItem {
  final String name;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String subtitle;

  const IncomeSourceItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.subtitle,
  });
}

/// Modal Bottom Sheet for selecting an Income Source.
/// Styled according to the PennyPal design system with squircle icons and check indicators.
class IncomeSourcePickerSheet extends StatelessWidget {
  final String selectedSource;

  const IncomeSourcePickerSheet({
    super.key,
    required this.selectedSource,
  });

  static const List<IncomeSourceItem> sources = [
    IncomeSourceItem(
      name: 'Salary',
      icon: Icons.work_rounded,
      color: AppColors.primaryBlue,
      backgroundColor: AppColors.primaryBlueLight,
      subtitle: 'Monthly job or company payroll',
    ),
    IncomeSourceItem(
      name: 'Freelance',
      icon: Icons.laptop_mac_rounded,
      color: AppColors.purple,
      backgroundColor: AppColors.purpleLight,
      subtitle: 'Client projects & contracts',
    ),
    IncomeSourceItem(
      name: 'Investment',
      icon: Icons.trending_up_rounded,
      color: AppColors.successGreen,
      backgroundColor: AppColors.successGreenLight,
      subtitle: 'Dividends, stocks & mutual funds',
    ),
    IncomeSourceItem(
      name: 'Business',
      icon: Icons.storefront_rounded,
      color: AppColors.shoppingOrange,
      backgroundColor: AppColors.shoppingOrangeLight,
      subtitle: 'Commercial & ecommerce revenue',
    ),
    IncomeSourceItem(
      name: 'Allowance / Gift',
      icon: Icons.card_giftcard_rounded,
      color: AppColors.primaryPink,
      backgroundColor: AppColors.primaryPinkLight,
      subtitle: 'Family allowance or monetary gifts',
    ),
    IncomeSourceItem(
      name: 'Side Hustle',
      icon: Icons.monetization_on_rounded,
      color: Color(0xFF00B4D8),
      backgroundColor: Color(0xFFE0F7FA),
      subtitle: 'Tutoring, gigs & content creation',
    ),
    IncomeSourceItem(
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: AppColors.textSecondary,
      backgroundColor: AppColors.background,
      subtitle: 'Refunds or uncategorized deposits',
    ),
  ];

  static Future<IncomeSourceItem?> show(
    BuildContext context,
    String currentSelected,
  ) {
    return showModalBottomSheet<IncomeSourceItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IncomeSourcePickerSheet(
        selectedSource: currentSelected,
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
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                    'Select Income Source',
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

            // Scrollable List of Sources
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                itemCount: sources.length,
                separatorBuilder: (_, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final source = sources[index];
                  final isSelected = source.name == selectedSource;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, source),
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
                                    ? source.color.withValues(alpha: 0.2)
                                    : source.backgroundColor,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(
                                source.icon,
                                color: source.color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Title & Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    source.name,
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
                                    source.subtitle,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Selection Checkmark
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
