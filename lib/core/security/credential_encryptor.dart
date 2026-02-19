import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:citizentest/core/config/env_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CredentialEncryptor {
  final encrypt.Encrypter _encrypter;
  final encrypt.IV _iv;

  CredentialEncryptor._(this._encrypter, this._iv);

  factory CredentialEncryptor.fromEnv(String key, String iv) {
    if (key.length != 32 || iv.length != 16) {
      throw ArgumentError('Auth encryption key must be 32 chars and IV must be 16 chars.');
    }
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromUtf8(key), mode: encrypt.AESMode.cbc),
    );
    return CredentialEncryptor._(encrypter, encrypt.IV.fromUtf8(iv));
  }

  String encryptToBase64(String value) => _encrypter.encrypt(value, iv: _iv).base64;
}

final credentialEncryptorProvider = Provider<CredentialEncryptor>((ref) {
  final env = ref.watch(envLoaderProvider).requireValue;
  return CredentialEncryptor.fromEnv(env.authEncryptionKey, env.authEncryptionIv);
});
