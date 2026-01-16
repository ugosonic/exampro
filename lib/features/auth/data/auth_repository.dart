import 'package:exampro/core/auth/token_store.dart';
import 'package:exampro/core/security/credential_encryptor.dart';
import 'package:exampro/features/auth/data/auth_api.dart';
import 'package:exampro/features/auth/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  final AuthApi _api;
  final TokenStore _tokenStore;
  final CredentialEncryptor _encryptor;
  AuthRepository(this._api, this._tokenStore, this._encryptor);

  Future<User> signIn(String email, String password) async {
    final tokens = await _api.signIn(email: email, password: password);
    await _tokenStore.save(TokenBundle(accessToken: tokens.access, refreshToken: tokens.refresh));
    return _api.me();
  }

  Future<User> signUp(String email, String password) async {
    final encryptedEmail = _encryptor.encryptToBase64(email.trim());
    final encryptedPassword = _encryptor.encryptToBase64(password);
    final tokens = await _api.signUp(email: encryptedEmail, password: encryptedPassword);
    await _tokenStore.save(TokenBundle(accessToken: tokens.access, refreshToken: tokens.refresh));
    return _api.me();
  }

  Future<User> me() => _api.me();

  Future<void> requestDeleteCode(String email) => _api.requestDeleteCode(email: email.trim());

  Future<void> deleteAccount({required String email, required String code}) async {
    await _api.deleteAccount(email: email.trim(), code: code.trim());
    await _tokenStore.clear();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(authApiProvider);
  final store = ref.watch(tokenStoreProvider);
  final encryptor = ref.watch(credentialEncryptorProvider);
  return AuthRepository(api, store, encryptor);
});
