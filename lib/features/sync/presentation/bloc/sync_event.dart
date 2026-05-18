part of 'sync_bloc.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();
  @override
  List<Object?> get props => [];
}

class SyncBootstrapRequested extends SyncEvent {
  const SyncBootstrapRequested();
}

class SyncRunRequested extends SyncEvent {
  const SyncRunRequested();
}

class SyncPendingRefreshed extends SyncEvent {
  const SyncPendingRefreshed();
}
