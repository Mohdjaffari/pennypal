import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pages_app/models/transaction_model.dart';

void main() {
  group('TransactionModel.parsedDate Tests', () {
    test('parses "27 Sep 2026" format from AddIncome/AddExpense correctly', () {
      const tx = TransactionModel(
        id: '1',
        title: 'Salary',
        date: '27 Sep 2026',
        amount: 50000,
        icon: Icons.money,
        color: Colors.green,
        backgroundColor: Colors.white,
        category: 'Salary',
        isExpense: false,
      );

      final dt = tx.parsedDate;
      expect(dt.year, 2026);
      expect(dt.month, 9);
      expect(dt.day, 27);
    });

    test('parses "Today, 27 Sep" format from AddExpenseSheet correctly', () {
      const tx = TransactionModel(
        id: '2',
        title: 'Lunch',
        date: 'Today, 27 Sep',
        amount: 450,
        icon: Icons.fastfood,
        color: Colors.red,
        backgroundColor: Colors.white,
        category: 'Food',
        isExpense: true,
      );

      final dt = tx.parsedDate;
      expect(dt.month, 9);
      expect(dt.day, 27);
    });

    test('parses ISO8601 string "2026-09-27" correctly', () {
      const tx = TransactionModel(
        id: '3',
        title: 'Freelance',
        date: '2026-09-27',
        amount: 15000,
        icon: Icons.work,
        color: Colors.blue,
        backgroundColor: Colors.white,
        category: 'Freelance',
        isExpense: false,
      );

      final dt = tx.parsedDate;
      expect(dt.year, 2026);
      expect(dt.month, 9);
      expect(dt.day, 27);
    });

    test('parses "Today" with fallback to current date', () {
      const tx = TransactionModel(
        id: '4',
        title: 'Snack',
        date: 'Today',
        amount: 120,
        icon: Icons.fastfood,
        color: Colors.orange,
        backgroundColor: Colors.white,
        category: 'Food',
        isExpense: true,
      );

      final dt = tx.parsedDate;
      final now = DateTime.now();
      expect(dt.year, now.year);
      expect(dt.month, now.month);
      expect(dt.day, now.day);
    });

    test('parses "Yesterday" with fallback to 1 day ago', () {
      const tx = TransactionModel(
        id: '5',
        title: 'Coffee',
        date: 'Yesterday',
        amount: 250,
        icon: Icons.coffee,
        color: Colors.brown,
        backgroundColor: Colors.white,
        category: 'Beverage',
        isExpense: true,
      );

      final dt = tx.parsedDate;
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(dt.year, yesterday.year);
      expect(dt.month, yesterday.month);
      expect(dt.day, yesterday.day);
    });
  });
}
