import '../../../../core/error/exceptions.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Verifies the entered OTP against the challenge that was issued.
/// Returns a [AuthSession] only when the existing-user path applies.
/// For new users, callers must collect a nickname and call [CreateAccount].
class VerifyOtp {
  VerifyOtp(this._repository);
  final AuthRepository _repository;

  Future<AuthSession?> call({
    required OtpChallenge challenge,
    required String enteredOtp,
  }) async {
    if (challenge.otp != enteredOtp.trim()) {
      throw AuthException('Invalid OTP. Please try again.');
    }
    if (challenge.userExists) {
      final session = AuthSession(
        phone: challenge.phone,
        nickname: challenge.nickname ?? '',
        token: challenge.token ?? '',
      );
      await _repository.persistSession(session);
      return session;
    }
    return null;
  }
}
