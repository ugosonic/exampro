import 'dart:convert';

import 'package:citizentest/core/auth/token_store.dart';
import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/core/notifications/push_notifications.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:citizentest/features/auth/domain/models.dart';
import 'package:citizentest/features/sync/data/sync_repository.dart';
import 'package:citizentest/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionInitializerProvider = FutureProvider<void>((ref) async {
  final tokens = ref.read(tokenStoreProvider);
  final has = await tokens.hasTokens();
  if (!has) return;
  User? sessionUser;
  try {
    sessionUser = await ref.read(authRepositoryProvider).me();
  } catch (_) {
    // Do not clear tokens automatically on transient/network errors.
    // Keep the session until the user explicitly signs out.
    sessionUser = await _restoreFromCachedTokens(ref, tokens);
  }

  if (sessionUser == null) return;
  ref.read(currentUserProvider.notifier).state = sessionUser;

  try {
    await ref.read(pushNotificationsProvider).syncTokenWithBackend();
  } catch (_) {
    // Keep session init non-blocking if notifications backend is unreachable.
  }

  // Auto-sync content and user progress so devices are consistent.
  try {
    await ref.read(syncRepositoryProvider).pushUserProgress(sessionUser.email);
    await ref.read(syncRepositoryProvider).pullUserProgress(sessionUser.email);
    await ref.read(syncRepositoryProvider).syncIfNeeded();
  } catch (_) {
    // Ignore transient sync errors; UI remains usable and will retry later.
  }
});

Future<User?> _restoreFromCachedTokens(Ref ref, TokenStore tokens) async {
  String? userId = await tokens.getUserId();
  String? email = await tokens.getEmail();
  String role = 'user';

  final access = await tokens.getAccessToken();
  if (access != null && access.isNotEmpty) {
    final parsed = _decodeJwtPayload(access);
    userId = (parsed['sub']?.toString().trim().isNotEmpty == true)
        ? parsed['sub'].toString().trim()
        : userId;
    email = (parsed['email']?.toString().trim().isNotEmpty == true)
        ? parsed['email'].toString().trim()
        : email;
    final parsedRole = parsed['role']?.toString().trim();
    if (parsedRole != null && parsedRole.isNotEmpty) {
      role = parsedRole;
    }
  }

  if ((email == null || email.isEmpty) && (userId == null || userId.isEmpty)) {
    return null;
  }

  try {
    final db = ref.read(dbProvider);
    if (email != null && email.isNotEmpty) {
      final row = await (db.select(
        db.users,
      )..where((u) => u.email.equals(email!))).getSingleOrNull();
      if (row != null) {
        return User(
          id: userId ?? row.id.toString(),
          email: row.email,
          role: row.role,
        );
      }
    }
  } catch (_) {
    // Fall back to token-derived session below.
  }

  return User(
    id: (userId == null || userId.isEmpty) ? 'session' : userId,
    email: (email == null || email.isEmpty) ? 'user@local' : email,
    role: role,
  );
}

Map<String, dynamic> _decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return const {};
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return const {};
  } catch (_) {
    return const {};
  }
}
