import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.isSynced = false,
    this.isDeleted = false,
    required this.createdAt,
  });

  final String id;
  final String name;
  final bool isSynced;
  final bool isDeleted;
  final DateTime createdAt;

  Category copyWith({
    String? name,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, isSynced, isDeleted, createdAt];
}
