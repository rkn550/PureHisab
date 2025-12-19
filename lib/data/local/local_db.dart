import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'purehisab.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE businesses (
        id TEXT PRIMARY KEY,
        business_name TEXT NOT NULL,
        owner_name TEXT,
        phone_number TEXT,
        photo_url TEXT,
        is_deleted INTEGER DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER,
        user_id TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        firebase_updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE parties (
        id TEXT PRIMARY KEY,
        party_name TEXT NOT NULL,
        phone_number TEXT,
        address TEXT,
        photo_url TEXT,
        type TEXT CHECK(type IN ('customer','supplier')),
        reminder_date INTEGER,
        reminder_type TEXT,
        sms_setting INTEGER DEFAULT 0,
        sms_language TEXT,
        is_deleted INTEGER DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER,
        business_id TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        firebase_updated_at INTEGER,
        FOREIGN KEY (business_id)
          REFERENCES businesses(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        direction TEXT CHECK(direction IN ('gave','got')),
        description TEXT,
        photo_url TEXT,
        is_deleted INTEGER DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER,
        party_id TEXT NOT NULL,
        business_id TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        firebase_updated_at INTEGER,
        FOREIGN KEY (party_id)
          REFERENCES parties(id)
          ON DELETE CASCADE,
        FOREIGN KEY (business_id)
          REFERENCES businesses(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_business_user ON businesses(user_id)');
    await db.execute('CREATE INDEX idx_party_business ON parties(business_id)');
    await db.execute('CREATE INDEX idx_tx_party ON transactions(party_id)');
    await db.execute(
      'CREATE INDEX idx_tx_business ON transactions(business_id)',
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Print all tables and their data
  Future<void> printAllTables() async {
    final db = await database;

    print('\n========== DATABASE TABLES ==========\n');

    // Print businesses table
    await _printTable(db, 'businesses');

    // Print parties table
    await _printTable(db, 'parties');

    // Print transactions table
    await _printTable(db, 'transactions');

    print('\n=====================================\n');
  }

  // Print a specific table
  Future<void> printTable(String tableName) async {
    final db = await database;
    await _printTable(db, tableName);
  }

  // Helper method to print table data
  Future<void> _printTable(Database db, String tableName) async {
    try {
      // Get table schema
      final tableInfo = await db.rawQuery("PRAGMA table_info($tableName)");

      print('\n--- TABLE: $tableName ---');
      print('Columns:');
      for (var column in tableInfo) {
        print('  - ${column['name']} (${column['type']})');
      }

      // Get all data
      final data = await db.query(tableName);

      print('\nTotal Rows: ${data.length}');

      if (data.isNotEmpty) {
        print('\nData:');
        for (var i = 0; i < data.length; i++) {
          print('\nRow ${i + 1}:');
          data[i].forEach((key, value) {
            print('  $key: $value');
          });
        }
      } else {
        print('\n(No data)');
      }

      print('\n');
    } catch (e) {
      print('Error printing table $tableName: $e');
    }
  }

  // Get table count
  Future<Map<String, int>> getTableCounts() async {
    final db = await database;

    final businessesCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM businesses'),
        ) ??
        0;

    final partiesCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM parties'),
        ) ??
        0;

    final transactionsCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM transactions'),
        ) ??
        0;

    return {
      'businesses': businessesCount,
      'parties': partiesCount,
      'transactions': transactionsCount,
    };
  }

  // Print table counts
  Future<void> printTableCounts() async {
    final counts = await getTableCounts();

    print('\n========== TABLE COUNTS ==========');
    print('Businesses: ${counts['businesses']}');
    print('Parties: ${counts['parties']}');
    print('Transactions: ${counts['transactions']}');
    print('===================================\n');
  }
}
