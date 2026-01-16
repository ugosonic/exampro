<<<<<<< HEAD
import 'package:exampro/core/utils/validators.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:exampro/features/auth/data/auth_repository.dart';
import 'package:exampro/features/auth/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
=======
import 'package:citizentest/core/utils/validators.dart';
import 'package:citizentest/features/auth/application/auth_session.dart';
import 'package:citizentest/features/auth/data/auth_repository.dart';
import 'package:citizentest/features/auth/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45

class SignUpState {
  final String email;
  final String password;
<<<<<<< HEAD
  final String confirmPassword;
=======
  final String confirm;
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  final bool loading;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;
  final String? errorMessage;
<<<<<<< HEAD

  const SignUpState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
=======
  const SignUpState({
    this.email = '',
    this.password = '',
    this.confirm = '',
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    this.loading = false,
    this.emailError,
    this.passwordError,
    this.confirmError,
    this.errorMessage,
  });

  bool get canSubmit =>
      email.isNotEmpty &&
      password.isNotEmpty &&
<<<<<<< HEAD
      confirmPassword.isNotEmpty &&
=======
      confirm.isNotEmpty &&
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      emailError == null &&
      passwordError == null &&
      confirmError == null;

  SignUpState copyWith({
    String? email,
    String? password,
<<<<<<< HEAD
    String? confirmPassword,
=======
    String? confirm,
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    bool? loading,
    String? emailError,
    String? passwordError,
    String? confirmError,
    String? errorMessage,
  }) =>
      SignUpState(
        email: email ?? this.email,
        password: password ?? this.password,
<<<<<<< HEAD
        confirmPassword: confirmPassword ?? this.confirmPassword,
=======
        confirm: confirm ?? this.confirm,
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
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
<<<<<<< HEAD
      passwordError: state.password.isEmpty ? 'Password is required' : null,
      confirmError: _confirmError(state.confirmPassword, v, state.password),
=======
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      errorMessage: null,
    );
  }

  void onPasswordChanged(String v) {
    state = state.copyWith(
      password: v,
<<<<<<< HEAD
      passwordError: v.isEmpty ? 'Password is required' : null,
      emailError: Validators.isEmail(state.email) ? null : 'Invalid email',
      confirmError: _confirmError(state.confirmPassword, state.email, v),
=======
      passwordError: v.length >= 6 ? null : 'At least 6 characters',
      confirmError: state.confirm == v ? null : 'Passwords do not match',
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      errorMessage: null,
    );
  }

  void onConfirmChanged(String v) {
    state = state.copyWith(
<<<<<<< HEAD
      confirmPassword: v,
      confirmError: _confirmError(v, state.email, state.password),
      emailError: Validators.isEmail(state.email) ? null : 'Invalid email',
      passwordError: state.password.isEmpty ? 'Password is required' : null,
=======
      confirm: v,
      confirmError: v == state.password ? null : 'Passwords do not match',
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      errorMessage: null,
    );
  }

<<<<<<< HEAD
  String? _confirmError(String confirm, String email, String password) {
    if (confirm.isEmpty) return 'Confirm your password';
    if (password.isEmpty || email.isEmpty) return null;
    if (confirm != password) return 'Passwords do not match';
    return null;
  }

  Future<bool> submit() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final user = await _repo.signUp(state.email, state.password);
=======
  Future<bool> submit() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final user = await _repo.register(state.email, state.password);
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      currentUser.state = user;
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
<<<<<<< HEAD
      state = state.copyWith(loading: false, errorMessage: 'Failed to register');
=======
      var message = 'Failed to register';
      if (e is DioException) {
        final code = e.response?.statusCode ?? 0;
        if (code == 409) message = 'Email already exists';
      }
      state = state.copyWith(loading: false, errorMessage: message);
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      return false;
    }
  }
}

final signUpControllerProvider = StateNotifierProvider<SignUpController, SignUpState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final user = ref.watch(currentUserProvider.notifier);
  return SignUpController(repo, user);
});
