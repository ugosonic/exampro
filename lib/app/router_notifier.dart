import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppRouterNotifier extends ChangeNotifier {
  AppRouterNotifier(this.ref) {
    ref.listen(currentUserProvider, (prev, next) => notifyListeners());
  }
  final Ref ref;
}

final routerNotifierProvider = Provider<AppRouterNotifier>((ref) => AppRouterNotifier(ref));
