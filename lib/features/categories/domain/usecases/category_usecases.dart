import '../entities/category.dart';
import '../repositories/category_repository.dart';

class LoadCategories {
  LoadCategories(this._repo);
  final CategoryRepository _repo;
  Future<List<Category>> call() => _repo.getAll();
}

class AddCategory {
  AddCategory(this._repo);
  final CategoryRepository _repo;
  Future<Category> call(String name) => _repo.create(name);
}

class DeleteCategory {
  DeleteCategory(this._repo);
  final CategoryRepository _repo;
  Future<void> call(String id) => _repo.softDelete(id);
}
