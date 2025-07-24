import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/features/auth/domain/usecases/login_user.dart';
import 'package:waddi_platform/features/auth/domain/usecases/register_user.dart';
import 'package:waddi_platform/features/auth/domain/entities/user_entity.dart';
import 'package:waddi_platform/core/errors/failures.dart';
import 'package:waddi_platform/features/auth/auth_injection.dart';
import 'package:waddi_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// State for the AuthNotifier
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  AuthState({this.status = AuthStatus.initial, this.user, this.errorMessage});
  AuthState copyWith({AuthStatus? status, UserEntity? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  String? get error => errorMessage;
}

// Notifier that holds and manages the authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  AuthNotifier(this._loginUser, this._registerUser) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _loginUser(email, password);
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.error, errorMessage: 'Login failed');
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _registerUser(name, email, password);
      if (user != null) {
        // Save user to Firestore after successful registration
        await saveUserToFirestore(
          uid: user.uid,
          email: user.email,
          name: user.name,
          phoneNumber: null, // or user.phoneNumber if available
        );
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.error, errorMessage: 'Registration failed');
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    // TODO: Implement logout logic
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> resetPassword(String email) async {
    // TODO: Implement reset password logic
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(Duration(seconds: 1));
    state = state.copyWith(status: AuthStatus.initial);
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final repo = _loginUser.repository as AuthRepository;
      final user = await repo.signInWithGoogle();
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await saveUserToFirestore(
            uid: user.uid,
            email: user.email,
            name: user.name,
            phoneNumber: null,
          );
        }
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.error, errorMessage: 'Google sign-in failed');
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signInAnonymously() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final repo = _loginUser.repository as AuthRepository;
      final user = await repo.signInAnonymously();
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await saveUserToFirestore(
            uid: user.uid,
            email: user.email,
            name: user.name,
            phoneNumber: null,
          );
        }
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.error, errorMessage: 'Anonymous sign-in failed');
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  // Placeholder for mapping failures to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server Error: ${failure.message}';
    } else if (failure is CacheFailure) {
      return 'Cache Error: ${failure.message}';
    } else if (failure is AuthFailure) {
      return 'Authentication Error: ${failure.message}';
    } else {
      return 'An unexpected error occurred.';
    }
  }
}

// The provider that exposes the AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUser = ref.read(loginUserUseCaseProvider);
  final registerUser = ref.read(registerUserUseCaseProvider);
  return AuthNotifier(loginUser, registerUser);
});

Future<void> saveUserToFirestore({
  required String uid,
  required String email,
  required String name,
  String? phoneNumber,
}) async {
  final now = FieldValue.serverTimestamp();
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'email': email,
    'name': name,
    'role': 'user',
    'phoneNumber': phoneNumber ?? '',
    'createdAt': now,
    'updatedAt': now,
    'points': 0,
    'venueId': '',
    'fcmTokens': [],
  });
}
