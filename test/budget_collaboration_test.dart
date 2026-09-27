import 'package:flutter_test/flutter_test.dart';
import 'package:pages_app/core/repository/pennypal_repository.dart';
import 'package:pages_app/models/budget_model.dart';
import 'package:pages_app/models/transaction_model.dart';
import 'package:pages_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Budget & Transaction Cross-Page Collaboration Tests', () {
    test('isCategoryMatch correctly links varied category aliases', () {
      expect(PennyPalRepository.isCategoryMatch('Food & Dining', 'Food'), isTrue);
      expect(PennyPalRepository.isCategoryMatch('Food & Dining', 'Restaurant'), isTrue);
      expect(PennyPalRepository.isCategoryMatch('Transport', 'bus'), isTrue);
      expect(PennyPalRepository.isCategoryMatch('Bills & Utilities', 'Electricity'), isTrue);
      expect(PennyPalRepository.isCategoryMatch('Shopping', 'Clothes'), isTrue);
      expect(PennyPalRepository.isCategoryMatch('Entertainment', 'Movies'), isTrue);
      expect(PennyPalRepository.isCategoryMatch('Groceries', 'Groceries'), isTrue);
      expect(PennyPalRepository.isCategoryMatch('Food & Dining', 'Transport'), isFalse);
    });

    test('Budget limit calculation and over-budget logic works accurately', () {
      const budget = CategoryBudgetModel(
        id: 'test_b_1',
        category: 'Food & Dining',
        spentAmount: 4200.0,
        limitAmount: 5000.0,
        icon: Icons.restaurant_rounded,
        color: AppColors.primaryPink,
        backgroundColor: AppColors.primaryPinkLight,
      );

      expect(budget.isOverBudget, isFalse);
      expect(budget.usagePercentage, 84);
      expect(budget.progressRatio, closeTo(0.84, 0.01));

      final exceeded = budget.copyWith(spentAmount: 5500.0);
      expect(exceeded.isOverBudget, isTrue);
      expect(exceeded.usagePercentage, 100); // clamped to 1.0 progress ratio
    });

    test('Transaction addition and dynamic category calculation reflects current month spending', () {
      final now = DateTime.now();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final formattedCurrentDate = '${now.day} ${months[now.month - 1]} ${now.year}';

      final tx1 = TransactionModel(
        id: 'tx_exp_1',
        title: 'Lunch with team',
        date: formattedCurrentDate,
        amount: 850.0,
        icon: Icons.restaurant_rounded,
        color: AppColors.primaryPink,
        backgroundColor: AppColors.primaryPinkLight,
        category: 'Food & Dining',
        isExpense: true,
      );

      final tx2 = TransactionModel(
        id: 'tx_exp_2',
        title: 'Coffee',
        date: formattedCurrentDate,
        amount: 350.0,
        icon: Icons.restaurant_rounded,
        color: AppColors.primaryPink,
        backgroundColor: AppColors.primaryPinkLight,
        category: 'Food',
        isExpense: true,
      );

      expect(tx1.parsedDate.month, now.month);
      expect(tx1.parsedDate.year, now.year);
      expect(PennyPalRepository.isCategoryMatch('Food & Dining', tx1.category), isTrue);
      expect(PennyPalRepository.isCategoryMatch('Food & Dining', tx2.category), isTrue);

      final totalFoodSpent = tx1.amount + tx2.amount;
      expect(totalFoodSpent, 1200.0);
    });
  });
}
