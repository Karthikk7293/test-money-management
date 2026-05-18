part of 'sync_bloc.dart';

enum SyncStatus { idle, running, success, failure }

class SyncState extends Equatable {
  const SyncState({
    this.status = SyncStatus.idle,
    this.pending,
    this.lastReport,
    this.lastSyncedAt,
    this.errorMessage,
  });

  final SyncStatus status;
  final PendingCounts? pending;
  final SyncReport? lastReport;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  bool get isRunning => status == SyncStatus.running;
  bool get hasPending => pending?.hasAny ?? false;

  SyncState copyWith({
    SyncStatus? status,
    PendingCounts? pending,
    SyncReport? lastReport,
    DateTime? lastSyncedAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      pending: pending ?? this.pending,
      lastReport: lastReport ?? this.lastReport,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, pending, lastReport, lastSyncedAt, errorMessage];
}
