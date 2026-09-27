import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as p;
import '../database/database_tables.dart';

/// Result wrapper for auth operations
class AuthResult {
  final bool success;
  final String? error;
  final UserRecord? user;

  const AuthResult._({required this.success, this.error, this.user});

  factory AuthResult.ok(UserRecord user) =>
      AuthResult._(success: true, user: user);

  factory AuthResult.fail(String error) =>
      AuthResult._(success: false, error: error);
}

/// A single user record from the database
class UserRecord {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? securityQuestion;

  const UserRecord({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.securityQuestion,
  });

  factory UserRecord.fromMap(Map<String, dynamic> map) {
    return UserRecord(
      id: map[DatabaseTables.colId] as String,
      fullName: map[DatabaseTables.colFullName] as String,
      email: map[DatabaseTables.colEmail] as String,
      phone: map[DatabaseTables.colPhone] as String?,
      securityQuestion: map[DatabaseTables.colSecurityQuestion] as String?,
    );
  }
}

/// Professional SQLite-backed User Auth Repository.
class UserAuthRepository {
  UserAuthRepository._internal();
  static final UserAuthRepository instance = UserAuthRepository._internal();

  sqflite.Database? _db;

  Future<sqflite.Database> get _database async {
    if (_db != null) return _db!;
    final dbPath = await sqflite.getDatabasesPath();
    final path = p.join(dbPath, DatabaseTables.databaseName);

    _db = await sqflite.openDatabase(
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
          try {
            await db.execute(DatabaseTables.createUsersTable);
          } catch (_) {}
        }
      },
    );
    return _db!;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode('pennypal_salt_2025_$password');
    return sha256.convert(bytes).toString();
  }

  String _generateId() {
    final rand = Random.secure();
    final values = List<int>.generate(16, (_) => rand.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<bool> hasAnyAccount() async {
    try {
      if (kIsWeb) return false;
      final db = await _database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseTables.tableUsers} WHERE ${DatabaseTables.colIsActive} = 1',
      );
      final count = result.first['count'] as int? ?? 0;
      return count > 0;
    } catch (e) {
      debugPrint('[UserAuthRepository] hasAnyAccount error: $e');
      return false;
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      if (kIsWeb) return false;
      final db = await _database;
      final result = await db.query(
        DatabaseTables.tableUsers,
        where: '${DatabaseTables.colEmail} = ? AND ${DatabaseTables.colIsActive} = 1',
        whereArgs: [email.toLowerCase().trim()],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('[UserAuthRepository] emailExists error: $e');
      return false;
    }
  }

  Future<UserRecord?> findByEmail(String email) async {
    try {
      if (kIsWeb) return null;
      final db = await _database;
      final result = await db.query(
        DatabaseTables.tableUsers,
        where: '${DatabaseTables.colEmail} = ? AND ${DatabaseTables.colIsActive} = 1',
        whereArgs: [email.toLowerCase().trim()],
        limit: 1,
      );
      if (result.isEmpty) return null;
      return UserRecord.fromMap(result.first);
    } catch (e) {
      debugPrint('[UserAuthRepository] findByEmail error: $e');
      return null;
    }
  }

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? securityQuestion,
    String? securityAnswer,
  }) async {
    try {
      if (kIsWeb) return AuthResult.fail('Registration requires mobile device storage.');

      final trimmedName = fullName.trim();
      final trimmedEmail = email.toLowerCase().trim();
      final trimmedPhone = phone?.trim();

      if (trimmedName.length < 2) return AuthResult.fail('Full name must be at least 2 characters.');
      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmedEmail)) {
        return AuthResult.fail('Please enter a valid email address.');
      }
      if (password.length < 6) return AuthResult.fail('Password must be at least 6 characters.');
      if (trimmedPhone != null && trimmedPhone.isNotEmpty &&
          !RegExp(r'^[+0-9\s\-]{8,15}$').hasMatch(trimmedPhone)) {
        return AuthResult.fail('Please enter a valid phone number.');
      }

      if (await emailExists(trimmedEmail)) {
        return AuthResult.fail('An account with this email already exists. Please log in instead.');
      }

      final db = await _database;
      final id = _generateId();
      final now = DateTime.now().millisecondsSinceEpoch;
      final hashedPassword = _hashPassword(password);
      final hashedAnswer = securityAnswer != null
          ? _hashPassword(securityAnswer.toLowerCase().trim())
          : null;

      await db.insert(
        DatabaseTables.tableUsers,
        {
          DatabaseTables.colId: id,
          DatabaseTables.colFullName: trimmedName,
          DatabaseTables.colEmail: trimmedEmail,
          DatabaseTables.colPhone: trimmedPhone,
          DatabaseTables.colPasswordHash: hashedPassword,
          DatabaseTables.colSecurityQuestion: securityQuestion,
          DatabaseTables.colSecurityAnswer: hashedAnswer,
          DatabaseTables.colCreatedAt2: now,
          DatabaseTables.colIsActive: 1,
        },
        conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
      );

      final user = UserRecord(
        id: id,
        fullName: trimmedName,
        email: trimmedEmail,
        phone: trimmedPhone,
        securityQuestion: securityQuestion,
      );
      debugPrint('[UserAuthRepository] Registered: $trimmedEmail');
      return AuthResult.ok(user);
    } catch (e) {
      debugPrint('[UserAuthRepository] register error: $e');
      if (e.toString().contains('UNIQUE constraint')) {
        return AuthResult.fail('An account with this email already exists. Please log in instead.');
      }
      return AuthResult.fail('Registration failed. Please try again.');
    }
  }

  Future<AuthResult> login({required String email, required String password}) async {
    try {
      if (kIsWeb) return AuthResult.fail('Login requires mobile device storage.');
      final trimmedEmail = email.toLowerCase().trim();
      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmedEmail)) {
        return AuthResult.fail('Please enter a valid email address.');
      }
      if (password.isEmpty) return AuthResult.fail('Password is required.');

      final db = await _database;
      final result = await db.query(
        DatabaseTables.tableUsers,
        where: '${DatabaseTables.colEmail} = ? AND ${DatabaseTables.colIsActive} = 1',
        whereArgs: [trimmedEmail],
        limit: 1,
      );

      if (result.isEmpty) {
        return AuthResult.fail('No account found with this email. Please sign up first.');
      }

      final row = result.first;
      final storedHash = row[DatabaseTables.colPasswordHash] as String;
      final inputHash = _hashPassword(password);

      if (storedHash != inputHash) {
        return AuthResult.fail('Incorrect password. Please try again.');
      }

      final user = UserRecord.fromMap(row);
      debugPrint('[UserAuthRepository] Login success: $trimmedEmail');
      return AuthResult.ok(user);
    } catch (e) {
      debugPrint('[UserAuthRepository] login error: $e');
      return AuthResult.fail('Login failed. Please try again.');
    }
  }

  Future<String?> getSecurityQuestion(String email) async {
    try {
      if (kIsWeb) return null;
      final db = await _database;
      final result = await db.query(
        DatabaseTables.tableUsers,
        columns: [DatabaseTables.colSecurityQuestion],
        where: '${DatabaseTables.colEmail} = ? AND ${DatabaseTables.colIsActive} = 1',
        whereArgs: [email.toLowerCase().trim()],
        limit: 1,
      );
      if (result.isEmpty) return null;
      return result.first[DatabaseTables.colSecurityQuestion] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<AuthResult> resetPassword({
    required String email,
    required String securityAnswer,
    required String newPassword,
  }) async {
    try {
      if (kIsWeb) return AuthResult.fail('Password reset requires mobile device storage.');
      final trimmedEmail = email.toLowerCase().trim();
      if (newPassword.length < 6) return AuthResult.fail('New password must be at least 6 characters.');

      final db = await _database;
      final result = await db.query(
        DatabaseTables.tableUsers,
        where: '${DatabaseTables.colEmail} = ? AND ${DatabaseTables.colIsActive} = 1',
        whereArgs: [trimmedEmail],
        limit: 1,
      );

      if (result.isEmpty) return AuthResult.fail('No account found with this email.');

      final row = result.first;
      final storedAnswerHash = row[DatabaseTables.colSecurityAnswer] as String?;
      if (storedAnswerHash == null) {
        return AuthResult.fail('No security question set for this account.');
      }

      final inputAnswerHash = _hashPassword(securityAnswer.toLowerCase().trim());
      if (storedAnswerHash != inputAnswerHash) {
        return AuthResult.fail('Incorrect answer. Please try again.');
      }

      final newHash = _hashPassword(newPassword);
      await db.update(
        DatabaseTables.tableUsers,
        {DatabaseTables.colPasswordHash: newHash},
        where: '${DatabaseTables.colEmail} = ?',
        whereArgs: [trimmedEmail],
      );

      debugPrint('[UserAuthRepository] Password reset: $trimmedEmail');
      return AuthResult.ok(UserRecord.fromMap(row));
    } catch (e) {
      debugPrint('[UserAuthRepository] resetPassword error: $e');
      return AuthResult.fail('Password reset failed. Please try again.');
    }
  }
}
