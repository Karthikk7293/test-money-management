import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/usecases/sync_usecases.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({
    required RunSync runSync,
    required LoadPendingCounts loadPendingCounts,
    required CategoryBloc categoryBloc,
    required TransactionBloc transactionBloc,
  })  : _runSync = runSync,
        _loadPending = loadPendingCounts,
        _categoryBloc = categoryBloc,
        _transactionBloc = transactionBloc,
        super(const SyncState()) {
    on<SyncBootstrapRequested>(_onBootstrap);
    on<SyncRunRequested>(_onRun);
    on<SyncPendingRefreshed>(_onPendingRefreshed);

    _catSub = categoryBloc.stream.listen(
        (_) => isClosed ? null : add(const SyncPendingRefreshed()));
    _txnSub = transactionBloc.stream.listen(
        (_) => isClosed ? null : add(const SyncPendingRefreshed()));
  }

  final RunSync _runSync;
  final LoadPendingCounts _loadPending;
  final CategoryBloc _categoryBloc;
  final TransactionBloc _transactionBloc;
  late final StreamSubscription _catSub;
  late final StreamSubscription _txnSub;

  Future<void> _onBootstrap(
      SyncBootstrapRequested event, Emitter<SyncState> emit) async {
    await _refreshPending(emit);
  }

  Future<void> _onPendingRefreshed(
      SyncPendingRefreshed event, Emitter<SyncState> emit) async {
    if (state.status == SyncStatus.running) return;
    await _refreshPending(emit);
  }

  Future<void> _refreshPending(Emitter<SyncState> emit) async {
    try {
      final pending = await _loadPending();
      emit(state.copyWith(pending: pending));
    } catch (_) {
      // Non-fatal — silently keep stale counts.
    }
  }

  Future<void> _onRun(SyncRunRequested event, Emitter<SyncState> emit) async {
    if (state.status == SyncStatus.running) return;
    emit(state.copyWith(status: SyncStatus.running, clearError: true));
    try {
      final report = await _runSync();
      emit(state.copyWith(
        status: SyncStatus.success,
        lastReport: report,
        lastSyncedAt: DateTime.now(),
      ));
      // Refresh dependent BLoCs so the UI reflects the cleared `local` badge.
      _categoryBloc.add(const CategoriesRefreshed());
      _transactionBloc.add(const TransactionsRefreshed());
      await _refreshPending(emit);
    } catch (e) {
      emit(state.copyWith(
          status: SyncStatus.failure, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _catSub.cancel();
    await _txnSub.cancel();
    return super.close();
  }
}
