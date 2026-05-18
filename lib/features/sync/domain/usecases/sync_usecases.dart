import '../repositories/sync_repository.dart';

class RunSync {
  RunSync(this._repo);
  final SyncRepository _repo;
  Future<SyncReport> call() => _repo.runSync();
}

class LoadPendingCounts {
  LoadPendingCounts(this._repo);
  final SyncRepository _repo;
  Future<PendingCounts> call() => _repo.getPendingCounts();
}
