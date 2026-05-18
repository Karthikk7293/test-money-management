import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/domain/usecases/transaction_usecases.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required LoadDashboardSummary loadSummary,
    required LoadRecentTransactions loadRecent,
    required TransactionBloc transactionBloc,
  })  : _loadSummary = loadSummary,
        _loadRecent = loadRecent,
        super(const DashboardState()) {
    on<DashboardRequested>(_onRequested);
    on<DashboardRefreshed>(_onRefreshed);

    // Refresh dashboard reactively whenever transactions list changes.
    _txnSub = transactionBloc.stream.listen((_) {
      if (!isClosed) add(const DashboardRefreshed());
    });
  }

  final LoadDashboardSummary _loadSummary;
  final LoadRecentTransactions _loadRecent;
  late final StreamSubscription _txnSub;

  Future<void> _onRequested(
      DashboardRequested event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshed(
      DashboardRefreshed event, Emitter<DashboardState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<DashboardState> emit) async {
    try {
      final summary = await _loadSummary();
      final recent = await _loadRecent(limit: 10);
      emit(state.copyWith(
        status: DashboardStatus.ready,
        summary: summary,
        recent: recent,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: DashboardStatus.failure, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _txnSub.cancel();
    return super.close();
  }
}
