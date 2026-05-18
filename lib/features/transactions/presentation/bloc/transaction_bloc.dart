import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/usecases/transaction_usecases.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required LoadTransactions loadTransactions,
    required AddTransaction addTransaction,
    required DeleteTransaction deleteTransaction,
  })  : _load = loadTransactions,
        _add = addTransaction,
        _delete = deleteTransaction,
        super(const TransactionState()) {
    on<TransactionsRequested>(_onRequested);
    on<TransactionsRefreshed>(_onRefreshed);
    on<TransactionAdded>(_onAdded);
    on<TransactionDeleted>(_onDeleted);
  }

  final LoadTransactions _load;
  final AddTransaction _add;
  final DeleteTransaction _delete;

  Future<void> _onRequested(
      TransactionsRequested event, Emitter<TransactionState> emit) async {
    if (state.transactions.isEmpty) {
      emit(state.copyWith(status: TransactionStatus.loading));
    }
    try {
      final list = await _load();
      emit(state.copyWith(
          status: TransactionStatus.ready, transactions: list));
    } catch (e) {
      emit(state.copyWith(
          status: TransactionStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshed(
      TransactionsRefreshed event, Emitter<TransactionState> emit) async {
    try {
      final list = await _load();
      emit(state.copyWith(
          status: TransactionStatus.ready, transactions: list));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onAdded(
      TransactionAdded event, Emitter<TransactionState> emit) async {
    try {
      final created = await _add(
        amount: event.amount,
        note: event.note,
        type: event.type,
        categoryId: event.categoryId,
        timestamp: event.timestamp,
      );
      final next = [created, ...state.transactions];
      emit(state.copyWith(
          status: TransactionStatus.ready,
          transactions: next,
          clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleted(
      TransactionDeleted event, Emitter<TransactionState> emit) async {
    final next = state.transactions
        .where((t) => t.id != event.id)
        .toList(growable: false);
    emit(state.copyWith(transactions: next));
    try {
      await _delete(event.id);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
