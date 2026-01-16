import 'package:exampro/core/utils/validators.dart';
import 'package:exampro/features/auth/application/auth_session.dart';
import 'package:exampro/features/auth/data/auth_repository.dart';
import 'package:exampro/features/auth/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpState {
  final String email;
  final String password;
  final String confirmPassword;
  final bool loading;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;
  final String? errorMessage;

  const SignUpState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.loading = false,
    this.emailError,
    this.passwordError,
    this.confirmError,
    this.errorMessage,
  });

  bool get canSubmit =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      emailError == null &&
      passwordError == null &&
      confirmError == null;

  SignUpState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? loading,
    String? emailError,
    String? passwordError,
    String? confirmError,
    String? errorMessage,
  }) =>
      SignUpState(
        email: email ?? this.email,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
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
      passwordError: state.password.isEmpty ? 'Password is required' : null,
      confirmError: _confirmError(state.confirmPassword, v, state.password),
      errorMessage: null,
    );
  }

  void onPasswordChanged(String v) {
    state = state.copyWith(
      password: v,
      passwordError: v.isEmpty ? 'Password is required' : null,
      emailError: Validators.isEmail(state.email) ? null : 'Invalid email',
      confirmError: _confirmError(state.confirmPassword, state.email, v),
      errorMessage: null,
    );
  }

  void onConfirmChanged(String v) {
    state = state.copyWith(
      confirmPassword: v,
      confirmError: _confirmError(v, state.email, state.password),
      emailError: Validators.isEmail(state.email) ? null : 'Invalid email',
      passwordError: state.password.isEmpty ? 'Password is required' : null,
      errorMessage: null,
    );
  }

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
      currentUser.state = user;
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, errorMessage: 'Failed to register');
      return false;
    }
  }
}

final signUpControllerProvider = StateNotifierProvider<SignUpController, SignUpState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final user = ref.watch(currentUserProvider.notifier);
  return SignUpController(repo, user);
});
