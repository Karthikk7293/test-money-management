import '../../../categories/data/datasources/category_local_datasource.dart';
import '../../../categories/data/datasources/category_remote_datasource.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../transactions/data/datasources/transaction_local_datasource.dart';
import '../../../transactions/data/datasources/transaction_remote_datasource.dart';
import '../../domain/repositories/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required CategoryLocalDataSource categoryLocal,
    required CategoryRemoteDataSource categoryRemote,
    required TransactionLocalDataSource transactionLocal,
    required TransactionRemoteDataSource transactionRemote,
  })  : _categoryLocal = categoryLocal,
        _categoryRemote = categoryRemote,
        _transactionLocal = transactionLocal,
        _transactionRemote = transactionRemote;

  final CategoryLocalDataSource _categoryLocal;
  final CategoryRemoteDataSource _categoryRemote;
  final TransactionLocalDataSource _transactionLocal;
  final TransactionRemoteDataSource _transactionRemote;

  @override
  Future<SyncReport> runSync() async {
    // Step A — Cloud purge (transactions first, then categories).
    final pendingDeletedTxns = await _transactionLocal.getPendingDeletions();
    int deletedTxnCount = 0;
    if (pendingDeletedTxns.isNotEmpty) {
      final ids = pendingDeletedTxns.map((t) => t.id).toList();
      final confirmed = await _transactionRemote.deleteIds(ids);
      await _transactionLocal.purgeDeleted(confirmed);
      deletedTxnCount = confirmed.length;
    }

    final pendingDeletedCats = await _categoryLocal.getPendingDeletions();
    int deletedCatCount = 0;
    if (pendingDeletedCats.isNotEmpty) {
      final ids = pendingDeletedCats.map((c) => c.id).toList();
      final confirmed = await _categoryRemote.deleteIds(ids);
      await _categoryLocal.purgeDeleted(confirmed);
      deletedCatCount = confirmed.length;
    }

    // Step B — Upload categories first, then transactions.
    final unsyncedCats = await _categoryLocal.getUnsynced();
    int uploadedCats = 0;
    if (unsyncedCats.isNotEmpty) {
      final models = unsyncedCats.map(CategoryModel.fromEntity).toList();
      final confirmed = await _categoryRemote.uploadAdditions(models);
      await _categoryLocal.markSynced(confirmed);
      uploadedCats = confirmed.length;
    }

    final unsyncedTxns = await _transactionLocal.getUnsynced();
    int uploadedTxns = 0;
    if (unsyncedTxns.isNotEmpty) {
      final confirmed = await _transactionRemote.uploadBatch(unsyncedTxns);
      await _transactionLocal.markSynced(confirmed);
      uploadedTxns = confirmed.length;
    }

    return SyncReport(
      categoriesDeleted: deletedCatCount,
      transactionsDeleted: deletedTxnCount,
      categoriesUploaded: uploadedCats,
      transactionsUploaded: uploadedTxns,
    );
  }

  @override
  Future<PendingCounts> getPendingCounts() async {
    final results = await Future.wait([
      _categoryLocal.getUnsynced(),
      _transactionLocal.getUnsynced(),
      _categoryLocal.getPendingDeletions(),
      _transactionLocal.getPendingDeletions(),
    ]);
    return PendingCounts(
      unsyncedCategories: results[0].length,
      unsyncedTransactions: results[1].length,
      deletedCategories: results[2].length,
      deletedTransactions: results[3].length,
    );
  }
}
