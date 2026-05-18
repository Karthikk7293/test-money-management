import 'package:sqflite/sqflite.dart';

import '../../../../core/services/database_service.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAll();
  Future<CategoryModel> insert(String name);
  Future<void> softDelete(String id);
  Future<List<CategoryModel>> getUnsynced();
  Future<List<CategoryModel>> getPendingDeletions();
  Future<void> markSynced(List<String> ids);
  Future<void> purgeDeleted(List<String> ids);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  CategoryLocalDataSourceImpl(this._db);
  final DatabaseService _db;

  @override
  Future<List<CategoryModel>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(
      'categories',
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  @override
  Future<CategoryModel> insert(String name) async {
    final db = await _db.database;
    final category = CategoryModel(
      id: UuidGenerator.v4(),
      name: name.trim(),
      isSynced: false,
      isDeleted: false,
      createdAt: DateTime.now().toUtc(),
    );
    await db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return category;
  }

  @override
  Future<void> softDelete(String id) async {
    final db = await _db.database;
    await db.update(
      'categories',
      {'is_deleted': 1, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<CategoryModel>> getUnsynced() async {
    final db = await _db.database;
    final rows = await db.query(
      'categories',
      where: 'is_synced = 0 AND is_deleted = 0',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  @override
  Future<List<CategoryModel>> getPendingDeletions() async {
    final db = await _db.database;
    final rows = await db.query(
      'categories',
      where: 'is_deleted = 1',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  @override
  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE categories SET is_synced = 1 WHERE id IN ($placeholders)',
      ids,
    );
  }

  @override
  Future<void> purgeDeleted(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawDelete(
      'DELETE FROM categories WHERE id IN ($placeholders)',
      ids,
    );
  }
}
