import 'dart:math';

import 'package:exampro/core/auth/token_store.dart';
import 'package:exampro/core/db/app_database.dart' as db;
import 'package:exampro/core/db/db_provider.dart';
import 'package:exampro/features/auth/domain/models.dart' as auth_models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:exampro/features/auth/data/auth_api.dart';
import 'package:exampro/core/config/env_loader.dart';

class AuthRepository {
  final db.AppDatabase _db;
  final TokenStore _tokenStore;
  final AuthApi? _remote;
  final String _adminEmailsCsv;
  AuthRepository(this._db, this._tokenStore, [this._remote, this._adminEmailsCsv = '']);

  Future<auth_models.User> signIn(String email, String password) async {
    if (_remote != null) {
      final tokens = await _remote!.signIn(email: email, password: password);
      final me = await _remote!.me();
      await _tokenStore.save(TokenBundle(accessToken: tokens.access, refreshToken: tokens.refresh, userId: me.id, email: me.email));
      // Respect local admin override for same email
      final local = await (_db.select(_db.users)..where((u) => u.email.equals(me.email))).getSingleOrNull();
      final envAdmins = _adminEmailsCsv.split(',').map((e) => e.trim().toLowerCase()).toSet();
      final role = (local?.role == 'admin' || envAdmins.contains(me.email.toLowerCase())) ? 'admin' : me.role;
      // Persist/update local user row for role/pro checks used by UI
      try {
        await _db.into(_db.users).insertOnConflictUpdate(
              db.UsersCompanion.insert(
                email: me.email,
                password: '',
                role: drift.Value(role),
              ),
            );
      } catch (_) {}
      return auth_models.User(id: me.id, email: me.email, role: role);
    }
    final existing = await (_db.select(_db.users)..where((u) => u.email.equals(email))).getSingleOrNull();
    if (existing == null || existing.password != password) {
      throw Exception('Invalid credentials');
    }
    final uid = existing.id.toString();
    await _tokenStore.save(TokenBundle(
      accessToken: _randToken('access', uid),
      refreshToken: _randToken('refresh', uid),
      userId: uid,
    ));
    return auth_models.User(id: uid, email: existing.email, role: existing.role);
  }

  Future<auth_models.User> register(String email, String password) async {
    if (_remote != null) {
      final tokens = await _remote!.register(email: email, password: password);
      final me = await _remote!.me();
      await _tokenStore.save(TokenBundle(accessToken: tokens.access, refreshToken: tokens.refresh, userId: me.id, email: me.email));
      // Persist local row so role/is_pro checks work
      final envAdmins = _adminEmailsCsv.split(',').map((e) => e.trim().toLowerCase()).toSet();
      final role = envAdmins.contains(me.email.toLowerCase()) ? 'admin' : me.role;
      try {
        await _db.into(_db.users).insertOnConflictUpdate(
              db.UsersCompanion.insert(
                email: me.email,
                password: '',
                role: drift.Value(role),
              ),
            );
      } catch (_) {}
      return auth_models.User(id: me.id, email: me.email, role: role);
    }
    final count = await _db.customSelect('SELECT COUNT(*) AS c FROM users').getSingle().then((r) => r.data['c'] as int);
    final role = count == 0 ? 'admin' : 'user';
    final id = await _db
        .into(_db.users)
        .insert(db.UsersCompanion.insert(email: email, password: password, role: drift.Value(role)));
    final uid = id.toString();
    await _tokenStore.save(TokenBundle(
      accessToken: _randToken('access', uid),
      refreshToken: _randToken('refresh', uid),
      userId: uid,
    ));
    return auth_models.User(id: uid, email: email, role: role);
  }

  Future<auth_models.User> me() async {
    if (_remote != null) {
      try {
        final me = await _remote!.me();
        final local = await (_db.select(_db.users)..where((u) => u.email.equals(me.email))).getSingleOrNull();
        final envAdmins = _adminEmailsCsv.split(',').map((e) => e.trim().toLowerCase()).toSet();
        final role = (local?.role == 'admin' || envAdmins.contains(me.email.toLowerCase())) ? 'admin' : me.role;
        // Upsert local row for downstream checks
        try {
          await _db.into(_db.users).insertOnConflictUpdate(
                db.UsersCompanion.insert(
                  email: me.email,
                  password: '',
                  role: drift.Value(role),
                ),
              );
        } catch (_) {}
        return auth_models.User(id: me.id, email: me.email, role: role);
      } catch (_) {
        // Dev-only fallback: if using mock API, reconstruct user from stored tokens
        if (_remote is AuthApiMock) {
          final email = await _tokenStore.getEmail();
          if (email != null && email.isNotEmpty) {
            final local = await (_db.select(_db.users)..where((u) => u.email.equals(email))).getSingleOrNull();
            final envAdmins = _adminEmailsCsv.split(',').map((e) => e.trim().toLowerCase()).toSet();
            final role = (local?.role == 'admin' || envAdmins.contains(email.toLowerCase())) ? 'admin' : (local?.role ?? 'user');
            final uid = await _tokenStore.getUserId() ?? (local?.id.toString() ?? 'u_local');
            return auth_models.User(id: uid, email: email, role: role);
          }
        }
        rethrow;
      }
    }
    final uid = await _tokenStore.getUserId();
    if (uid == null) throw Exception('No session');
    final row = await (_db.select(_db.users)..where((u) => u.id.equals(int.parse(uid)))).getSingle();
    return auth_models.User(id: uid, email: row.email, role: row.role);
  }

  Future<void> forgotPassword(String email) async {
    if (_remote == null) throw Exception('Forgot password requires network');
    await _remote!.requestPasswordReset(email: email);
  }

  String _randToken(String pfx, String uid) {
    final rng = Random();
    final n = List.generate(16, (_) => rng.nextInt(16).toRadixString(16)).join();
    return 'local-$pfx-$uid-$n';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dbi = ref.watch(dbProvider);
  final store = ref.watch(tokenStoreProvider);
  final env = ref.watch(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
  final hasApi = env != null && (env.apiBaseUrl.isNotEmpty);
  final remote = hasApi ? ref.watch(authApiProvider) : null;
  final admins = env?.adminEmails ?? '';
  return AuthRepository(dbi, store, remote, admins);
});

