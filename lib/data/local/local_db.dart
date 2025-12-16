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
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    /// USER
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        phone_number TEXT NOT NULL UNIQUE,
        active_business_id TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    /// BUSINESS
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
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    /// PARTY
    await db.execute('''
      CREATE TABLE parties (
        id TEXT PRIMARY KEY,
        party_name TEXT NOT NULL,
        phone_number TEXT,
        address TEXT,
        photo_url TEXT,
        type TEXT,
        reminder_date INTEGER,
        reminder_type TEXT,
        sms_setting INTEGER DEFAULT 0,
        sms_language TEXT,
        is_deleted INTEGER DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER,
        business_id TEXT NOT NULL,
        FOREIGN KEY (business_id) REFERENCES businesses(id)
      )
    ''');

    /// TRANSACTION
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        direction TEXT NOT NULL,
        description TEXT,
        photo_url TEXT,
        is_deleted INTEGER DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER,
        party_id TEXT NOT NULL,
        business_id TEXT NOT NULL,
        FOREIGN KEY (party_id) REFERENCES parties(id),
        FOREIGN KEY (business_id) REFERENCES businesses(id)
      )
    ''');
  }

  /// Close DB
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
