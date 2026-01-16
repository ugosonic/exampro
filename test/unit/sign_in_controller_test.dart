<<<<<<< HEAD
import 'package:exampro/features/auth/data/auth_repository.dart';
import 'package:exampro/features/auth/domain/models.dart';
import 'package:exampro/features/auth/presentation/sign_in_state.dart';
=======
import 'package:citizentest/features/auth/data/auth_repository.dart';
import 'package:citizentest/features/auth/domain/models.dart';
import 'package:citizentest/features/auth/presentation/sign_in_state.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  test('sign in success updates state', () async {
    final repo = _MockRepo();
    when(() => repo.signIn(any(), any())).thenAnswer((_) async => const User(id: '1', email: 'a@b.com', role: 'user'));

    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    final ctrl = container.read(signInControllerProvider.notifier);
    ctrl.onEmailChanged('a@b.com');
    ctrl.onPasswordChanged('x');
    final ok = await ctrl.submit();
    expect(ok, true);
    expect(container.read(signInControllerProvider).loading, false);
    expect(container.read(signInControllerProvider).errorMessage, null);
  });
}
