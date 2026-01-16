import 'package:exampro/core/config/env.dart';
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
    authEncryptionKey: dotenv.get('AUTH_ENCRYPTION_KEY'),
    authEncryptionIv: dotenv.get('AUTH_ENCRYPTION_IV'),
  );
});
