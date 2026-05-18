import '../../../../core/services/notification_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class LoadTransactions {
  LoadTransactions(this._repo);
  final TransactionRepository _repo;
  Future<List<TransactionEntity>> call() => _repo.getAll();
}

class LoadRecentTransactions {
  LoadRecentTransactions(this._repo);
  final TransactionRepository _repo;
  Future<List<TransactionEntity>> call({int limit = 10}) =>
      _repo.getRecent(limit: limit);
}

class LoadDashboardSummary {
  LoadDashboardSummary(this._repo);
  final TransactionRepository _repo;
  Future<DashboardSummary> call() => _repo.getSummary();
}

class AddTransaction {
  AddTransaction(this._repo, this._notifications, this._prefs);
  final TransactionRepository _repo;
  final NotificationService _notifications;
  final PreferencesService _prefs;

  Future<TransactionEntity> call({
    required double amount,
    required String note,
    required TransactionType type,
    required String categoryId,
    DateTime? timestamp,
  }) async {
    final beforeMonthTotal = type == TransactionType.debit
        ? await _repo.getCurrentMonthDebitTotal()
        : 0.0;

    final created = await _repo.create(
      amount: amount,
      note: note,
      type: type,
      categoryId: categoryId,
      timestamp: timestamp,
    );

    if (type == TransactionType.debit) {
      final limit = _prefs.budgetLimit;
      final after = beforeMonthTotal + amount;
      if (beforeMonthTotal <= limit && after > limit) {
        await _notifications.showBudgetAlert(
          currentTotal: after,
          limit: limit,
        );
      }
    }
    return created;
  }
}

class DeleteTransaction {
  DeleteTransaction(this._repo);
  final TransactionRepository _repo;
  Future<void> call(String id) => _repo.softDelete(id);
}
