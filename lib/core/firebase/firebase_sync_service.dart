import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../database/local_database_service.dart';
import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';
import '../../models/saving_goal_model.dart';
import 'firebase_config.dart';

enum SyncState { idle, syncing, success, offline, error }

/// Cloud Firestore synchronization service coordinating offline SQLite
/// records with remote Firebase Firestore storage.
class FirebaseSyncService {
  FirebaseSyncService._internal();
  static final FirebaseSyncService instance = FirebaseSyncService._internal();

  FirebaseFirestore? _firestore;

  FirebaseFirestore? get firestore {
    try {
      if (!FirebaseConfig.isInitialized || Firebase.apps.isEmpty) return null;
      _firestore ??= FirebaseFirestore.instance;
      return _firestore;
    } catch (e) {
      debugPrint('[FirebaseSyncService] Cloud Firestore not ready: $e');
      return null;
    }
  }

  /// Syncs all locally queued operations to Firebase Firestore
  Future<SyncState> pushLocalChangesToFirestore(String userId) async {
    final db = firestore;
    if (db == null) {
      debugPrint('[FirebaseSyncService] Operating in local SQLite mode; changes secured locally.');
      return SyncState.offline;
    }

    try {
      final queueItems = await LocalDatabaseService.instance.getPendingSyncItems();
      if (queueItems.isEmpty) {
        final allTx = await LocalDatabaseService.instance.getAllTransactions();
        final unsynced = allTx.where((tx) => !tx.isSynced).toList();
        for (var tx in unsynced) {
          await db
              .collection('users')
              .doc(userId)
              .collection('transactions')
              .doc(tx.id)
              .set(tx.toMap(), SetOptions(merge: true));

          await LocalDatabaseService.instance.markTransactionSynced(tx.id);
        }
        return SyncState.success;
      }

      for (var item in queueItems) {
        final queueId = item['id'] as String;
        final entityType = item['entity_type'] as String;
        final entityId = item['entity_id'] as String;
        final action = item['action'] as String;
        final payload = jsonDecode(item['payload'] as String) as Map<String, dynamic>;

        final collectionRef = db.collection('users').doc(userId).collection(entityType);

        if (action == 'delete') {
          await collectionRef.doc(entityId).delete();
        } else {
          await collectionRef.doc(entityId).set(payload, SetOptions(merge: true));
        }

        if (entityType == 'transactions') {
          await LocalDatabaseService.instance.markTransactionSynced(entityId);
        }
        await LocalDatabaseService.instance.removeSyncQueueItem(queueId);
      }

      return SyncState.success;
    } catch (e) {
      debugPrint('[FirebaseSyncService] Error pushing changes to Firestore: $e');
      return SyncState.error;
    }
  }

  /// Pulls the latest records from Cloud Firestore into the local SQLite database
  Future<SyncState> pullRemoteChangesFromFirestore(String userId) async {
    final db = firestore;
    if (db == null) return SyncState.offline;

    try {
      // 1. Transactions
      final txSnapshot = await db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      for (var doc in txSnapshot.docs) {
        final data = doc.data();
        data['is_synced'] = 1;
        final tx = TransactionModel.fromMap(data);
        await LocalDatabaseService.instance.insertTransaction(tx);
      }

      // 2. Budgets
      final budgetSnapshot = await db
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .get();

      for (var doc in budgetSnapshot.docs) {
        final data = doc.data();
        data['is_synced'] = 1;
        final budget = CategoryBudgetModel.fromMap(data);
        await LocalDatabaseService.instance.insertOrUpdateBudget(budget);
      }

      // 3. Goals
      final goalsSnapshot = await db
          .collection('users')
          .doc(userId)
          .collection('goals')
          .get();

      for (var doc in goalsSnapshot.docs) {
        final data = doc.data();
        data['is_synced'] = 1;
        final goal = SavingGoalModel.fromMap(data);
        await LocalDatabaseService.instance.insertOrUpdateGoal(goal);
      }

      return SyncState.success;
    } catch (e) {
      debugPrint('[FirebaseSyncService] Error pulling remote changes: $e');
      return SyncState.error;
    }
  }
}
