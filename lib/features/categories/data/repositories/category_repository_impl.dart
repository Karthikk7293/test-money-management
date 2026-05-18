import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._local);
  final CategoryLocalDataSource _local;

  @override
  Future<List<Category>> getAll() => _local.getAll();

  @override
  Future<Category> create(String name) => _local.insert(name);

  @override
  Future<void> softDelete(String id) => _local.softDelete(id);

  @override
  Future<List<Category>> getUnsynced() => _local.getUnsynced();

  @override
  Future<List<Category>> getPendingDeletions() => _local.getPendingDeletions();

  @override
  Future<void> markSynced(List<String> ids) => _local.markSynced(ids);

  @override
  Future<void> purgeDeleted(List<String> ids) => _local.purgeDeleted(ids);
}
