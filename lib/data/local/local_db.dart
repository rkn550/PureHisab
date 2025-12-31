import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:purehisab/app/flavour/flavour_manager.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  static bool _isOpening = false;

  DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  String get _dbName => FlavourManager.currentFlavour.dbName;
  int get _dbVersion => FlavourManager.currentFlavour.dbVersion;

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (_isOpening) {
      while (_database == null) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _database!;
    }

    _isOpening = true;
    try {
      _database = await _initDatabase();
      if (_database == null) {
        throw Exception('Database initialization returned null');
      }
    } catch (e) {
      _isOpening = false;
      _database = null;
      throw Exception('Failed to initialize database. Please try again.');
    } finally {
      _isOpening = false;
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      if (dbPath.isEmpty) {
        throw Exception('Database path is empty');
      }
      final path = join(dbPath, _dbName);

      final database = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      await database.rawQuery('PRAGMA foreign_keys = ON');
      await database.rawQuery('PRAGMA journal_mode = WAL');
      return database;
    } catch (e) {
      throw Exception(
        'Failed to initialize database at path. Please try again.',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      return;
    }
  }

  Future<void> _createTables(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE businesses (
          id TEXT PRIMARY KEY,
          business_name TEXT NOT NULL,
          owner_name TEXT,
          phone_number TEXT,
          business_photo_url TEXT,
          is_deleted INTEGER DEFAULT 0,
          created_at INTEGER,
          updated_at INTEGER,
          user_id TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0,
          firebase_updated_at INTEGER
        )
      ''');

      await txn.execute('''
        CREATE TABLE parties (
          id TEXT PRIMARY KEY,
          party_name TEXT NOT NULL,
          phone_number TEXT,
          address TEXT,
          parties_photo_url TEXT,
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

      await txn.execute('''
        CREATE TABLE transactions (
          id TEXT PRIMARY KEY,
          amount REAL NOT NULL,
          date INTEGER NOT NULL,
          direction TEXT CHECK(direction IN ('gave','got')),
          description TEXT,
          transaction_photo_url TEXT,
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

      await txn.execute(
        'CREATE INDEX idx_business_user ON businesses(user_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_party_business ON parties(business_id)',
      );
      await txn.execute('CREATE INDEX idx_tx_party ON transactions(party_id)');
      await txn.execute(
        'CREATE INDEX idx_tx_business ON transactions(business_id)',
      );
    });
  }

  Future<Map<String, int>> getTableCounts() async {
    final db = await database;

    final results = await db.transaction((txn) async {
      final businesses =
          Sqflite.firstIntValue(
            await txn.rawQuery('SELECT COUNT(*) FROM businesses'),
          ) ??
          0;

      final parties =
          Sqflite.firstIntValue(
            await txn.rawQuery('SELECT COUNT(*) FROM parties'),
          ) ??
          0;

      final transactions =
          Sqflite.firstIntValue(
            await txn.rawQuery('SELECT COUNT(*) FROM transactions'),
          ) ??
          0;

      return {
        'businesses': businesses,
        'parties': parties,
        'transactions': transactions,
      };
    });

    return results;
  }
}
