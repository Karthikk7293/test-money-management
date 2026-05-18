import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<String>> uploadBatch(List<TransactionModel> transactions);
  Future<List<String>> deleteIds(List<String> ids);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  TransactionRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<String>> uploadBatch(List<TransactionModel> transactions) async {
    if (transactions.isEmpty) return const [];
    final response = await _client.post(
      ApiConstants.addTransaction,
      {'transactions': transactions.map((t) => t.toRemoteJson()).toList()},
    );
    if (response['status'] != 'success') {
      throw ServerException(
          response['message']?.toString() ?? 'Transaction sync failed');
    }
    return (response['synced_ids'] as List?)?.cast<String>() ??
        transactions.map((t) => t.id).toList();
  }

  @override
  Future<List<String>> deleteIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final response = await _client.delete(
      ApiConstants.deleteTransaction,
      {'ids': ids},
    );
    if (response['status'] != 'success') {
      throw ServerException(
          response['message']?.toString() ?? 'Transaction delete failed');
    }
    return (response['deleted_ids'] as List?)?.cast<String>() ?? ids;
  }
}
