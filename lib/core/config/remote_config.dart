import 'package:dio/dio.dart';
import 'package:exampro/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteConfig {
  final bool upgradeDisabled;
  const RemoteConfig({required this.upgradeDisabled});
}

final remoteConfigProvider = FutureProvider<RemoteConfig>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get('/config');
    final disabled = (res.data['upgrade_disabled'] as bool?) ?? false;
    return RemoteConfig(upgradeDisabled: disabled);
  } catch (_) {
    return const RemoteConfig(upgradeDisabled: false);
  }
});

