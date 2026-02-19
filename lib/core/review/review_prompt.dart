import 'dart:math';

import 'package:citizentest/core/db/db_provider.dart';
import 'package:citizentest/core/notifications/notification_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewPrompt {
  static const _minDaysBetween = 30;

  static Future<void> maybeShow(BuildContext context, WidgetRef ref) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    if (!context.mounted) return;
    final db = ref.read(dbProvider);
    final last = await NotificationSettings.getReviewPromptLast(db);
    if (last != null && DateTime.now().difference(last).inDays < _minDaysBetween) {
      return;
    }
    // Keep it occasional instead of guaranteed.
    if (Random().nextInt(100) > 45) {
      await NotificationSettings.setReviewPromptLast(db, DateTime.now());
      return;
    }
    await NotificationSettings.setReviewPromptLast(db, DateTime.now());
    if (!context.mounted) return;
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    final uri = Uri.parse('https://play.google.com/store/apps/details?id=${info.packageName}');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enjoying Citizen Test?'),
        content: const Text('Please take a moment to leave a review on the Play Store. It helps a lot!'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Not now')),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Rate app'),
          ),
        ],
      ),
    );
  }
}
