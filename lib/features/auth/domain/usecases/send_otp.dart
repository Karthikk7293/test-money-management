import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class SendOtp {
  SendOtp(this._repository);
  final AuthRepository _repository;

  Future<OtpChallenge> call(String phone) => _repository.sendOtp(phone);
}
