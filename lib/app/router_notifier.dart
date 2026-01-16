import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppRouterNotifier extends ChangeNotifier {
  AppRouterNotifier(this.ref) {
    ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}

final routerNotifierProvider = Provider<AppRouterNotifier>((ref) => AppRouterNotifier(ref));
