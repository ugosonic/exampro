import 'dart:convert';

import 'package:citizentest/core/storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenBundle {
  final String accessToken;
  final String refreshToken;
  final String? userId;
  final String? email;
  const TokenBundle({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
    this.email,
  });

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
  String? _memoryTokens;
  TokenStore(this._secureStore);

  Future<void> save(TokenBundle tokens) async {
    final raw = jsonEncode(tokens.toJson());
    _memoryTokens = raw;
    try {
      await _secureStore.write(_kTokens, raw);
    } catch (_) {
      // Keep in-memory tokens for the current session when secure storage fails.
    }
  }

  Future<String?> getAccessToken() async {
    final raw = await _readRaw();
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json['access'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    final raw = await _readRaw();
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json['refresh'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasTokens() async => (await _readRaw()) != null;

  Future<String?> getUserId() async {
    final raw = await _readRaw();
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json['uid'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getEmail() async {
    final raw = await _readRaw();
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  // Network refresh is implemented in the AuthInterceptor via AuthApi.

  Future<void> clear() async {
    _memoryTokens = null;
    try {
      await _secureStore.delete(_kTokens);
    } catch (_) {}
  }

  Future<String?> _readRaw() async {
    if (_memoryTokens != null) return _memoryTokens;
    try {
      final raw = await _secureStore.read(_kTokens);
      _memoryTokens = raw;
      return raw;
    } catch (_) {
      // Attempt cleanup of potentially corrupted browser storage entry.
      try {
        await _secureStore.delete(_kTokens);
      } catch (_) {}
      return _memoryTokens;
    }
  }
}

final tokenStoreProvider = Provider<TokenStore>(
  (ref) => TokenStore(SecureStore()),
);
