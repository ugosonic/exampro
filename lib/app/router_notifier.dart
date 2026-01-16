<<<<<<< HEAD
import 'package:exampro/features/auth/application/auth_session.dart';
=======
import 'package:citizentest/features/auth/application/auth_session.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppRouterNotifier extends ChangeNotifier {
  AppRouterNotifier(this.ref) {
<<<<<<< HEAD
    ref.listen(currentUserProvider, (_, __) => notifyListeners());
=======
    ref.listen(currentUserProvider, (prev, next) => notifyListeners());
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  }
  final Ref ref;
}

final routerNotifierProvider = Provider<AppRouterNotifier>((ref) => AppRouterNotifier(ref));
