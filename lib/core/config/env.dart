class EnvConfig {
  final String apiBaseUrl;
  final String environment;
  final bool analyticsEnabled;
  final bool featureLeaderboard;
  final String jwtAudience;
  final String jwtIssuer;
<<<<<<< HEAD
  final String authEncryptionKey;
  final String authEncryptionIv;
=======
  final String databaseUrl;
  final String emailApiUrl;
  final String emailApiKey;
  final String stripePublishableKey;
  final String stripeSecretKey;
  final String stripeCheckoutUrlGbp;
  final String stripeCheckoutUrlUsd;
  final String adminEmails;
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45

  const EnvConfig({
    required this.apiBaseUrl,
    required this.environment,
    required this.analyticsEnabled,
    required this.featureLeaderboard,
    required this.jwtAudience,
    required this.jwtIssuer,
<<<<<<< HEAD
    required this.authEncryptionKey,
    required this.authEncryptionIv,
=======
    required this.databaseUrl,
    required this.emailApiUrl,
    required this.emailApiKey,
    required this.stripePublishableKey,
    required this.stripeSecretKey,
    required this.stripeCheckoutUrlGbp,
    required this.stripeCheckoutUrlUsd,
    this.adminEmails = '',
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  });
}
