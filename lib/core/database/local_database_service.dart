import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';
import '../../models/saving_goal_model.dart';
import 'database_tables.dart';

/// Professional, resilient Local Database Service for PennyPal.
/// Engineered with offline-first architecture:
/// - Uses native SQLite (`sqflite`) on mobile/desktop platforms
/// - Transparently uses SharedPreferences/In-memory driver on Web (`kIsWeb`)
/// - Manages schema creation, migrations, CRUD, and offline sync queueing
class LocalDatabaseService {
  LocalDatabaseService._internal();
  static final LocalDatabaseService instance = LocalDatabaseService._internal();

  sqflite.Database? _sqliteDb;
  bool _isInitialized = false;

  // In-memory cache for Web platform execution
  final Map<String, Map<String, dynamic>> _webTransactions = {};
  final Map<String, Map<String, dynamic>> _webBudgets = {};
  final Map<String, Map<String, dynamic>> _webGoals = {};
  final List<Map<String, dynamic>> _webSyncQueue = [];

  Future<void> init() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      await _initWebStore();
      _isInitialized = true;
      return;
    }

    try {
      final dbPath = await sqflite.getDatabasesPath();
      final path = p.join(dbPath, DatabaseTables.databaseName);

      _sqliteDb = await sqflite.openDatabase(
        path,
        version: DatabaseTables.databaseVersion,
        onCreate: (db, version) async {
          await db.execute(DatabaseTables.createTransactionsTable);
          await db.execute(DatabaseTables.createBudgetsTable);
          await db.execute(DatabaseTables.createGoalsTable);
          await db.execute(DatabaseTables.createSyncQueueTable);
          await db.execute(DatabaseTables.createUsersTable);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            try {
              await db.execute(
                'ALTER TABLE ${DatabaseTables.tableTransactions} ADD COLUMN ${DatabaseTables.colReceiptPath} TEXT',
              );
            } catch (_) {}
          }
          if (oldVersion < 3) {
            // Create users table if upgrading from version < 3
            try {
              await db.execute(DatabaseTables.createUsersTable);
            } catch (_) {}
          }
          if (oldVersion < 4) {
            try {
              await db.execute(
                'ALTER TABLE ${DatabaseTables.tableBudgets} ADD COLUMN ${DatabaseTables.colAlertThreshold} REAL DEFAULT 0.8',
              );
              await db.execute(
                'ALTER TABLE ${DatabaseTables.tableBudgets} ADD COLUMN ${DatabaseTables.colEnableAlert} INTEGER DEFAULT 1',
              );
            } catch (_) {}
          }
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('[LocalDatabaseService] SQLite init failed, falling back to web store: $e');
      await _initWebStore();
      _isInitialized = true;
    }
  }

  Future<void> _initWebStore() async {
    final prefs = await SharedPreferences.getInstance();
    final txJson = prefs.getString('db_transactions');
    if (txJson != null) {
      final decoded = jsonDecode(txJson) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        _webTransactions[key] = Map<String, dynamic>.from(value as Map);
      });
    }

    final budgetJson = prefs.getString('db_budgets');
    if (budgetJson != null) {
      final decoded = jsonDecode(budgetJson) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        _webBudgets[key] = Map<String, dynamic>.from(value as Map);
      });
    }

    final goalsJson = prefs.getString('db_goals');
    if (goalsJson != null) {
      final decoded = jsonDecode(goalsJson) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        _webGoals[key] = Map<String, dynamic>.from(value as Map);
      });
    }
  }

  Future<void> _persistWebStore() async {
    if (!kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('db_transactions', jsonEncode(_webTransactions));
    await prefs.setString('db_budgets', jsonEncode(_webBudgets));
    await prefs.setString('db_goals', jsonEncode(_webGoals));
  }

  // =========================================================================
  // TRANSACTIONS CRUD
  // =========================================================================

  Future<List<TransactionModel>> getAllTransactions() async {
    await init();
    if (kIsWeb || _sqliteDb == null) {
      final list = _webTransactions.values.map((m) => TransactionModel.fromMap(m)).toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    }

    final records = await _sqliteDb!.query(
      DatabaseTables.tableTransactions,
      orderBy: '${DatabaseTables.colUpdatedAt} DESC',
    );
    return records.map((r) => TransactionModel.fromMap(r)).toList();
  }

  Future<void> insertTransaction(TransactionModel transaction) async {
    await init();
    final map = transaction.toMap();

    if (kIsWeb || _sqliteDb == null) {
      _webTransactions[transaction.id] = map;
      await _persistWebStore();
    } else {
      await _sqliteDb!.insert(
        DatabaseTables.tableTransactions,
        map,
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await init();
    final map = transaction.toMap();

    if (kIsWeb || _sqliteDb == null) {
      _webTransactions[transaction.id] = map;
      await _persistWebStore();
    } else {
      await _sqliteDb!.update(
        DatabaseTables.tableTransactions,
        map,
        where: '${DatabaseTables.colId} = ?',
        whereArgs: [transaction.id],
      );
    }
  }

  Future<void> deleteTransaction(String id) async {
    await init();
    if (kIsWeb || _sqliteDb == null) {
      _webTransactions.remove(id);
      await _persistWebStore();
    } else {
      await _sqliteDb!.delete(
        DatabaseTables.tableTransactions,
        where: '${DatabaseTables.colId} = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> markTransactionSynced(String id) async {
    await init();
    if (kIsWeb || _sqliteDb == null) {
      if (_webTransactions.containsKey(id)) {
        _webTransactions[id]!['is_synced'] = 1;
        await _persistWebStore();
      }
    } else {
      await _sqliteDb!.update(
        DatabaseTables.tableTransactions,
        {'is_synced': 1},
        where: '${DatabaseTables.colId} = ?',
        whereArgs: [id],
      );
    }
  }

  // =========================================================================
  // BUDGETS CRUD
  // =========================================================================

  Future<List<CategoryBudgetModel>> getAllBudgets() async {
    await init();
    if (kIsWeb || _sqliteDb == null) {
      if (_webBudgets.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final hasSeeded = prefs.getBool('budgets_seeded_v1') ?? false;
        if (!hasSeeded) {
          for (final b in CategoryBudgetModel.defaultBudgets) {
            _webBudgets[b.id] = b.toMap();
          }
          await prefs.setBool('budgets_seeded_v1', true);
          await _persistWebStore();
        }
      }
      return _webBudgets.values.map((m) => CategoryBudgetModel.fromMap(m)).toList();
    }

    final records = await _sqliteDb!.query(DatabaseTables.tableBudgets);
    if (records.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final hasSeeded = prefs.getBool('budgets_seeded_v1') ?? false;
      if (!hasSeeded) {
        for (final b in CategoryBudgetModel.defaultBudgets) {
          await _sqliteDb!.insert(DatabaseTables.tableBudgets, b.toMap());
        }
        await prefs.setBool('budgets_seeded_v1', true);
        final seededRecords = await _sqliteDb!.query(DatabaseTables.tableBudgets);
        return seededRecords.map((r) => CategoryBudgetModel.fromMap(r)).toList();
      }
    }
    return records.map((r) => CategoryBudgetModel.fromMap(r)).toList();
  }

  Future<void> insertOrUpdateBudget(CategoryBudgetModel budget) async {
    await init();
    final map = budget.toMap();

    if (kIsWeb || _sqliteDb == null) {
      _webBudgets[budget.id] = map;
      await _persistWebStore();
    } else {
      await _sqliteDb!.insert(
        DatabaseTables.tableBudgets,
        map,
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteBudget(String id) async {
    await init();
    if (kIsWeb || _sqliteDb == null) {
      _webBudgets.remove(id);
      await _persistWebStore();
    } else {
      await _sqliteDb!.delete(
        DatabaseTables.tableBudgets,
        where: '${DatabaseTables.colId} = ?',
        whereArgs: [id],
      );
    }
  }

  // =========================================================================
  // GOALS CRUD
  // =========================================================================

  Future<List<SavingGoalModel>> getAllGoals() async {
    await init();
    if (kIsWeb || _sqliteDb == null) {
      return _webGoals.values.map((m) => SavingGoalModel.fromMap(m)).toList();
    }

    final records = await _sqliteDb!.query(DatabaseTables.tableGoals);
    return records.map((r) => SavingGoalModel.fromMap(r)).toList();
  }

  Future<void> insertOrUpdateGoal(SavingGoalModel goal) async {
    await init();
    final map = goal.toMap();

    if (kIsWeb || _sqliteDb == null) {
      _webGoals[goal.id] = map;
      await _persistWebStore();
    } else {
      await _sqliteDb!.insert(
        DatabaseTables.tableGoals,
        map,
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteGoal(String id) async {
    await init();
    if (kIsWeb || _sqliteDb == null) {
      _webGoals.remove(id);
      await _persistWebStore();
    } else {
      await _sqliteDb!.delete(
        DatabaseTables.tableGoals,
        where: '${DatabaseTables.colId} = ?',
        whereArgs: [id],
      );
    }
  }

  // =========================================================================
  // SYNC QUEUE MANAGEMENT (OFFLINE QUEUEING)
  // =========================================================================

  Future<void> addToSyncQueue({
    required String entityType,
    required String entityId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    await init();
    final queueItem = {
      'id': 'sq_${DateTime.now().millisecondsSinceEpoch}_${payload['id'] ?? entityId}',
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };

    if (kIsWeb || _sqliteDb == null) {
      _webSyncQueue.add(queueItem);
    } else {
      await _sqliteDb!.insert(
        DatabaseTables.tableSyncQueue,
        queueItem,
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    await init();
    if (kIsWeb || _sqliteDb == null) {
      return List.from(_webSyncQueue);
    }

    return await _sqliteDb!.query(
      DatabaseTables.tableSyncQueue,
      orderBy: '${DatabaseTables.colCreatedAt} ASC',
    );
  }

  Future<void> removeSyncQueueItem(String queueId) async {
    await init();
    if (kIsWeb || _sqliteDb == null) {
      _webSyncQueue.removeWhere((item) => item['id'] == queueId);
    } else {
      await _sqliteDb!.delete(
        DatabaseTables.tableSyncQueue,
        where: '${DatabaseTables.colId} = ?',
        whereArgs: [queueId],
      );
    }
  }
}
