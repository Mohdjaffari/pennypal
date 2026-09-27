import 'package:flutter/material.dart';

/// Represents a single bar column in the analytics bar chart.
class BarChartDataPoint {
  final String label;
  final double percentage; // Value between 0.0 and 1.0
  final Color color;
  final double? amount;

  const BarChartDataPoint({
    required this.label,
    required this.percentage,
    required this.color,
    this.amount,
  });

  /// Formatted amount string if available
  String? get formattedAmount => amount != null ? 'Rs. ${amount!.toInt()}' : null;
}

/// Represents paired bars for Income vs Expenses comparison.
class ComparisonBarDataPoint {
  final String label;
  final double incomeAmount;
  final double expenseAmount;
  final double incomePct;
  final double expensePct;

  const ComparisonBarDataPoint({
    required this.label,
    required this.incomeAmount,
    required this.expenseAmount,
    required this.incomePct,
    required this.expensePct,
  });

  String get formattedIncome => 'Rs. ${incomeAmount.toInt()}';
  String get formattedExpense => 'Rs. ${expenseAmount.toInt()}';
  double get netFlow => incomeAmount - expenseAmount;
}

/// Represents a data point for a continuous spline/area trend line.
class CashFlowTrendPoint {
  final String label;
  final double value; // e.g. net savings or cumulative balance
  final double normalizedHeight; // 0.0 to 1.0 for canvas plotting

  const CashFlowTrendPoint({
    required this.label,
    required this.value,
    required this.normalizedHeight,
  });
}

/// Represents budget utilization metrics for category health monitoring.
class BudgetHealthMetric {
  final String category;
  final double spent;
  final double budget;
  final IconData icon;
  final Color color;

  const BudgetHealthMetric({
    required this.category,
    required this.spent,
    required this.budget,
    required this.icon,
    required this.color,
  });

  double get ratio => (spent / budget).clamp(0.0, 1.5);
  int get percentageInt => (ratio * 100).round();
  bool get isOverBudget => spent > budget;
  bool get isNearLimit => ratio >= 0.85 && !isOverBudget;
}

/// Represents a category slice for the spending donut chart and legend.
class CategorySpendingData {
  final String name;
  final double percentage; // Value between 0.0 and 1.0
  final Color color;
  final double? amount;
  final IconData? icon;

  const CategorySpendingData({
    required this.name,
    required this.percentage,
    required this.color,
    this.amount,
    this.icon,
  });

  /// Integer percentage representation, e.g. 34 for 34%
  int get percentageInt => (percentage * 100).round();

  /// Formatted amount string if available
  String? get formattedAmount => amount != null ? 'Rs. ${amount!.toInt()}' : null;
}
