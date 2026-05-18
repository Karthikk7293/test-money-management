import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.note,
    required super.type,
    required super.categoryId,
    required super.categoryName,
    required super.timestamp,
    super.isSynced,
    super.isDeleted,
  });

  /// Constructs from a JOIN query that produces a `category_name` column.
  factory TransactionModel.fromJoinedMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: (map['note'] as String?) ?? '',
      type: TransactionTypeX.fromString(map['type'] as String),
      categoryId: map['category_id'] as String,
      categoryName: (map['category_name'] as String?) ?? 'Uncategorised',
      timestamp: DateTime.parse(map['timestamp'] as String),
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type.asString,
      'category_id': categoryId,
      'timestamp': timestamp.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  Map<String, dynamic> toRemoteJson() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type.asString,
      'category_id': categoryId,
      'timestamp': Formatters.sqlDateTime(timestamp),
    };
  }
}
