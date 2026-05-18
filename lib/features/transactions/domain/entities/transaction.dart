import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

extension TransactionTypeX on TransactionType {
  String get asString => name;
  static TransactionType fromString(String value) {
    return value == 'credit' ? TransactionType.credit : TransactionType.debit;
  }
}

class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.timestamp,
    this.isSynced = false,
    this.isDeleted = false,
  });

  final String id;
  final double amount;
  final String note;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final DateTime timestamp;
  final bool isSynced;
  final bool isDeleted;

  bool get isCredit => type == TransactionType.credit;
  bool get isDebit => type == TransactionType.debit;

  TransactionEntity copyWith({
    double? amount,
    String? note,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    DateTime? timestamp,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return TransactionEntity(
      id: id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        note,
        type,
        categoryId,
        categoryName,
        timestamp,
        isSynced,
        isDeleted,
      ];
}
