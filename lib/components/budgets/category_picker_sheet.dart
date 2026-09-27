import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Modal bottom sheet for choosing a budget category.
class CategoryPickerSheet extends StatelessWidget {
  final String selectedCategory;

  const CategoryPickerSheet({
    super.key,
    required this.selectedCategory,
  });

  static const List<Map<String, dynamic>> budgetCategories = [
    {
      'name': 'Food & Dining',
      'icon': Icons.restaurant_rounded,
      'color': AppColors.primaryPink,
      'bgColor': AppColors.primaryPinkLight,
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_bus_rounded,
      'color': AppColors.primaryBlue,
      'bgColor': AppColors.primaryBlueLight,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_rounded,
      'color': AppColors.shoppingOrange,
      'bgColor': AppColors.shoppingOrangeLight,
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie_rounded,
      'color': AppColors.purple,
      'bgColor': AppColors.purpleLight,
    },
    {
      'name': 'Bills & Utilities',
      'icon': Icons.receipt_long_rounded,
      'color': AppColors.successGreen,
      'bgColor': AppColors.successGreenLight,
    },
  ];

  static Future<Map<String, dynamic>?> show(
    BuildContext context,
    String selectedCategory,
  ) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CategoryPickerSheet(selectedCategory: selectedCategory),
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
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Budget Category',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...budgetCategories.map((cat) {
                final isSelected = cat['name'] == selectedCategory;
                return ListTile(
                  onTap: () => Navigator.of(context).pop(cat),
                  tileColor: isSelected
                      ? (isDark ? AppColors.darkSurfaceMuted : AppColors.primaryBlueLight)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? (cat['color'] as Color).withValues(alpha: 0.2)
                          : (cat['bgColor'] as Color),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      color: cat['color'] as Color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    cat['name'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : textPrimary,
                      fontSize: 14.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue)
                      : null,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
