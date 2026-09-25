import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Data model representing a category budget limit and its consumption in PennyPal.
class CategoryBudgetModel {
  final String id;
  final String category;
  final double spentAmount;
  final double limitAmount;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const CategoryBudgetModel({
    required this.id,
    required this.category,
    required this.spentAmount,
    required this.limitAmount,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  /// Ratio from 0.0 to 1.0 (or greater if exceeded)
  double get progressRatio =>
      limitAmount > 0 ? (spentAmount / limitAmount).clamp(0.0, 1.0) : 0.0;

  /// Percentage integer representation (e.g. 56 for 56%)
  int get usagePercentage => (progressRatio * 100).round();

  /// Whether the budget has exceeded 100%
  bool get isOverBudget => spentAmount > limitAmount;

  /// Formatted spending ratio string, e.g. "Rs. 2,800 / 5,000"
  String get formattedRatio =>
      'Rs. ${spentAmount.toInt()} / ${limitAmount.toInt()}';

  /// Initial default category budgets matching Screen 4 of the Figma board
  static List<CategoryBudgetModel> get defaultBudgets => const [
        CategoryBudgetModel(
          id: 'b_food',
          category: 'Food & Dining',
          spentAmount: 2800,
          limitAmount: 5000,
          icon: Icons.restaurant_rounded,
          color: AppColors.primaryPink,
          backgroundColor: AppColors.primaryPinkLight,
        ),
        CategoryBudgetModel(
          id: 'b_transport',
          category: 'Transport',
          spentAmount: 1640,
          limitAmount: 3000,
          icon: Icons.directions_bus_rounded,
          color: AppColors.primaryBlue,
          backgroundColor: AppColors.primaryBlueLight,
        ),
        CategoryBudgetModel(
          id: 'b_shopping',
          category: 'Shopping',
          spentAmount: 820,
          limitAmount: 2000,
          icon: Icons.shopping_bag_rounded,
          color: AppColors.shoppingOrange,
          backgroundColor: AppColors.shoppingOrangeLight,
        ),
        CategoryBudgetModel(
          id: 'b_entertainment',
          category: 'Entertainment',
          spentAmount: 600,
          limitAmount: 2000,
          icon: Icons.movie_rounded,
          color: AppColors.purple,
          backgroundColor: AppColors.purpleLight,
        ),
      ];
}
