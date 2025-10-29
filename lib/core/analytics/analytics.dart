import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class Analytics {
  void captureScreenChange(String screen);
  void event(String name, {Map<String, Object?> params = const {}});
}

class ConsoleAnalytics implements Analytics {
  @override
  void captureScreenChange(String screen) {
    debugPrint('[analytics] screen: $screen');
  }

  @override
  void event(String name, {Map<String, Object?> params = const {}}) {
    debugPrint('[analytics] event: $name $params');
  }
}

final analyticsProvider = Provider<Analytics>((ref) => ConsoleAnalytics());

