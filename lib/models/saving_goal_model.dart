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
}
