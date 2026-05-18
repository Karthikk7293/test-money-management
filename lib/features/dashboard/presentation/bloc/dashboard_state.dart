part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, ready, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.summary,
    this.recent = const [],
    this.errorMessage,
  });

  final DashboardStatus status;
  final DashboardSummary? summary;
  final List<TransactionEntity> recent;
  final String? errorMessage;

  bool get isLoading => status == DashboardStatus.loading;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSummary? summary,
    List<TransactionEntity>? recent,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      recent: recent ?? this.recent,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, summary, recent, errorMessage];
}
