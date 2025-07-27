import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/features/auth/domain/usecases/login_user.dart';
import 'package:waddi_platform/features/auth/domain/usecases/register_user.dart';
import 'package:waddi_platform/features/users/domain/entities/user_entity.dart';
import 'package:waddi_platform/core/errors/failures.dart';
import 'package:waddi_platform/features/auth/auth_injection.dart';
import 'package:waddi_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Check if the current user is a guest user
  bool get isGuestUser => user?.email.isEmpty == true || user?.name == 'Guest';
}

// Notifier that holds and manages the authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  AuthNotifier(this._loginUser, this._registerUser) : super(AuthState()) {
    // Initialize auth state when the notifier is created
    _initializeAuthState();
  }

  // Initialize authentication state by checking Firebase Auth
  Future<void> _initializeAuthState() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      print('Starting auth state initialization...');

      // Wait a bit to ensure Firebase Auth is fully initialized
      await Future.delayed(Duration(milliseconds: 500));

      final firebaseUser = FirebaseAuth.instance.currentUser;
      print('Firebase current user: ${firebaseUser?.uid ?? 'null'}');

      if (firebaseUser != null) {
        // User is already signed in, fetch user data from Firestore
        print('User found, fetching from Firestore...');
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final user = UserEntity(
            id: firebaseUser.uid,
            name: userData['name'] ?? '',
            email: userData['email'] ?? firebaseUser.email ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            role: userData['role'] ?? 'user',
            createdAt: userData['createdAt'] ?? Timestamp.now(),
            updatedAt: userData['updatedAt'] ?? Timestamp.now(),
          );
          print('User data found, setting authenticated state');
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        } else {
          // User exists in Firebase Auth but not in Firestore, create user document
          print('User not in Firestore, creating user document...');
          final user = UserEntity(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            phoneNumber: firebaseUser.phoneNumber ?? '',
            role: 'user',
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
          );
          await saveUserToFirestore(
            uid: user.id,
            email: user.email,
            name: user.name,
            phoneNumber: user.phoneNumber,
          );
          print('User document created, setting authenticated state');
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        }
      } else {
        // No user is signed in
        print('No user found, setting unauthenticated state');
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      print('Error initializing auth state: $e');
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

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
          uid: user.id,
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
    try {
      await FirebaseAuth.instance.signOut();
      state = AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
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
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.id);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await saveUserToFirestore(
            uid: user.id,
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
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.id);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await saveUserToFirestore(
            uid: user.id,
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
