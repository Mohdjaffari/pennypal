import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pages_app/core/database/local_database_service.dart';
import 'package:pages_app/core/repository/pennypal_repository.dart';
import 'package:pages_app/models/transaction_model.dart';
import 'package:pages_app/models/budget_model.dart';
import 'package:pages_app/models/saving_goal_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Offline-First Database & Sync Engine Tests', () {
    test('TransactionModel serialization and deserialization', () {
      final tx = TransactionModel(
        id: 'tx_test_1',
        title: 'Coffee',
        date: '21 Sep 2025',
        amount: 250.0,
        icon: Icons.coffee_rounded,
        color: Colors.brown,
        backgroundColor: Colors.brown.shade50,
        category: 'Food & Dining',
        isExpense: true,
        note: 'Morning latte',
        updatedAt: 1726900000,
        isSynced: false,
      );

      final map = tx.toMap();
      expect(map['id'], 'tx_test_1');
      expect(map['amount'], 250.0);
      expect(map['is_expense'], 1);
      expect(map['is_synced'], 0);

      final fromMap = TransactionModel.fromMap(map);
      expect(fromMap.id, tx.id);
      expect(fromMap.title, tx.title);
      expect(fromMap.amount, tx.amount);
      expect(fromMap.isExpense, true);
      expect(fromMap.formattedAmount, 'Rs. 250');
    });

    test('CategoryBudgetModel serialization and deserialization', () {
      final budget = const CategoryBudgetModel(
        id: 'b_test_1',
        category: 'Transport',
        spentAmount: 1200.0,
        limitAmount: 3000.0,
        icon: Icons.directions_bus_rounded,
        color: Colors.blue,
        backgroundColor: Colors.blueAccent,
      );

      final map = budget.toMap();
      expect(map['category'], 'Transport');
      expect(map['spent_amount'], 1200.0);

      final fromMap = CategoryBudgetModel.fromMap(map);
      expect(fromMap.category, 'Transport');
      expect(fromMap.progressRatio, 0.4);
      expect(fromMap.usagePercentage, 40);
      expect(fromMap.isOverBudget, false);
    });

    test('SavingGoalModel serialization and deserialization', () {
      final goal = const SavingGoalModel(
        id: 'goal_test_1',
        title: 'Emergency Fund',
        targetAmount: 20000.0,
        currentAmount: 5000.0,
        monthlyContribution: 2000.0,
        targetDate: 'Dec 2026',
        createdDate: 'Jan 2026',
      );

      final map = goal.toMap();
      expect(map['title'], 'Emergency Fund');
      expect(map['target_amount'], 20000.0);

      final fromMap = SavingGoalModel.fromMap(map);
      expect(fromMap.title, 'Emergency Fund');
      expect(fromMap.progressRatio, 0.25);
      expect(fromMap.progressPercentage, 25);
    });

    test('LocalDatabaseService inserts, retrieves, and deletes transactions', () async {
      final db = LocalDatabaseService.instance;
      await db.init();

      final tx = const TransactionModel(
        id: 'tx_local_100',
        title: 'Books',
        date: 'Today',
        amount: 850.0,
        icon: Icons.book_rounded,
        color: Colors.orange,
        backgroundColor: Colors.amber,
        category: 'Education',
      );

      await db.insertTransaction(tx);
      final all = await db.getAllTransactions();
      expect(all.any((item) => item.id == 'tx_local_100'), isTrue);

      await db.deleteTransaction('tx_local_100');
      final afterDelete = await db.getAllTransactions();
      expect(afterDelete.any((item) => item.id == 'tx_local_100'), isFalse);
    });

    test('PennyPalRepository initializes and manages transactions and sync state', () async {
      final repo = PennyPalRepository.instance;
      await repo.initialize();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(repo.isOnlineNotifier.value, isNotNull);

      final txList = await repo.getTransactions();
      expect(txList, isNotNull);

      final testTx = const TransactionModel(
        id: 'repo_tx_99',
        title: 'Campus Stationery',
        date: '22 Sep 2025',
        amount: 150.0,
        icon: Icons.edit_rounded,
        color: Colors.pink,
        backgroundColor: Colors.white,
        category: 'Supplies',
      );

      await repo.addTransaction(testTx);
      final updated = await repo.getTransactions();
      expect(updated.any((t) => t.id == 'repo_tx_99'), isTrue);

      await repo.deleteTransaction('repo_tx_99');
    });
  });
}
