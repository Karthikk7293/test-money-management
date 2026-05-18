import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAll();
  Future<Category> create(String name);
  Future<void> softDelete(String id);

  // sync helpers used by the sync feature
  Future<List<Category>> getUnsynced();
  Future<List<Category>> getPendingDeletions();
  Future<void> markSynced(List<String> ids);
  Future<void> purgeDeleted(List<String> ids);
}
