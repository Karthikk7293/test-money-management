class SyncReport {
  const SyncReport({
    required this.categoriesDeleted,
    required this.transactionsDeleted,
    required this.categoriesUploaded,
    required this.transactionsUploaded,
  });

  final int categoriesDeleted;
  final int transactionsDeleted;
  final int categoriesUploaded;
  final int transactionsUploaded;

  int get total =>
      categoriesDeleted +
      transactionsDeleted +
      categoriesUploaded +
      transactionsUploaded;
}

class PendingCounts {
  const PendingCounts({
    required this.unsyncedCategories,
    required this.unsyncedTransactions,
    required this.deletedCategories,
    required this.deletedTransactions,
  });

  final int unsyncedCategories;
  final int unsyncedTransactions;
  final int deletedCategories;
  final int deletedTransactions;

  bool get hasAny =>
      unsyncedCategories > 0 ||
      unsyncedTransactions > 0 ||
      deletedCategories > 0 ||
      deletedTransactions > 0;

  int get total =>
      unsyncedCategories +
      unsyncedTransactions +
      deletedCategories +
      deletedTransactions;
}

abstract class SyncRepository {
  /// Runs the full sync workflow:
  ///   A) Cloud purge (txns then categories) → local DELETE.
  ///   B) Upload categories first, then transactions.
  Future<SyncReport> runSync();

  Future<PendingCounts> getPendingCounts();
}
