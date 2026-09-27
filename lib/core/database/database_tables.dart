/// SQL Table and Column definitions for PennyPal's local SQLite database.
class DatabaseTables {
  DatabaseTables._();

  static const String databaseName = 'pennypal.db';
  static const int databaseVersion = 4;

  // Table Names
  static const String tableTransactions = 'transactions';
  static const String tableBudgets = 'budgets';
  static const String tableGoals = 'goals';
  static const String tableSyncQueue = 'sync_queue';
  static const String tableUsers = 'users';

  // User Columns
  static const String colEmail = 'email';
  static const String colPhone = 'phone';
  static const String colFullName = 'full_name';
  static const String colPasswordHash = 'password_hash';
  static const String colSecurityQuestion = 'security_question';
  static const String colSecurityAnswer = 'security_answer';
  static const String colCreatedAt2 = 'created_at';
  static const String colIsActive = 'is_active';

  // Common Columns
  static const String colId = 'id';
  static const String colUpdatedAt = 'updated_at';
  static const String colIsSynced = 'is_synced';

  // Transactions Columns
  static const String colTitle = 'title';
  static const String colDate = 'date';
  static const String colAmount = 'amount';
  static const String colIconCode = 'icon_code';
  static const String colIconFontFamily = 'icon_font_family';
  static const String colColorValue = 'color_value';
  static const String colBackgroundColorValue = 'background_color_value';
  static const String colCategory = 'category';
  static const String colIsExpense = 'is_expense';
  static const String colPaymentMethod = 'payment_method';
  static const String colHasReceipt = 'has_receipt';
  static const String colReceiptPath = 'receipt_path';
  static const String colNote = 'note';

  // Budgets Columns
  static const String colSpentAmount = 'spent_amount';
  static const String colLimitAmount = 'limit_amount';
  static const String colAlertThreshold = 'alert_threshold';
  static const String colEnableAlert = 'enable_alert';

  // Goals Columns
  static const String colTargetAmount = 'target_amount';
  static const String colCurrentAmount = 'current_amount';
  static const String colMonthlyContribution = 'monthly_contribution';
  static const String colTargetDate = 'target_date';
  static const String colCreatedDate = 'created_date';

  // Sync Queue Columns
  static const String colEntityType = 'entity_type';
  static const String colEntityId = 'entity_id';
  static const String colAction = 'action';
  static const String colPayload = 'payload';
  static const String colCreatedAt = 'created_at';

  // SQL Create Statements
  static const String createTransactionsTable = '''
    CREATE TABLE $tableTransactions (
      $colId TEXT PRIMARY KEY,
      $colTitle TEXT NOT NULL,
      $colDate TEXT NOT NULL,
      $colAmount REAL NOT NULL,
      $colIconCode INTEGER NOT NULL,
      $colIconFontFamily TEXT,
      $colColorValue INTEGER NOT NULL,
      $colBackgroundColorValue INTEGER NOT NULL,
      $colCategory TEXT NOT NULL,
      $colIsExpense INTEGER NOT NULL DEFAULT 1,
      $colPaymentMethod TEXT,
      $colHasReceipt INTEGER NOT NULL DEFAULT 0,
      $colReceiptPath TEXT,
      $colNote TEXT,
      $colUpdatedAt INTEGER NOT NULL,
      $colIsSynced INTEGER NOT NULL DEFAULT 0
    );
  ''';

  static const String createBudgetsTable = '''
    CREATE TABLE $tableBudgets (
      $colId TEXT PRIMARY KEY,
      $colCategory TEXT NOT NULL,
      $colSpentAmount REAL NOT NULL,
      $colLimitAmount REAL NOT NULL,
      $colIconCode INTEGER NOT NULL,
      $colIconFontFamily TEXT,
      $colColorValue INTEGER NOT NULL,
      $colBackgroundColorValue INTEGER NOT NULL,
      $colAlertThreshold REAL NOT NULL DEFAULT 0.8,
      $colEnableAlert INTEGER NOT NULL DEFAULT 1,
      $colUpdatedAt INTEGER NOT NULL,
      $colIsSynced INTEGER NOT NULL DEFAULT 0
    );
  ''';

  static const String createGoalsTable = '''
    CREATE TABLE $tableGoals (
      $colId TEXT PRIMARY KEY,
      $colTitle TEXT NOT NULL,
      $colTargetAmount REAL NOT NULL,
      $colCurrentAmount REAL NOT NULL,
      $colMonthlyContribution REAL NOT NULL,
      $colTargetDate TEXT NOT NULL,
      $colCreatedDate TEXT NOT NULL,
      $colIconCode INTEGER NOT NULL,
      $colIconFontFamily TEXT,
      $colColorValue INTEGER NOT NULL,
      $colBackgroundColorValue INTEGER NOT NULL,
      $colUpdatedAt INTEGER NOT NULL,
      $colIsSynced INTEGER NOT NULL DEFAULT 0
    );
  ''';

  static const String createSyncQueueTable = '''
    CREATE TABLE $tableSyncQueue (
      $colId TEXT PRIMARY KEY,
      $colEntityType TEXT NOT NULL,
      $colEntityId TEXT NOT NULL,
      $colAction TEXT NOT NULL,
      $colPayload TEXT NOT NULL,
      $colCreatedAt INTEGER NOT NULL
    );
  ''';

  static const String createUsersTable = '''
    CREATE TABLE $tableUsers (
      $colId TEXT PRIMARY KEY,
      $colFullName TEXT NOT NULL,
      $colEmail TEXT NOT NULL UNIQUE,
      $colPhone TEXT,
      $colPasswordHash TEXT NOT NULL,
      $colSecurityQuestion TEXT,
      $colSecurityAnswer TEXT,
      $colCreatedAt2 INTEGER NOT NULL,
      $colIsActive INTEGER NOT NULL DEFAULT 1
    );
  ''';
}
