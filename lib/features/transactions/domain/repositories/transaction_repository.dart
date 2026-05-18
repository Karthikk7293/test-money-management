import '../entities/transaction.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.monthExpense,
  });

  final double totalIncome;
  final double totalExpense;
  final double monthExpense;

  double get net => totalIncome - totalExpense;
}

abstract class TransactionRepository {
  /// All transactions (joined with category name) where is_deleted = 0.
  Future<List<TransactionEntity>> getAll();

  /// `limit` most recent transactions where is_deleted = 0.
  Future<List<TransactionEntity>> getRecent({int limit = 10});

  Future<DashboardSummary> getSummary();

  /// Returns the monthly debit total *after* the new transaction is persisted.
  Future<double> getCurrentMonthDebitTotal();

  Future<TransactionEntity> create({
    required double amount,
    required String note,
    required TransactionType type,
    required String categoryId,
    DateTime? timestamp,
  });

  Future<void> softDelete(String id);

  // sync helpers
  Future<List<TransactionEntity>> getUnsynced();
  Future<List<TransactionEntity>> getPendingDeletions();
  Future<void> markSynced(List<String> ids);
  Future<void> purgeDeleted(List<String> ids);
}
