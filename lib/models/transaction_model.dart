import 'package:flutter/material.dart';

/// Represents a single financial transaction item with SQLite and Firestore serialization.
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
  final String? receiptPath;
  final String note;
  final int updatedAt;
  final bool isSynced;

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
    this.receiptPath,
    this.note = '',
    this.updatedAt = 0,
    this.isSynced = false,
  });

  /// Formatted amount string with currency code, e.g. "Rs. 450"
  String get formattedAmount {
    final isWhole = amount % 1 == 0;
    final formattedNum = isWhole ? amount.toInt().toString() : amount.toStringAsFixed(2);
    return 'Rs. $formattedNum';
  }

  /// Safely resolves the transaction's date into a valid DateTime object.
  /// Seamlessly parses ISO strings, human-friendly dates ("27 Sep 2026", "Today, 27 Sep"),
  /// slashed dates ("27/09/2026"), and falls back to [updatedAt] timestamp or current time.
  DateTime get parsedDate {
    // 1. Try ISO-8601 parsing directly (e.g. "2026-09-27")
    final iso = DateTime.tryParse(date);
    if (iso != null) return iso;

    // 2. Parse human-friendly date strings (e.g. "27 Sep 2026", "Today, 27 Sep")
    final human = _parseHumanDateString(date);
    if (human != null) return human;

    // 3. Fallback to updatedAt timestamp if available
    if (updatedAt > 0) {
      return DateTime.fromMillisecondsSinceEpoch(updatedAt);
    }

    // 4. Default to now
    return DateTime.now();
  }

  static DateTime? _parseHumanDateString(String raw) {
    if (raw.trim().isEmpty) return null;
    final now = DateTime.now();
    final lower = raw.trim().toLowerCase();

    // Check for "today"
    if (lower.startsWith('today')) {
      final afterComma = lower.replaceFirst(RegExp(r'^today[,\s]*'), '').trim();
      if (afterComma.isNotEmpty) {
        final parsedAfter = _parseHumanDateString(afterComma);
        if (parsedAfter != null) return parsedAfter;
      }
      return now;
    }

    // Check for "yesterday"
    if (lower.startsWith('yesterday')) {
      final afterComma = lower.replaceFirst(RegExp(r'^yesterday[,\s]*'), '').trim();
      if (afterComma.isNotEmpty) {
        final parsedAfter = _parseHumanDateString(afterComma);
        if (parsedAfter != null) return parsedAfter;
      }
      return now.subtract(const Duration(days: 1));
    }

    const monthMap = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
      'january': 1, 'february': 2, 'march': 3, 'april': 4,
      'june': 6, 'july': 7, 'august': 8, 'september': 9,
      'october': 10, 'november': 11, 'december': 12,
    };

    // Match "27 Sep 2026" or "27 Sep" or "27 September 2026"
    final dmyMatch = RegExp(r'(\d{1,2})\s+([a-zA-Z]+)(?:\s+(\d{4}))?').firstMatch(raw);
    if (dmyMatch != null) {
      final day = int.tryParse(dmyMatch.group(1)!) ?? 1;
      final monthName = dmyMatch.group(2)!.toLowerCase();
      final month = monthMap[monthName];
      final year = dmyMatch.group(3) != null
          ? int.tryParse(dmyMatch.group(3)!) ?? now.year
          : now.year;
      if (month != null) {
        return DateTime(year, month, day);
      }
    }

    // Match "Sep 27, 2026" or "Sep 27 2026" or "Sep 27"
    final mdyMatch = RegExp(r'([a-zA-Z]+)\s+(\d{1,2})(?:[,\s]+(\d{4}))?').firstMatch(raw);
    if (mdyMatch != null) {
      final monthName = mdyMatch.group(1)!.toLowerCase();
      final month = monthMap[monthName];
      final day = int.tryParse(mdyMatch.group(2)!) ?? 1;
      final year = mdyMatch.group(3) != null
          ? int.tryParse(mdyMatch.group(3)!) ?? now.year
          : now.year;
      if (month != null) {
        return DateTime(year, month, day);
      }
    }

    // Match "27/09/2026" or "27-09-2026"
    final slashMatch = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})').firstMatch(raw);
    if (slashMatch != null) {
      final part1 = int.tryParse(slashMatch.group(1)!) ?? 1;
      final part2 = int.tryParse(slashMatch.group(2)!) ?? 1;
      var year = int.tryParse(slashMatch.group(3)!) ?? now.year;
      if (year < 100) year += 2000;
      if (part2 <= 12) {
        return DateTime(year, part2, part1);
      } else if (part1 <= 12) {
        return DateTime(year, part1, part2);
      }
    }

    return null;
  }

  /// Converts this model into a map for SQLite and Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'amount': amount,
      'icon_code': icon.codePoint,
      'icon_font_family': icon.fontFamily ?? 'MaterialIcons',
      'color_value': color.toARGB32(),
      'background_color_value': backgroundColor.toARGB32(),
      'category': category,
      'is_expense': isExpense ? 1 : 0,
      'payment_method': paymentMethod,
      'has_receipt': hasReceipt ? 1 : 0,
      'receipt_path': receiptPath,
      'note': note,
      'updated_at': updatedAt == 0 ? DateTime.now().millisecondsSinceEpoch : updatedAt,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  /// Recreates a TransactionModel from an SQLite or Firestore record
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final iconCode = map['icon_code'] is int
        ? map['icon_code'] as int
        : (int.tryParse(map['icon_code']?.toString() ?? '') ?? Icons.receipt_long_rounded.codePoint);
    final fontFamily = map['icon_font_family'] as String? ?? 'MaterialIcons';

    final colorVal = map['color_value'] is int
        ? map['color_value'] as int
        : (int.tryParse(map['color_value']?.toString() ?? '') ?? 0xFF4361EE);
    final bgVal = map['background_color_value'] is int
        ? map['background_color_value'] as int
        : (int.tryParse(map['background_color_value']?.toString() ?? '') ?? 0xFFEEF2FF);

    return TransactionModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Transaction',
      date: map['date']?.toString() ?? 'Today',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      icon: IconData(iconCode, fontFamily: fontFamily),
      color: Color(colorVal),
      backgroundColor: Color(bgVal),
      category: map['category']?.toString() ?? 'General',
      isExpense: (map['is_expense'] == 1 || map['is_expense'] == true),
      paymentMethod: map['payment_method']?.toString() ?? 'Cash',
      hasReceipt: (map['has_receipt'] == 1 || map['has_receipt'] == true),
      receiptPath: map['receipt_path']?.toString(),
      note: map['note']?.toString() ?? '',
      updatedAt: (map['updated_at'] is num) ? (map['updated_at'] as num).toInt() : 0,
      isSynced: (map['is_synced'] == 1 || map['is_synced'] == true),
    );
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    String? date,
    double? amount,
    IconData? icon,
    Color? color,
    Color? backgroundColor,
    String? category,
    bool? isExpense,
    String? paymentMethod,
    bool? hasReceipt,
    String? receiptPath,
    String? note,
    int? updatedAt,
    bool? isSynced,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      category: category ?? this.category,
      isExpense: isExpense ?? this.isExpense,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      hasReceipt: hasReceipt ?? this.hasReceipt,
      receiptPath: receiptPath ?? this.receiptPath,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
