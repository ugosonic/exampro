import 'dart:async';

import 'package:citizentest/core/config/env_loader.dart';
import 'package:dio/dio.dart';
import 'package:citizentest/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Emits true when online, false when last probe failed
final onlineStatusProvider = StreamProvider<bool>((ref) async* {
  final env = ref.watch(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
  if (env == null || env.apiBaseUrl.isEmpty) {
    // No remote API configured; avoid probing and keep app usable offline/local.
    yield true;
    return;
  }

  final dio = ref.watch(dioProvider);
  bool online = true;
  bool? lastEmitted;
  final controller = StreamController<bool>();
  Timer? timer;
  void emit(bool value) {
    if (lastEmitted == value) return;
    lastEmitted = value;
    controller.add(value);
  }
  Future<void> probe() async {
    try {
      await dio.get(
        '/sync/version',
        options: Options(receiveTimeout: const Duration(seconds: 6)),
      );
      if (!online) {
        online = true;
      }
      emit(true);
      return;
    } on DioException catch (err) {
      final isNetworkFailure = switch (err.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError ||
        DioExceptionType.badCertificate => true,
        DioExceptionType.badResponse ||
        DioExceptionType.cancel => false,
        // On web, dart:io is unavailable; treat unknown as network-related.
        DioExceptionType.unknown => true,
      };
      if (!isNetworkFailure) {
        if (!online) {
          online = true;
        }
        emit(true);
        return;
      }
    } catch (_) {
      // Fall through to offline update below.
    }
    if (online) {
      online = false;
    }
    emit(false);
  }
  await probe();
  timer = Timer.periodic(const Duration(seconds: 8), (_) => probe());
  ref.onDispose(() { timer?.cancel(); controller.close(); });
  yield* controller.stream;
});
