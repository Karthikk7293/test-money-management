part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class TransactionsRequested extends TransactionEvent {
  const TransactionsRequested();
}

class TransactionsRefreshed extends TransactionEvent {
  const TransactionsRefreshed();
}

class TransactionAdded extends TransactionEvent {
  const TransactionAdded({
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    this.timestamp,
  });

  final double amount;
  final String note;
  final TransactionType type;
  final String categoryId;
  final DateTime? timestamp;

  @override
  List<Object?> get props => [amount, note, type, categoryId, timestamp];
}

class TransactionDeleted extends TransactionEvent {
  const TransactionDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
