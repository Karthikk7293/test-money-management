import '../../../../core/services/preferences_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required PreferencesService prefs,
  })  : _remote = remote,
        _prefs = prefs;

  final AuthRemoteDataSource _remote;
  final PreferencesService _prefs;

  @override
  Future<OtpChallenge> sendOtp(String phone) async {
    await _prefs.setPhone(phone);
    return _remote.sendOtp(phone);
  }

  @override
  Future<AuthSession> createAccount({
    required String phone,
    required String nickname,
  }) async {
    final token = await _remote.createAccount(phone: phone, nickname: nickname);
    return AuthSession(phone: phone, nickname: nickname, token: token);
  }

  @override
  Future<void> persistSession(AuthSession session) async {
    await _prefs.setToken(session.token);
    await _prefs.setNickname(session.nickname);
    await _prefs.setPhone(session.phone);
  }

  @override
  Future<AuthSession?> currentSession() async {
    final token = _prefs.token;
    final nickname = _prefs.nickname;
    final phone = _prefs.phone;
    if (token == null || token.isEmpty) return null;
    return AuthSession(
      phone: phone ?? '',
      nickname: nickname ?? '',
      token: token,
    );
  }

  @override
  Future<void> signOut() => _prefs.clearSession();
}
