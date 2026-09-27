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
  final int updatedAt;
  final bool isSynced;

  const CategoryBudgetModel({
    required this.id,
    required this.category,
    required this.spentAmount,
    required this.limitAmount,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.updatedAt = 0,
    this.isSynced = false,
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

  /// Converts this model into a map for SQLite and Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'spent_amount': spentAmount,
      'limit_amount': limitAmount,
      'icon_code': icon.codePoint,
      'icon_font_family': icon.fontFamily ?? 'MaterialIcons',
      'color_value': color.toARGB32(),
      'background_color_value': backgroundColor.toARGB32(),
      'updated_at': updatedAt == 0 ? DateTime.now().millisecondsSinceEpoch : updatedAt,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  /// Recreates a CategoryBudgetModel from an SQLite or Firestore record
  factory CategoryBudgetModel.fromMap(Map<String, dynamic> map) {
    final iconCode = map['icon_code'] is int
        ? map['icon_code'] as int
        : (int.tryParse(map['icon_code']?.toString() ?? '') ?? Icons.category_rounded.codePoint);
    final fontFamily = map['icon_font_family'] as String? ?? 'MaterialIcons';

    final colorVal = map['color_value'] is int
        ? map['color_value'] as int
        : (int.tryParse(map['color_value']?.toString() ?? '') ?? 0xFF4361EE);
    final bgVal = map['background_color_value'] is int
        ? map['background_color_value'] as int
        : (int.tryParse(map['background_color_value']?.toString() ?? '') ?? 0xFFEEF2FF);

    return CategoryBudgetModel(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General',
      spentAmount: (map['spent_amount'] is num) ? (map['spent_amount'] as num).toDouble() : 0.0,
      limitAmount: (map['limit_amount'] is num) ? (map['limit_amount'] as num).toDouble() : 0.0,
      icon: IconData(iconCode, fontFamily: fontFamily),
      color: Color(colorVal),
      backgroundColor: Color(bgVal),
      updatedAt: (map['updated_at'] is num) ? (map['updated_at'] as num).toInt() : 0,
      isSynced: (map['is_synced'] == 1 || map['is_synced'] == true),
    );
  }

  CategoryBudgetModel copyWith({
    String? id,
    String? category,
    double? spentAmount,
    double? limitAmount,
    IconData? icon,
    Color? color,
    Color? backgroundColor,
    int? updatedAt,
    bool? isSynced,
  }) {
    return CategoryBudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      spentAmount: spentAmount ?? this.spentAmount,
      limitAmount: limitAmount ?? this.limitAmount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

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
