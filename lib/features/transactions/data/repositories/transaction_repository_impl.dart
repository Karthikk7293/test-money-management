import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._local);
  final TransactionLocalDataSource _local;

  @override
  Future<List<TransactionEntity>> getAll() => _local.getAll();

  @override
  Future<List<TransactionEntity>> getRecent({int limit = 10}) =>
      _local.getRecent(limit: limit);

  @override
  Future<DashboardSummary> getSummary() => _local.getSummary();

  @override
  Future<double> getCurrentMonthDebitTotal() =>
      _local.getCurrentMonthDebitTotal();

  @override
  Future<TransactionEntity> create({
    required double amount,
    required String note,
    required TransactionType type,
    required String categoryId,
    DateTime? timestamp,
  }) {
    return _local.insert(
      amount: amount,
      note: note,
      type: type,
      categoryId: categoryId,
      timestamp: timestamp,
    );
  }

  @override
  Future<void> softDelete(String id) => _local.softDelete(id);

  @override
  Future<List<TransactionEntity>> getUnsynced() => _local.getUnsynced();

  @override
  Future<List<TransactionEntity>> getPendingDeletions() =>
      _local.getPendingDeletions();

  @override
  Future<void> markSynced(List<String> ids) => _local.markSynced(ids);

  @override
  Future<void> purgeDeleted(List<String> ids) => _local.purgeDeleted(ids);
}
