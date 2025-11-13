import 'package:citizentest/core/config/env_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeatureFlags {
  final bool leaderboard;
  const FeatureFlags({required this.leaderboard});
}

final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  final env = ref.watch(envLoaderProvider).maybeWhen(data: (e) => e, orElse: () => null);
  return FeatureFlags(leaderboard: env?.featureLeaderboard ?? false);
});

