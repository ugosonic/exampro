import 'dart:convert';

import 'package:exampro/core/storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenBundle {
  final String accessToken;
  final String refreshToken;
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

  // Network refresh is implemented in the AuthInterceptor via AuthApi.

  Future<void> clear() async => _secureStore.delete(_kTokens);
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore(SecureStore()));
