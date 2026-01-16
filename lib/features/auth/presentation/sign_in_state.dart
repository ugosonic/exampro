<<<<<<< HEAD
import 'package:exampro/core/utils/validators.dart';
import 'package:exampro/features/auth/data/auth_repository.dart';
import 'package:exampro/features/auth/domain/models.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
=======
import 'package:citizentest/core/utils/validators.dart';
import 'package:citizentest/features/auth/data/auth_repository.dart';
import 'package:citizentest/features/auth/domain/models.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45

class SignInState {
  final String email;
  final String password;
  final bool loading;
  final String? emailError;
  final String? passwordError;
  final String? errorMessage;
  const SignInState({
    this.email = '',
    this.password = '',
    this.loading = false,
<<<<<<< HEAD
    this.emailError = null,
    this.passwordError = null,
    this.errorMessage = null,
=======
    this.emailError,
    this.passwordError,
    this.errorMessage,
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  });

  bool get canSubmit => email.isNotEmpty && password.isNotEmpty && emailError == null && passwordError == null;

  SignInState copyWith({
    String? email,
    String? password,
    bool? loading,
    String? emailError,
    String? passwordError,
    String? errorMessage,
  }) =>
      SignInState(
        email: email ?? this.email,
        password: password ?? this.password,
        loading: loading ?? this.loading,
        emailError: emailError,
        passwordError: passwordError,
        errorMessage: errorMessage,
      );
}

class SignInController extends StateNotifier<SignInState> {
  final AuthRepository _repo;
  final StateController<User?> currentUser;
  SignInController(this._repo, this.currentUser) : super(const SignInState());

  void onEmailChanged(String v) {
    state = state.copyWith(
      email: v,
      emailError: Validators.isEmail(v) ? null : 'Invalid email',
      passwordError: state.password.isEmpty ? 'Password is required' : null,
      errorMessage: null,
    );
  }

  void onPasswordChanged(String v) {
    state = state.copyWith(
      password: v,
      passwordError: v.isEmpty ? 'Password is required' : null,
      emailError: Validators.isEmail(state.email) ? null : 'Invalid email',
      errorMessage: null,
    );
  }

  Future<bool> submit() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final user = await _repo.signIn(state.email, state.password);
      currentUser.state = user;
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
<<<<<<< HEAD
      state = state.copyWith(loading: false, errorMessage: 'Failed to sign in');
=======
      var message = 'Failed to sign in';
      if (e is DioException) {
        final code = e.response?.statusCode ?? 0;
        if (code == 401) {
          message = 'Invalid email or password';
        } else {
          message = 'Cannot reach server. Check API_BASE_URL and that the backend is running.';
        }
      }
      state = state.copyWith(loading: false, errorMessage: message);
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      return false;
    }
  }
}

final signInControllerProvider = StateNotifierProvider<SignInController, SignInState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final user = ref.watch(currentUserProvider.notifier);
  return SignInController(repo, user);
});
