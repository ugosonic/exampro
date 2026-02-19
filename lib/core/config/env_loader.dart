import 'package:citizentest/core/config/env.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb, kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final envLoaderProvider = FutureProvider<EnvConfig>((ref) async {
  await dotenv.load(fileName: 'assets/env/vc.env');
  const apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
  const apiBaseUrlLegacyOverride = String.fromEnvironment('API_BASE');
  const environmentOverride = String.fromEnvironment('ENVIRONMENT');
  final rawApiBaseUrl = apiBaseUrlOverride.isNotEmpty
      ? apiBaseUrlOverride
      : (apiBaseUrlLegacyOverride.isNotEmpty
            ? apiBaseUrlLegacyOverride
            : dotenv.get(
                'API_BASE_URL',
                fallback: dotenv.get('API_BASE', fallback: ''),
              ));
  final resolvedApiBaseUrl = _resolveApiBaseUrl(rawApiBaseUrl);
  return EnvConfig(
    apiBaseUrl: resolvedApiBaseUrl,
    environment: environmentOverride.isNotEmpty
        ? environmentOverride
        : dotenv.get('ENVIRONMENT', fallback: 'development'),
    analyticsEnabled: dotenv.get('ANALYTICS_ENABLED').toLowerCase() == 'true',
    featureLeaderboard:
        dotenv.get('FEATURE_LEADERBOARD').toLowerCase() == 'true',
    jwtAudience: dotenv.get('JWT_AUDIENCE'),
    jwtIssuer: dotenv.get('JWT_ISSUER'),
    authEncryptionKey: dotenv.get('AUTH_ENCRYPTION_KEY'),
    authEncryptionIv: dotenv.get('AUTH_ENCRYPTION_IV'),
    databaseUrl: dotenv.get('DATABASE_URL', fallback: ''),
    emailApiUrl: dotenv.get('EMAIL_API_URL', fallback: ''),
    emailApiKey: dotenv.get('EMAIL_API_KEY', fallback: ''),
    stripePublishableKey: dotenv.get('STRIPE_PUBLISHABLE_KEY', fallback: ''),
    stripeSecretKey: dotenv.get('STRIPE_SECRET_KEY', fallback: ''),
    stripeCheckoutUrlGbp: dotenv.get('STRIPE_CHECKOUT_URL_GBP', fallback: ''),
    stripeCheckoutUrlUsd: dotenv.get('STRIPE_CHECKOUT_URL_USD', fallback: ''),
    adminEmails: dotenv.get('ADMIN_EMAILS', fallback: ''),
  );
});

String _resolveApiBaseUrl(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    // On deployed web, default to same-origin API (Nginx reverse proxy setup).
    if (kIsWeb) return _withoutTrailingSlash(Uri.base.origin);
    return '';
  }
  final parsed = Uri.tryParse(value);
  if (parsed == null || parsed.scheme.isEmpty || parsed.host.isEmpty) {
    return value;
  }

  final host = parsed.host.toLowerCase();
  final isLoopback =
      host == 'localhost' ||
      host == '127.0.0.1' ||
      host == '::1' ||
      host == '10.0.2.2';

  // Prevent store/release builds from shipping emulator-only localhost URLs.
  if (kReleaseMode && isLoopback) return '';

  if (kIsWeb && host == '10.0.2.2') {
    return _withoutTrailingSlash(parsed.replace(host: 'localhost').toString());
  }

  final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  if (isAndroid &&
      (host == 'localhost' || host == '127.0.0.1' || host == '::1')) {
    return _withoutTrailingSlash(parsed.replace(host: '10.0.2.2').toString());
  }

  if (!isAndroid && host == '10.0.2.2') {
    return _withoutTrailingSlash(parsed.replace(host: 'localhost').toString());
  }

  return _withoutTrailingSlash(parsed.toString());
}

String _withoutTrailingSlash(String url) {
  if (url.endsWith('/')) return url.substring(0, url.length - 1);
  return url;
}
