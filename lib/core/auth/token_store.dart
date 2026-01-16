import 'dart:convert';

<<<<<<< HEAD
import 'package:exampro/core/storage/secure_storage.dart';
=======
import 'package:citizentest/core/storage/secure_storage.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenBundle {
  final String accessToken;
  final String refreshToken;
<<<<<<< HEAD
  const TokenBundle({required this.accessToken, required this.refreshToken});

  Map<String, dynamic> toJson() => {'access': accessToken, 'refresh': refreshToken};
  factory TokenBundle.fromJson(Map<String, dynamic> json) =>
      TokenBundle(accessToken: json['access'] as String, refreshToken: json['refresh'] as String);
=======
  final String? userId;
  final String? email;
  const TokenBundle({required this.accessToken, required this.refreshToken, this.userId, this.email});

  Map<String, dynamic> toJson() => {
        'access': accessToken,
        'refresh': refreshToken,
        if (userId != null) 'uid': userId,
        if (email != null) 'email': email,
      };
  factory TokenBundle.fromJson(Map<String, dynamic> json) => TokenBundle(
        accessToken: json['access'] as String,
        refreshToken: json['refresh'] as String,
        userId: json['uid'] as String?,
        email: json['email'] as String?,
      );
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
}

class TokenStore {
  final SecureStore _secureStore;
  static const _kTokens = 'tokens';
  TokenStore(this._secureStore);

  Future<void> save(TokenBundle tokens) async {
    await _secureStore.write(_kTokens, jsonEncode(tokens.toJson()));
  }

  Future<String?> getAccessToken() async {
    final raw = await _secureStore.read(_kTokens);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json['access'] as String?;
  }

  Future<String?> getRefreshToken() async {
    final raw = await _secureStore.read(_kTokens);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json['refresh'] as String?;
  }

  Future<bool> hasTokens() async => (await _secureStore.read(_kTokens)) != null;

<<<<<<< HEAD
=======
  Future<String?> getUserId() async {
    final raw = await _secureStore.read(_kTokens);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json['uid'] as String?;
  }

  Future<String?> getEmail() async {
    final raw = await _secureStore.read(_kTokens);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json['email'] as String?;
  }

>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  // Network refresh is implemented in the AuthInterceptor via AuthApi.

  Future<void> clear() async => _secureStore.delete(_kTokens);
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore(SecureStore()));
