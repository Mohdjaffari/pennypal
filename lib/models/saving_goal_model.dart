import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Data model representing a financial savings goal in PennyPal.
class SavingGoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final double monthlyContribution;
  final String targetDate;
  final String createdDate;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final int updatedAt;
  final bool isSynced;

  const SavingGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.monthlyContribution = 0.0,
    required this.targetDate,
    required this.createdDate,
    this.icon = Icons.flag_rounded,
    this.color = AppColors.primaryPink,
    this.backgroundColor = AppColors.primaryPinkLight,
    this.updatedAt = 0,
    this.isSynced = false,
  });

  /// Ratio between 0.0 and 1.0 representing goal completion
  double get progressRatio {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  /// Percentage integer representation (e.g. 24 for 24%)
  int get progressPercentage => (progressRatio * 100).toInt();

  /// Formatted target amount string (e.g., "Rs. 50,000")
  String get formattedTargetAmount => 'Rs. ${_formatNumber(targetAmount)}';

  /// Formatted current amount string (e.g., "Rs. 12,000")
  String get formattedCurrentAmount => 'Rs. ${_formatNumber(currentAmount)}';

  /// Formatted progress overview (e.g., "Rs. 12,000 / 50,000")
  String get formattedProgressOverview =>
      'Rs. ${_formatNumber(currentAmount)} / ${_formatNumber(targetAmount)}';

  /// Formatted monthly contribution string
  String get formattedMonthlyContribution =>
      'Rs. ${_formatNumber(monthlyContribution)} / month';

  /// Formats double amount into a readable comma-separated integer string
  static String _formatNumber(double amount) {
    final intVal = amount.toInt();
    final str = intVal.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  /// Converts this model into a map for SQLite and Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'monthly_contribution': monthlyContribution,
      'target_date': targetDate,
      'created_date': createdDate,
      'icon_code': icon.codePoint,
      'icon_font_family': icon.fontFamily ?? 'MaterialIcons',
      'color_value': color.toARGB32(),
      'background_color_value': backgroundColor.toARGB32(),
      'updated_at': updatedAt == 0 ? DateTime.now().millisecondsSinceEpoch : updatedAt,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  /// Recreates a SavingGoalModel from an SQLite or Firestore record
  factory SavingGoalModel.fromMap(Map<String, dynamic> map) {
    final iconCode = map['icon_code'] is int
        ? map['icon_code'] as int
        : (int.tryParse(map['icon_code']?.toString() ?? '') ?? Icons.flag_rounded.codePoint);
    final fontFamily = map['icon_font_family'] as String? ?? 'MaterialIcons';

    final colorVal = map['color_value'] is int
        ? map['color_value'] as int
        : (int.tryParse(map['color_value']?.toString() ?? '') ?? 0xFFFF477E);
    final bgVal = map['background_color_value'] is int
        ? map['background_color_value'] as int
        : (int.tryParse(map['background_color_value']?.toString() ?? '') ?? 0xFFFFEDF3);

    return SavingGoalModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Savings Goal',
      targetAmount: (map['target_amount'] is num) ? (map['target_amount'] as num).toDouble() : 0.0,
      currentAmount: (map['current_amount'] is num) ? (map['current_amount'] as num).toDouble() : 0.0,
      monthlyContribution: (map['monthly_contribution'] is num) ? (map['monthly_contribution'] as num).toDouble() : 0.0,
      targetDate: map['target_date']?.toString() ?? 'Dec 2025',
      createdDate: map['created_date']?.toString() ?? 'Today',
      icon: IconData(iconCode, fontFamily: fontFamily),
      color: Color(colorVal),
      backgroundColor: Color(bgVal),
      updatedAt: (map['updated_at'] is num) ? (map['updated_at'] as num).toInt() : 0,
      isSynced: (map['is_synced'] == 1 || map['is_synced'] == true),
    );
  }

  SavingGoalModel copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    double? monthlyContribution,
    String? targetDate,
    String? createdDate,
    IconData? icon,
    Color? color,
    Color? backgroundColor,
    int? updatedAt,
    bool? isSynced,
  }) {
    return SavingGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      targetDate: targetDate ?? this.targetDate,
      createdDate: createdDate ?? this.createdDate,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
