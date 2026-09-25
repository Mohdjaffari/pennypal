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

/// Represents a category slice for the spending donut chart and legend.
class CategorySpendingData {
  final String name;
  final double percentage; // Value between 0.0 and 1.0
  final Color color;
  final double? amount;

  const CategorySpendingData({
    required this.name,
    required this.percentage,
    required this.color,
    this.amount,
  });

  /// Integer percentage representation, e.g. 34 for 34%
  int get percentageInt => (percentage * 100).round();

  /// Formatted amount string if available
  String? get formattedAmount => amount != null ? 'Rs. ${amount!.toInt()}' : null;
}
