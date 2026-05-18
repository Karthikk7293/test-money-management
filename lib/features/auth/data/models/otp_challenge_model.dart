import '../../domain/entities/auth_session.dart';

class OtpChallengeModel extends OtpChallenge {
  const OtpChallengeModel({
    required super.phone,
    required super.otp,
    required super.userExists,
    super.nickname,
    super.token,
  });

  factory OtpChallengeModel.fromJson(Map<String, dynamic> json,
      {required String phone}) {
    return OtpChallengeModel(
      phone: phone,
      otp: json['otp']?.toString() ?? '',
      userExists: json['user_exists'] == true,
      nickname: json['nickname']?.toString(),
      token: json['token']?.toString(),
    );
  }
}
