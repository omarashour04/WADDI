import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/features/auth/domain/usecases/login_user.dart';
import 'package:waddi_platform/features/auth/domain/usecases/register_user.dart';
import 'package:waddi_platform/features/auth/domain/entities/user_entity.dart';
import 'package:waddi_platform/core/errors/failures.dart';

// State for the AuthNotifier
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });
  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier that holds and manages the authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  AuthNotifier(this._loginUser, this._registerUser) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _loginUser(LoginUserParams(email: email, password: password));
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _registerUser(RegisterUserParams(email: email, password: password, name: name));
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  // Placeholder for mapping failures to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server Error:  {failure.message}';
    } else if (failure is CacheFailure) {
      return 'Cache Error:  {failure.message}';
    } else if (failure is AuthFailure) {
      return 'Authentication Error:  {failure.message}';
    } else {
      return 'An unexpected error occurred.';
    }
  }
}

// The provider that exposes the AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // In a real app, you would provide the actual use case implementations here
  // For simplicity, we're using dummy ones. You'd use ref.read(someUseCaseProvider)
  final loginUser = ref.read(loginUserUseCaseProvider);
  final registerUser = ref.read(registerUserUseCaseProvider);
  return AuthNotifier(loginUser, registerUser);
}); 