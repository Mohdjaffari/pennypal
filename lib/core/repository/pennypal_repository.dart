import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';
import '../../models/saving_goal_model.dart';
import '../database/local_database_service.dart';
import '../network/connectivity_service.dart';
import '../firebase/firebase_config.dart';
import '../firebase/firebase_sync_service.dart';

/// Clean, human-engineered offline-first Repository for PennyPal.
/// Orchestrates local SQLite persistence, automatic online sync,
/// and reactive broadcast updates for the UI.
class PennyPalRepository {
  PennyPalRepository._internal();
  static final PennyPalRepository instance = PennyPalRepository._internal();

  final LocalDatabaseService _localDb = LocalDatabaseService.instance;
  final FirebaseSyncService _syncService = FirebaseSyncService.instance;
  final ConnectivityService _connectivity = ConnectivityService.instance;

  final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isSyncingNotifier = ValueNotifier<bool>(false);

  final StreamController<List<TransactionModel>> _transactionsController =
      StreamController<List<TransactionModel>>.broadcast();
  Stream<List<TransactionModel>> get transactionsStream =>
      _transactionsController.stream;

  final StreamController<List<CategoryBudgetModel>> _budgetsController =
      StreamController<List<CategoryBudgetModel>>.broadcast();
  Stream<List<CategoryBudgetModel>> get budgetsStream =>
      _budgetsController.stream;

  final StreamController<List<SavingGoalModel>> _goalsController =
      StreamController<List<SavingGoalModel>>.broadcast();
  Stream<List<SavingGoalModel>> get goalsStream => _goalsController.stream;

  bool _initialized = false;
  String _currentUserId = 'default_user';

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Initialize SQLite / Local Storage
    await _localDb.init();

    // 2. Initialize Connectivity Monitor
    await _connectivity.init();
    isOnlineNotifier.value = _connectivity.isOnline;
    _connectivity.onConnectivityChanged.listen((online) {
      isOnlineNotifier.value = online;
      if (online) {
        // Automatically sync pending items when connectivity is restored!
        syncNow();
      }
    });

    // 3. Initialize Firebase
    await FirebaseConfig.initialize();

    // 4. Retrieve Active User ID
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId') ?? 'user_umair_khan';

    // 5. Purge any legacy dummy data to guarantee clean database-first operation
    await _purgeLegacyDummyData();

    // 6. Broadcast initial datasets
    await refreshAll();

    // 7. Background sync if online
    if (_connectivity.isOnline) {
      unawaited(syncNow());
    }

