import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.phone,
    required this.nickname,
    required this.token,
  });

  final String phone;
  final String nickname;
  final String token;

  @override
  List<Object?> get props => [phone, nickname, token];
}

class OtpChallenge extends Equatable {
  const OtpChallenge({
    required this.phone,
    required this.otp,
    required this.userExists,
    this.nickname,
    this.token,
  });

  final String phone;
  final String otp;
  final bool userExists;
  final String? nickname;
  final String? token;

  @override
  List<Object?> get props => [phone, otp, userExists, nickname, token];
}
