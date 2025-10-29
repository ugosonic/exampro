import 'package:exampro/core/utils/validators.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:exampro/features/auth/data/auth_repository.dart';
import 'package:exampro/features/auth/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class SignUpState {
  final String email;
  final String password;
  final String confirm;
  final bool loading;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;
  final String? errorMessage;
  const SignUpState({
    this.email = '',
    this.password = '',
    this.confirm = '',
    this.loading = false,
    this.emailError = null,
    this.passwordError = null,
    this.confirmError = null,
    this.errorMessage = null,
  });

  bool get canSubmit =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirm.isNotEmpty &&
      emailError == null &&
      passwordError == null &&
      confirmError == null;

  SignUpState copyWith({
    String? email,
    String? password,
    String? confirm,
    bool? loading,
    String? emailError,
    String? passwordError,
    String? confirmError,
    String? errorMessage,
  }) =>
      SignUpState(
        email: email ?? this.email,
        password: password ?? this.password,
        confirm: confirm ?? this.confirm,
        loading: loading ?? this.loading,
        emailError: emailError,
        passwordError: passwordError,
        confirmError: confirmError,
        errorMessage: errorMessage,
      );
}

class SignUpController extends StateNotifier<SignUpState> {
  final AuthRepository _repo;
  final StateController<User?> currentUser;
  SignUpController(this._repo, this.currentUser) : super(const SignUpState());

  void onEmailChanged(String v) {
    state = state.copyWith(
      email: v,
      emailError: Validators.isEmail(v) ? null : 'Invalid email',
      errorMessage: null,
    );
  }

  void onPasswordChanged(String v) {
    state = state.copyWith(
      password: v,
      passwordError: v.length >= 6 ? null : 'At least 6 characters',
      confirmError: state.confirm == v ? null : 'Passwords do not match',
      errorMessage: null,
    );
  }

  void onConfirmChanged(String v) {
    state = state.copyWith(
      confirm: v,
      confirmError: v == state.password ? null : 'Passwords do not match',
      errorMessage: null,
    );
  }

  Future<bool> submit() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final user = await _repo.register(state.email, state.password);
      currentUser.state = user;
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      var message = 'Failed to register';
      if (e is DioException) {
        final code = e.response?.statusCode ?? 0;
        if (code == 409) message = 'Email already exists';
      }
      state = state.copyWith(loading: false, errorMessage: message);
      return false;
    }
  }
}

final signUpControllerProvider = StateNotifierProvider<SignUpController, SignUpState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final user = ref.watch(currentUserProvider.notifier);
  return SignUpController(repo, user);
});
