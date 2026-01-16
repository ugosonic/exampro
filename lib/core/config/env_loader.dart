<<<<<<< HEAD
import 'package:exampro/core/config/env.dart';
=======
import 'package:citizentest/core/config/env.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final envLoaderProvider = FutureProvider<EnvConfig>((ref) async {
  await dotenv.load(fileName: 'assets/env/vc.env');
  return EnvConfig(
    apiBaseUrl: dotenv.get('API_BASE_URL'),
    environment: dotenv.get('ENVIRONMENT'),
    analyticsEnabled: dotenv.get('ANALYTICS_ENABLED').toLowerCase() == 'true',
    featureLeaderboard: dotenv.get('FEATURE_LEADERBOARD').toLowerCase() == 'true',
    jwtAudience: dotenv.get('JWT_AUDIENCE'),
    jwtIssuer: dotenv.get('JWT_ISSUER'),
<<<<<<< HEAD
    authEncryptionKey: dotenv.get('AUTH_ENCRYPTION_KEY'),
    authEncryptionIv: dotenv.get('AUTH_ENCRYPTION_IV'),
=======
    databaseUrl: dotenv.get('DATABASE_URL', fallback: ''),
    emailApiUrl: dotenv.get('EMAIL_API_URL', fallback: ''),
    emailApiKey: dotenv.get('EMAIL_API_KEY', fallback: ''),
    stripePublishableKey: dotenv.get('STRIPE_PUBLISHABLE_KEY', fallback: ''),
    stripeSecretKey: dotenv.get('STRIPE_SECRET_KEY', fallback: ''),
    stripeCheckoutUrlGbp: dotenv.get('STRIPE_CHECKOUT_URL_GBP', fallback: ''),
    stripeCheckoutUrlUsd: dotenv.get('STRIPE_CHECKOUT_URL_USD', fallback: ''),
    adminEmails: dotenv.get('ADMIN_EMAILS', fallback: ''),
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  );
});
