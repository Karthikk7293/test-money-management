part of 'transaction_bloc.dart';

enum TransactionStatus { initial, loading, ready, failure }

class TransactionState extends Equatable {
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.errorMessage,
  });

  final TransactionStatus status;
  final List<TransactionEntity> transactions;
  final String? errorMessage;

  bool get isLoading => status == TransactionStatus.loading;

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionEntity>? transactions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage];
}
