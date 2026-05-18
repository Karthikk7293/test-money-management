import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category.dart';
import '../../domain/usecases/category_usecases.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({
    required LoadCategories loadCategories,
    required AddCategory addCategory,
    required DeleteCategory deleteCategory,
  })  : _load = loadCategories,
        _add = addCategory,
        _delete = deleteCategory,
        super(const CategoryState()) {
    on<CategoriesRequested>(_onRequested);
    on<CategoryAdded>(_onAdded);
    on<CategoryDeleted>(_onDeleted);
    on<CategoriesRefreshed>(_onRefreshed);
  }

  final LoadCategories _load;
  final AddCategory _add;
  final DeleteCategory _delete;

  Future<void> _onRequested(
      CategoriesRequested event, Emitter<CategoryState> emit) async {
    if (state.categories.isEmpty) {
      emit(state.copyWith(status: CategoryStatus.loading));
    }
    try {
      final list = await _load();
      emit(state.copyWith(status: CategoryStatus.ready, categories: list));
    } catch (e) {
      emit(state.copyWith(
          status: CategoryStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshed(
      CategoriesRefreshed event, Emitter<CategoryState> emit) async {
    try {
      final list = await _load();
      emit(state.copyWith(status: CategoryStatus.ready, categories: list));
    } catch (e) {
      emit(state.copyWith(
          status: CategoryStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onAdded(
      CategoryAdded event, Emitter<CategoryState> emit) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    if (state.categories
        .any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      emit(state.copyWith(
          errorMessage: 'A category with that name already exists.'));
      return;
    }
    try {
      final created = await _add(name);
      final next = [...state.categories, created]
        ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      emit(state.copyWith(
          status: CategoryStatus.ready, categories: next, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleted(
      CategoryDeleted event, Emitter<CategoryState> emit) async {
    // Optimistic: filter out instantly so the user sees it vanish.
    final next =
        state.categories.where((c) => c.id != event.id).toList(growable: false);
    emit(state.copyWith(categories: next));
    try {
      await _delete(event.id);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
