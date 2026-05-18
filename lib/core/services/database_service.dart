import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY NOT NULL,
        amount REAL NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        type TEXT NOT NULL CHECK(type IN ('credit','debit')),
        category_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_txn_category ON transactions(category_id)');
    await db.execute(
        'CREATE INDEX idx_txn_deleted ON transactions(is_deleted)');
    await db.execute(
        'CREATE INDEX idx_cat_deleted ON categories(is_deleted)');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  /// Test-only: wipes both tables.
  Future<void> reset() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('categories');
  }
}
