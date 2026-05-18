import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<OtpChallenge> sendOtp(String phone);

  Future<AuthSession> createAccount({
    required String phone,
    required String nickname,
  });

  Future<void> persistSession(AuthSession session);

  Future<AuthSession?> currentSession();

  Future<void> signOut();
}
