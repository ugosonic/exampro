import 'dart:async';
import 'package:dio/dio.dart';
import 'package:exampro/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Emits true when online, false when last probe failed
final onlineStatusProvider = StreamProvider<bool>((ref) async* {
  final dio = ref.watch(dioProvider);
  bool online = true;
  final controller = StreamController<bool>();
  Timer? timer;
  Future<void> probe() async {
    try {
      await dio.get('/sync/version', options: Options(receiveTimeout: const Duration(seconds: 6)));
      if (!online) { online = true; controller.add(true); }
    } catch (_) {
      if (online) { online = false; controller.add(false); }
    }
  }
  await probe();
  timer = Timer.periodic(const Duration(seconds: 8), (_) => probe());
  ref.onDispose(() { timer?.cancel(); controller.close(); });
  yield* controller.stream;
});

