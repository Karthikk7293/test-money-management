part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class CategoriesRequested extends CategoryEvent {
  const CategoriesRequested();
}

class CategoriesRefreshed extends CategoryEvent {
  const CategoriesRefreshed();
}

class CategoryAdded extends CategoryEvent {
  const CategoryAdded(this.name);
  final String name;
  @override
  List<Object?> get props => [name];
}

class CategoryDeleted extends CategoryEvent {
  const CategoryDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
