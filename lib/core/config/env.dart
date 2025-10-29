class EnvConfig {
  final String apiBaseUrl;
  final String environment;
  final bool analyticsEnabled;
  final bool featureLeaderboard;
  final String jwtAudience;
  final String jwtIssuer;
  final String databaseUrl;
  final String emailApiUrl;
  final String emailApiKey;
  final String stripePublishableKey;
  final String stripeSecretKey;
  final String stripeCheckoutUrlGbp;
  final String stripeCheckoutUrlUsd;
  final String adminEmails;

  const EnvConfig({
    required this.apiBaseUrl,
    required this.environment,
    required this.analyticsEnabled,
    required this.featureLeaderboard,
    required this.jwtAudience,
    required this.jwtIssuer,
    required this.databaseUrl,
    required this.emailApiUrl,
    required this.emailApiKey,
    required this.stripePublishableKey,
    required this.stripeSecretKey,
    required this.stripeCheckoutUrlGbp,
    required this.stripeCheckoutUrlUsd,
    this.adminEmails = '',
  });
}
