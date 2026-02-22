import 'dart:math';
import 'dart:convert';

import 'package:citizentest/core/auth/token_store.dart';
import 'package:citizentest/core/db/app_database.dart' as db;
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/features/auth/domain/models.dart' as auth_models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:citizentest/features/auth/data/auth_api.dart';
import 'package:citizentest/core/config/env_loader.dart';

class AuthRepository {
  final db.AppDatabase _db;
  final TokenStore _tokenStore;
  final AuthApi? _remote;
  AuthRepository(this._db, this._tokenStore, [this._remote]);

  Future<auth_models.User> signIn(String email, String password) async {
    if (_remote != null) {
      final tokens = await _remote.signIn(email: email, password: password);
      final user = await _remoteUser(tokens.access, fallbackEmail: email);
      await _tokenStore.save(
        TokenBundle(
          accessToken: tokens.access,
          refreshToken: tokens.refresh,
          userId: user.id,
          email: user.email,
        ),
      );
      await _upsertLocalUser(user, password: password);
      return user;
    }
    final existing = await (_db.select(
      _db.users,
    )..where((u) => u.email.equals(email))).getSingleOrNull();
    if (existing == null || existing.password != password) {
      throw Exception('Invalid credentials');
    }
    final uid = existing.id.toString();
    await _tokenStore.save(
      TokenBundle(
        accessToken: randToken('access', uid),
        refreshToken: randToken('refresh', uid),
        userId: uid,
        email: existing.email,
      ),
    );
    return auth_models.User(
      id: uid,
      email: existing.email,
      role: existing.role,
    );
  }

  Future<auth_models.User> register(String email, String password) async {
    if (_remote != null) {
      final tokens = await _remote.register(email: email, password: password);
      final user = await _remoteUser(tokens.access, fallbackEmail: email);
      await _tokenStore.save(
        TokenBundle(
          accessToken: tokens.access,
          refreshToken: tokens.refresh,
          userId: user.id,
          email: user.email,
        ),
      );
      await _upsertLocalUser(user, password: password);
      return user;
    }
    final count = await _db
        .customSelect('SELECT COUNT(*) AS c FROM users')
        .getSingle()
        .then((r) => r.data['c'] as int);
    final role = count == 0 ? 'admin' : 'user';
    final id = await _db
        .into(_db.users)
        .insert(
          db.UsersCompanion.insert(
            email: email,
            password: password,
            role: drift.Value(role),
          ),
        );
    final uid = id.toString();
    await _tokenStore.save(
      TokenBundle(
        accessToken: randToken('access', uid),
        refreshToken: randToken('refresh', uid),
        userId: uid,
        email: email,
      ),
    );
    return auth_models.User(id: uid, email: email, role: role);
  }

  Future<auth_models.User> me() async {
    if (_remote != null) {
      final user = await _remote.me();
      final access = await _tokenStore.getAccessToken();
      final refresh = await _tokenStore.getRefreshToken();
      if (access != null && refresh != null) {
        await _tokenStore.save(
          TokenBundle(
            accessToken: access,
            refreshToken: refresh,
            userId: user.id,
            email: user.email,
          ),
        );
      }
      await _upsertLocalUser(user);
      return user;
    }
    final uid = await _tokenStore.getUserId();
    if (uid == null) throw Exception('No session');
    final row = await (_db.select(
      _db.users,
    )..where((u) => u.id.equals(int.parse(uid)))).getSingle();
    return auth_models.User(id: uid, email: row.email, role: row.role);
  }

  Future<void> forgotPassword(String email) async {
    if (_remote == null) {
      throw Exception('Forgot password requires network');
    }
    await _remote.requestPasswordReset(email: email);
  }

  Future<void> requestDeleteCode(String email) async {
    if (_remote != null) {
      throw Exception('Delete account requires server support');
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String code,
  }) async {
    if (_remote != null) {
      throw Exception('Delete account requires server support');
    }
    await (_db.delete(_db.users)..where((u) => u.email.equals(email))).go();
    await _tokenStore.clear();
  }

  String randToken(String pfx, String uid) {
    final rng = Random();
    final n = List.generate(
      16,
      (_) => rng.nextInt(16).toRadixString(16),
    ).join();
    return 'local-$pfx-$uid-$n';
  }

  Future<auth_models.User> _remoteUser(
    String accessToken, {
    required String fallbackEmail,
  }) async {
    try {
      return await _remote!.me(accessToken: accessToken);
    } catch (_) {
      final user = _userFromJwt(accessToken, fallbackEmail: fallbackEmail);
      if (user != null) return user;
      rethrow;
    }
  }

  auth_models.User? _userFromJwt(
    String token, {
    required String fallbackEmail,
  }) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      final id = (payload['sub']?.toString() ?? '').trim();
      if (id.isEmpty) return null;
      final email = (payload['email']?.toString() ?? fallbackEmail).trim();
      final role = (payload['role']?.toString() ?? 'user').trim();
      return auth_models.User(id: id, email: email, role: role);
    } catch (_) {
      return null;
    }
  }

  Future<void> _upsertLocalUser(
    auth_models.User user, {
    String? password,
  }) async {
    final existing = await (_db.select(
      _db.users,
    )..where((u) => u.email.equals(user.email))).getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.users)
          .insert(
            db.UsersCompanion.insert(
              email: user.email,
              password: password ?? '',
              role: drift.Value(user.role),
            ),
            mode: drift.InsertMode.insertOrIgnore,
          );
      return;
    }
    await (_db.update(
      _db.users,
    )..where((u) => u.email.equals(user.email))).write(
      db.UsersCompanion(
        role: drift.Value(user.role),
        password: password != null
            ? drift.Value(password)
            : const drift.Value.absent(),
      ),
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dbi = ref.watch(dbProvider);
  final store = ref.watch(tokenStoreProvider);
  final env = ref
      .watch(envLoaderProvider)
      .maybeWhen(data: (e) => e, orElse: () => null);
  final hasApi = env != null && (env.apiBaseUrl.isNotEmpty);
  final remote = hasApi ? ref.watch(authApiProvider) : null;
  return AuthRepository(dbi, store, remote);
});
