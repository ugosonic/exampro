class EnvConfig {
  final String apiBaseUrl;
  final String environment;
  final bool analyticsEnabled;
  final bool featureLeaderboard;
  final String jwtAudience;
  final String jwtIssuer;
  final String authEncryptionKey;
  final String authEncryptionIv;

  const EnvConfig({
    required this.apiBaseUrl,
    required this.environment,
    required this.analyticsEnabled,
    required this.featureLeaderboard,
    required this.jwtAudience,
    required this.jwtIssuer,
    required this.authEncryptionKey,
    required this.authEncryptionIv,
  });
}
