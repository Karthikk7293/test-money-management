import 'package:sqflite/sqflite.dart';

import '../../../../core/services/database_service.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getAll();
  Future<List<TransactionModel>> getRecent({int limit});
  Future<DashboardSummary> getSummary();
  Future<double> getCurrentMonthDebitTotal();
  Future<TransactionModel> insert({
    required double amount,
    required String note,
    required TransactionType type,
    required String categoryId,
    DateTime? timestamp,
  });
  Future<void> softDelete(String id);
  Future<List<TransactionModel>> getUnsynced();
  Future<List<TransactionModel>> getPendingDeletions();
  Future<void> markSynced(List<String> ids);
  Future<void> purgeDeleted(List<String> ids);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  TransactionLocalDataSourceImpl(this._db);
  final DatabaseService _db;

  static const String _joinSelect = '''
    SELECT t.id, t.amount, t.note, t.type, t.category_id,
           t.timestamp, t.is_synced, t.is_deleted,
           c.name AS category_name
    FROM transactions t
    LEFT JOIN categories c ON c.id = t.category_id
  ''';

  @override
  Future<List<TransactionModel>> getAll() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '$_joinSelect WHERE t.is_deleted = 0 ORDER BY t.timestamp DESC',
    );
    return rows.map(TransactionModel.fromJoinedMap).toList();
  }

  @override
  Future<List<TransactionModel>> getRecent({int limit = 10}) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '$_joinSelect WHERE t.is_deleted = 0 ORDER BY t.timestamp DESC LIMIT ?',
      [limit],
    );
    return rows.map(TransactionModel.fromJoinedMap).toList();
  }

  @override
  Future<DashboardSummary> getSummary() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT type, SUM(amount) AS total
      FROM transactions
      WHERE is_deleted = 0
      GROUP BY type
    ''');
    double income = 0, expense = 0;
    for (final row in rows) {
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      if (row['type'] == 'credit') {
        income = total;
      } else {
        expense = total;
      }
    }
    final monthExpense = await getCurrentMonthDebitTotal();
    return DashboardSummary(
      totalIncome: income,
      totalExpense: expense,
      monthExpense: monthExpense,
    );
  }

  @override
  Future<double> getCurrentMonthDebitTotal() async {
    final db = await _db.database;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1).toIso8601String();
    final nextMonth = DateTime(now.year, now.month + 1, 1).toIso8601String();
    final rows = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM transactions
      WHERE is_deleted = 0
        AND type = 'debit'
        AND timestamp >= ?
        AND timestamp < ?
    ''', [monthStart, nextMonth]);
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Future<TransactionModel> insert({
    required double amount,
    required String note,
    required TransactionType type,
    required String categoryId,
    DateTime? timestamp,
  }) async {
    final db = await _db.database;
    final id = UuidGenerator.v4();
    final ts = (timestamp ?? DateTime.now()).toUtc();
    await db.insert('transactions', {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type.asString,
      'category_id': categoryId,
      'timestamp': ts.toIso8601String(),
      'is_synced': 0,
      'is_deleted': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Pull the joined row back so the new entity has the category name.
    final rows = await db.rawQuery(
      '$_joinSelect WHERE t.id = ?',
      [id],
    );
    return TransactionModel.fromJoinedMap(rows.first);
  }

  @override
  Future<void> softDelete(String id) async {
    final db = await _db.database;
    await db.update(
      'transactions',
      {'is_deleted': 1, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<TransactionModel>> getUnsynced() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '$_joinSelect WHERE t.is_synced = 0 AND t.is_deleted = 0',
    );
    return rows.map(TransactionModel.fromJoinedMap).toList();
  }

  @override
  Future<List<TransactionModel>> getPendingDeletions() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '$_joinSelect WHERE t.is_deleted = 1',
    );
    return rows.map(TransactionModel.fromJoinedMap).toList();
  }

  @override
  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE transactions SET is_synced = 1 WHERE id IN ($placeholders)',
      ids,
    );
  }

  @override
  Future<void> purgeDeleted(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawDelete(
      'DELETE FROM transactions WHERE id IN ($placeholders)',
      ids,
    );
  }
}
