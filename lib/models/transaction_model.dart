import 'package:flutter/material.dart';

/// Represents a single financial transaction item.
class TransactionModel {
  final String id;
  final String title;
  final String date;
  final double amount;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String category;
  final bool isExpense;
  final String paymentMethod;
  final bool hasReceipt;
  final String note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.category,
    this.isExpense = true,
    this.paymentMethod = 'Debit Card',
    this.hasReceipt = false,
    this.note = '',
  });

  /// Formatted amount string with currency code, e.g. "Rs. 450"
  String get formattedAmount {
    // Format without decimal if whole number
    final isWhole = amount % 1 == 0;
    final formattedNum = isWhole ? amount.toInt().toString() : amount.toStringAsFixed(2);
    // Add comma formatting if large
    return 'Rs. $formattedNum';
  }
}