    _initialized = true;
  }

  Future<void> _purgeLegacyDummyData() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPurged = prefs.getBool('dummy_data_purged_v3') ?? false;
    if (!hasPurged) {
      await _localDb.deleteTransaction('tx_1');
      await _localDb.deleteTransaction('tx_2');
      await _localDb.deleteTransaction('tx_3');
      await _localDb.deleteTransaction('tx_4');
      await _localDb.deleteGoal('goal_laptop');
      await _localDb.deleteGoal('goal_fund');
      await prefs.setBool('dummy_data_purged_v3', true);
    }
  }

  // =========================================================================
  // TRANSACTIONS
  // =========================================================================

  Future<List<TransactionModel>> getTransactions() async {
    return await _localDb.getAllTransactions();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final withMeta = transaction.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isSynced: false,
    );

    // 1. Commit to SQLite immediately (Offline First)
    await _localDb.insertTransaction(withMeta);

    // 2. Queue for Firebase sync
    await _localDb.addToSyncQueue(
      entityType: 'transactions',
      entityId: withMeta.id,
      action: 'create',
      payload: withMeta.toMap(),
    );

    // 3. Broadcast to listeners
    await refreshTransactions();
    await refreshBudgets();

    // 4. Trigger cloud sync if online
    if (_connectivity.isOnline) {
      syncNow();
    }
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    final withMeta = transaction.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isSynced: false,
    );

    // 1. Insert or update in SQLite
    await _localDb.insertTransaction(withMeta);

    // 2. Queue for Firebase sync
    await _localDb.addToSyncQueue(
      entityType: 'transactions',
      entityId: withMeta.id,
      action: 'update',
      payload: withMeta.toMap(),
    );

    // 3. Broadcast to listeners
    await refreshTransactions();
    await refreshBudgets();

    // 4. Trigger cloud sync if online
    if (_connectivity.isOnline) {
      syncNow();
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await saveTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    // 1. Remove from SQLite
    await _localDb.deleteTransaction(id);

    // 2. Queue deletion for Firebase
    await _localDb.addToSyncQueue(
      entityType: 'transactions',
      entityId: id,
      action: 'delete',
      payload: {'id': id},
    );

    // 3. Broadcast
    await refreshTransactions();
    await refreshBudgets();

    if (_connectivity.isOnline) {
      syncNow();
    }
  }

  // =========================================================================
  // BUDGETS
  // =========================================================================

  /// Normalizes and matches category strings across budgets and transactions
  static bool isCategoryMatch(String budgetCategory, String expenseCategory) {
    final b = budgetCategory.trim().toLowerCase();
    final e = expenseCategory.trim().toLowerCase();
    if (b == e) return true;
    if (b.contains(e) || e.contains(b)) return true;
    if ((b.contains('food') || b.contains('dining') || b.contains('restaurant')) &&
        (e.contains('food') || e.contains('dining') || e.contains('restaurant') || e.contains('cafe'))) {
      return true;
    }
    if ((b.contains('bill') || b.contains('utilit')) &&
        (e.contains('bill') || e.contains('utilit') || e.contains('electricity') || e.contains('water'))) {
      return true;
    }
    if ((b.contains('transp') || b.contains('commute') || b.contains('bus') || b.contains('fuel')) &&
        (e.contains('transp') || e.contains('commute') || e.contains('bus') || e.contains('fuel') || e.contains('uber') || e.contains('taxi'))) {
      return true;
    }
    if (b.contains('grocer') && (e.contains('grocer') || e.contains('supermarket'))) return true;
    if ((b.contains('shop') || b.contains('cloth')) &&
        (e.contains('shop') || e.contains('cloth') || e.contains('store') || e.contains('mall'))) {
      return true;
    }
    if ((b.contains('entertain') || b.contains('movie') || b.contains('fun')) &&
        (e.contains('entertain') || e.contains('movie') || e.contains('cinema') || e.contains('game'))) {
      return true;
    }
    if ((b.contains('health') || b.contains('medic') || b.contains('fitness')) &&
        (e.contains('health') || e.contains('medic') || e.contains('pharma') || e.contains('gym') || e.contains('fitness'))) {
      return true;
    }
    return false;
  }

  Future<List<CategoryBudgetModel>> getBudgets() async {
    final rawBudgets = await _localDb.getAllBudgets();
    final transactions = await _localDb.getAllTransactions();
    final now = DateTime.now();

    final currentMonthExpenses = transactions.where((tx) {
      if (!tx.isExpense) return false;
      final d = tx.parsedDate;
      return d.year == now.year && d.month == now.month;
    }).toList();

    return rawBudgets.map((budget) {
      if (currentMonthExpenses.isEmpty) {
        return budget;
      }

      double dynamicSpent = 0.0;
      bool hasMatchingTx = false;
      for (final tx in currentMonthExpenses) {
        if (isCategoryMatch(budget.category, tx.category)) {
          dynamicSpent += tx.amount;
          hasMatchingTx = true;
        }
      }

      final finalSpent = hasMatchingTx ? dynamicSpent : 0.0;
      return budget.copyWith(spentAmount: finalSpent);
    }).toList();
  }

  Future<void> saveBudget(CategoryBudgetModel budget) async {
    final withMeta = budget.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isSynced: false,
    );

    await _localDb.insertOrUpdateBudget(withMeta);
    await _localDb.addToSyncQueue(
      entityType: 'budgets',
      entityId: withMeta.id,
      action: 'update',
      payload: withMeta.toMap(),
    );

    await refreshBudgets();

    if (_connectivity.isOnline) {
      syncNow();
    }
  }

  Future<void> deleteBudget(String id) async {
    await _localDb.deleteBudget(id);
    await _localDb.addToSyncQueue(
      entityType: 'budgets',
      entityId: id,
      action: 'delete',
      payload: {'id': id},
    );

    await refreshBudgets();

    if (_connectivity.isOnline) {
      syncNow();
    }
  }

  // =========================================================================
  // SAVINGS GOALS
  // =========================================================================

  Future<List<SavingGoalModel>> getGoals() async {
    return await _localDb.getAllGoals();
  }

  Future<void> saveGoal(SavingGoalModel goal) async {
    final withMeta = goal.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isSynced: false,
    );

    await _localDb.insertOrUpdateGoal(withMeta);
    await _localDb.addToSyncQueue(
      entityType: 'goals',
      entityId: withMeta.id,
      action: 'update',
      payload: withMeta.toMap(),
    );

    await refreshGoals();

    if (_connectivity.isOnline) {
      syncNow();
    }
  }

  Future<void> addMoneyToGoal(String goalId, double amount) async {
    final goals = await getGoals();
    final index = goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = goals[index];
      final updated = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );
      await saveGoal(updated);
    }
  }

  Future<void> deleteGoal(String id) async {
    await _localDb.deleteGoal(id);
    await _localDb.addToSyncQueue(
      entityType: 'goals',
      entityId: id,
      action: 'delete',
      payload: {'id': id},
    );
    await refreshGoals();
    if (_connectivity.isOnline) {
      syncNow();
    }
  }

  // =========================================================================
  // SYNC & REFRESH
  // =========================================================================

  Future<void> syncNow() async {
    if (isSyncingNotifier.value) return;
    if (!_connectivity.isOnline) return;

    try {
      isSyncingNotifier.value = true;

      // 1. Push local SQLite offline queue to Cloud Firestore
      await _syncService.pushLocalChangesToFirestore(_currentUserId);

      // 2. Pull remote updates from Cloud Firestore into SQLite
      await _syncService.pullRemoteChangesFromFirestore(_currentUserId);

      // 3. Refresh UI datasets from SQLite
      await refreshAll();
    } catch (e) {
      debugPrint('[PennyPalRepository] Sync note: $e');
    } finally {
      isSyncingNotifier.value = false;
    }
  }

  Future<void> refreshTransactions() async {
    final list = await _localDb.getAllTransactions();
    _transactionsController.add(list);
  }

  Future<void> refreshBudgets() async {
    final list = await getBudgets();
    _budgetsController.add(list);
  }

  Future<void> refreshGoals() async {
    final list = await _localDb.getAllGoals();
    _goalsController.add(list);
  }

  Future<void> refreshAll() async {
    await refreshTransactions();
    await refreshBudgets();
    await refreshGoals();
  }

  void dispose() {
    _transactionsController.close();
    _budgetsController.close();
    _goalsController.close();
    isOnlineNotifier.dispose();
    isSyncingNotifier.dispose();
  }
}
