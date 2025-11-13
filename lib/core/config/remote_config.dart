import 'package:citizentest/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteConfig {
  final bool upgradeDisabled;
  final String? latestVersion; // e.g. "1.2.0"
  final String? minVersion; // e.g. "1.0.5" (force update if below)
  final bool forceUpdate; // hard override to force update
  final String? androidStoreUrl; // Play Store listing URL
  final String? iosStoreUrl; // App Store listing URL

  const RemoteConfig({
    required this.upgradeDisabled,
    this.latestVersion,
    this.minVersion,
    this.forceUpdate = false,
    this.androidStoreUrl,
    this.iosStoreUrl,
  });
}

final remoteConfigProvider = FutureProvider<RemoteConfig>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get('/config');
    final data = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : <String, dynamic>{};
    final disabled = (data['upgrade_disabled'] as bool?) ?? false;
    final latest = data['latest_version'] as String?;
    final min = data['min_version'] as String?;
    final force = (data['force_update'] as bool?) ?? false;
    final playUrl = data['android_store_url'] as String?;
    final iosUrl = data['ios_store_url'] as String?;
    return RemoteConfig(
      upgradeDisabled: disabled,
      latestVersion: latest,
      minVersion: min,
      forceUpdate: force,
      androidStoreUrl: playUrl,
      iosStoreUrl: iosUrl,
    );
  } catch (_) {
    return const RemoteConfig(upgradeDisabled: false);
  }
});
