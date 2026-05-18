import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<String>> uploadAdditions(List<CategoryModel> categories);
  Future<List<String>> deleteIds(List<String> ids);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  CategoryRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<String>> uploadAdditions(List<CategoryModel> categories) async {
    final synced = <String>[];
    for (final c in categories) {
      final response = await _client.post(
        ApiConstants.addCategory,
        c.toRemoteAddJson(),
      );
      if (response['status'] != 'success') {
        throw ServerException(
            response['message']?.toString() ?? 'Category sync failed');
      }
      final ids = (response['synced_ids'] as List?)?.cast<String>() ?? [c.id];
      synced.addAll(ids);
    }
    return synced;
  }

  @override
  Future<List<String>> deleteIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final response = await _client.delete(
      ApiConstants.deleteCategory,
      {'ids': ids},
    );
    if (response['status'] != 'success') {
      throw ServerException(
          response['message']?.toString() ?? 'Category delete failed');
    }
    return (response['deleted_ids'] as List?)?.cast<String>() ?? ids;
  }
}
