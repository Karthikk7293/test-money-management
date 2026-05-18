import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/otp_challenge_model.dart';

abstract class AuthRemoteDataSource {
  Future<OtpChallengeModel> sendOtp(String phone);
  Future<String> createAccount({required String phone, required String nickname});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<OtpChallengeModel> sendOtp(String phone) async {
    final response = await _client.post(
      ApiConstants.sendOtp,
      {'phone': phone},
      auth: false,
    );
    if (response['status'] != 'success') {
      throw ServerException(response['message']?.toString() ?? 'OTP failed');
    }
    return OtpChallengeModel.fromJson(response, phone: phone);
  }

  @override
  Future<String> createAccount({
    required String phone,
    required String nickname,
  }) async {
    final response = await _client.post(
      ApiConstants.createAccount,
      {'phone': phone, 'nickname': nickname},
      auth: false,
    );
    if (response['status'] != 'success' || response['token'] == null) {
      throw ServerException(
          response['message']?.toString() ?? 'Could not create account');
    }
    return response['token'].toString();
  }
}
