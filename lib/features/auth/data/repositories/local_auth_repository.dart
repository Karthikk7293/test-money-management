import 'dart:math';

import '../../../../core/services/preferences_service.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

/// Fully local auth implementation. Used while the remote OTP service is
/// unreliable — generates a random 6-digit OTP per `sendOtp`, recognises
/// returning phones via the known-users map in [PreferencesService], and
/// issues a locally-minted token on `createAccount`.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._prefs);

  final PreferencesService _prefs;
  final Random _rng = Random.secure();

  String _generateOtp() {
    final code = _rng.nextInt(900000) + 100000; // 100000..999999
    return code.toString();
  }

  String _generateToken() => 'local.${UuidGenerator.v4()}';

  @override
  Future<OtpChallenge> sendOtp(String phone) async {
    await _prefs.setPhone(phone);
    final otp = _generateOtp();
    final exists = _prefs.knowsUser(phone);
    if (exists) {
      return OtpChallenge(
        phone: phone,
        otp: otp,
        userExists: true,
        nickname: _prefs.knownNickname(phone),
        token: _generateToken(),
      );
    }
    return OtpChallenge(
      phone: phone,
      otp: otp,
      userExists: false,
    );
  }

  @override
  Future<AuthSession> createAccount({
    required String phone,
    required String nickname,
  }) async {
    final token = _generateToken();
    await _prefs.upsertKnownUser(phone, nickname);
    return AuthSession(phone: phone, nickname: nickname, token: token);
  }

  @override
  Future<void> persistSession(AuthSession session) async {
    await _prefs.setToken(session.token);
    await _prefs.setNickname(session.nickname);
    await _prefs.setPhone(session.phone);
    if (session.nickname.isNotEmpty) {
      await _prefs.upsertKnownUser(session.phone, session.nickname);
    }
  }

  @override
  Future<AuthSession?> currentSession() async {
    final token = _prefs.token;
    if (token == null || token.isEmpty) return null;
    return AuthSession(
      phone: _prefs.phone ?? '',
      nickname: _prefs.nickname ?? '',
      token: token,
    );
  }

  @override
  Future<void> signOut() => _prefs.clearSession();
}
