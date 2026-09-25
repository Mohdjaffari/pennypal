import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Data model representing an expense category item.
class ExpenseCategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const ExpenseCategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

/// Modal Bottom Sheet for selecting an Expense Category.
class ExpenseCategoryPickerSheet extends StatelessWidget {
  final String selectedCategory;

  const ExpenseCategoryPickerSheet({
    super.key,
    required this.selectedCategory,
  });

  static const List<ExpenseCategoryItem> categories = [
    ExpenseCategoryItem(
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: AppColors.primaryPink,
      backgroundColor: AppColors.primaryPinkLight,
    ),
    ExpenseCategoryItem(
      name: 'Transport',
      icon: Icons.directions_bus_rounded,
      color: AppColors.primaryBlue,
      backgroundColor: AppColors.primaryBlueLight,
    ),
    ExpenseCategoryItem(
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.shoppingOrange,
      backgroundColor: AppColors.shoppingOrangeLight,
    ),
    ExpenseCategoryItem(
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: AppColors.purple,
      backgroundColor: AppColors.purpleLight,
    ),
    ExpenseCategoryItem(
      name: 'Groceries',
      icon: Icons.local_grocery_store_rounded,
      color: Color(0xFF06D6A0),
      backgroundColor: Color(0xFFE8FDF5),
    ),
    ExpenseCategoryItem(
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFE63946),
      backgroundColor: Color(0xFFFFECEE),
    ),
    ExpenseCategoryItem(
      name: 'Health & Fitness',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFF118AB2),
      backgroundColor: Color(0xFFE0F2FE),
    ),
    ExpenseCategoryItem(
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFFFFB703),
      backgroundColor: Color(0xFFFFFBEB),
    ),
  ];

  static Future<ExpenseCategoryItem?> show(
    BuildContext context,
    String currentSelected,
  ) {
    return showModalBottomSheet<ExpenseCategoryItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseCategoryPickerSheet(
        selectedCategory: currentSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
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
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
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
                  const Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // Grid of categories
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat.name == selectedCategory;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, cat),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryPink.withValues(alpha: 0.08)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryPink
                                : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: cat.backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(cat.icon, color: cat.color, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primaryPink
                                      : AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
