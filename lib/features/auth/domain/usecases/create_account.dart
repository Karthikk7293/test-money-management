import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class CreateAccount {
  CreateAccount(this._repository);
  final AuthRepository _repository;

  Future<AuthSession> call({
    required String phone,
    required String nickname,
  }) async {
    final session = await _repository.createAccount(
      phone: phone,
      nickname: nickname,
    );
    await _repository.persistSession(session);
    return session;
  }
}
