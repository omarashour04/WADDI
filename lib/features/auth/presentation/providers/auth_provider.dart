import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/features/auth/domain/usecases/login_user.dart';
import 'package:waddi_platform/features/auth/domain/usecases/register_user.dart';
import 'package:waddi_platform/features/auth/domain/usecases/reset_password.dart';
import 'package:waddi_platform/features/users/domain/entities/user_entity.dart';
import 'package:waddi_platform/core/errors/failures.dart';
import 'package:waddi_platform/features/auth/auth_injection.dart';
import 'package:waddi_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

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
  bool get isGuestUser {
    if (user == null) return false;
    // Check if user has guest role, empty email, or name is 'Guest'
    return user!.role == 'guest' || user!.email.isEmpty || user!.name == 'Guest';
  }
}

// Notifier that holds and manages the authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final ResetPassword _resetPassword;
  AuthNotifier(this._loginUser, this._registerUser, this._resetPassword) : super(AuthState()) {
    // Initialize auth state when the notifier is created
    _initializeAuthState().catchError((error) {
      print('Error in auth initialization: $error');
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: error.toString());
    });

    // Fallback: if still loading after 3 seconds, set as unauthenticated
    Future.delayed(Duration(seconds: 3)).then((_) {
      if (state.status == AuthStatus.loading) {
        print('Auth initialization timeout, setting as unauthenticated');
        state = state.copyWith(status: AuthStatus.unauthenticated);
        print('Auth state updated to: ${state.status}');
      }
    });
  }

  // Initialize authentication state by checking Firebase Auth
  Future<void> _initializeAuthState() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      print('Starting auth state initialization...');

      // Add timeout to prevent hanging
      final firebaseUser = await Future.any([
        Future.value(FirebaseAuth.instance.currentUser),
        Future.delayed(Duration(seconds: 3)).then((_) => null),
      ]);

      print('Firebase current user: ${firebaseUser?.uid ?? 'null'}');

      if (firebaseUser != null && !firebaseUser.isAnonymous) {
        // User is signed in, try to fetch user data with timeout
        try {
          final userDoc = await Future.any([
            FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get(),
            Future.delayed(
              Duration(seconds: 5),
            ).then((_) => throw TimeoutException('Firestore timeout')),
          ]);

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
              isGuestUser: false,
            );
            print('User data found, setting authenticated state');
            state = state.copyWith(status: AuthStatus.authenticated, user: user);
            print('Auth state updated to: ${state.status}');
          } else {
            // Create user document if it doesn't exist (only for registered users)
            final user = UserEntity(
              id: firebaseUser.uid,
              name: firebaseUser.displayName ?? '',
              email: firebaseUser.email ?? '',
              phoneNumber: firebaseUser.phoneNumber ?? '',
              role: 'user',
              createdAt: Timestamp.now(),
              updatedAt: Timestamp.now(),
              isGuestUser: false,
            );

            // Try to save user to Firestore with timeout
            try {
              await Future.any([
                saveUserToFirestore(
                  uid: user.id,
                  email: user.email,
                  name: user.name,
                  phoneNumber: user.phoneNumber,
                ),
                Future.delayed(
                  Duration(seconds: 5),
                ).then((_) => throw TimeoutException('Save user timeout')),
              ]);
              print('User document created, setting authenticated state');
            } catch (e) {
              print('Error saving user to Firestore: $e');
              // Continue even if save fails
            }

            state = state.copyWith(status: AuthStatus.authenticated, user: user);
            print('Auth state updated to: ${state.status}');
          }
        } catch (e) {
          print('Error fetching user data: $e');
          // If there's an error fetching user data, still set as authenticated
          final user = UserEntity(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            phoneNumber: firebaseUser.phoneNumber ?? '',
            role: 'user',
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            isGuestUser: false,
          );
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        }
      } else if (firebaseUser != null && firebaseUser.isAnonymous) {
        // Anonymous user - create local guest user entity (not saved to database)
        print('Anonymous user detected, creating guest user entity');
        final guestUser = UserEntity(
          id: firebaseUser.uid,
          name: 'Guest User',
          email: '',
          phoneNumber: '',
          role: 'guest',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          isGuestUser: true,
        );
        state = state.copyWith(status: AuthStatus.unauthenticated, user: guestUser);
      } else {
        // No user is signed in - start as guest
        print('No user found, starting as guest');
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      print('Error initializing auth state: $e');
      // On any error, set as unauthenticated to prevent infinite loading
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    // Basic validation
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter both email and password.',
      );
      return;
    }

    // Email format validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter a valid email address.',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _loginUser(email, password);
      if (user != null) {
        // Check if this is the user's first login
        final isFirstLogin = await _checkFirstLogin(user.id);
        if (isFirstLogin) {
          // Don't set authenticated state yet, let the router handle redirect to change password
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        } else {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Invalid email or password. Please try again.',
        );
      }
    } catch (e) {
      String errorMessage = 'Login failed. Please try again.';

      // Provide more specific error messages based on the exception
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'No account found with this email address.';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email format.';
      } else if (e.toString().contains('user-disabled')) {
        errorMessage = 'This account has been disabled.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many failed attempts. Please try again later.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      }

      state = state.copyWith(status: AuthStatus.error, errorMessage: errorMessage);
    }
  }

  Future<bool> _checkFirstLogin(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['isFirstLogin'] == true;
      }
      return false;
    } catch (e) {
      print('Error checking first login: $e');
      return false;
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
        
        // Add a small delay to ensure Firebase Auth account is fully created
        await Future.delayed(Duration(seconds: 2));
        
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        print('✅ User registered successfully: ${user.email}');
        print('⏳ Added 2-second delay to ensure Firebase Auth account is ready');
      } else {
        state = state.copyWith(status: AuthStatus.error, errorMessage: 'Registration failed');
      }
    } catch (e) {
      String errorMessage = 'Registration failed. Please try again.';

      // Provide more specific error messages based on the exception
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'An account with this email already exists. Please try logging in instead.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email format. Please enter a valid email address.';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak. Please choose a stronger password.';
      } else if (e.toString().contains('password-does-not-meet-requirements')) {
        errorMessage =
            'Password does not meet requirements. Please ensure your password contains uppercase, lowercase, number, and special character.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many failed attempts. Please try again later.';
      }

      state = state.copyWith(status: AuthStatus.error, errorMessage: errorMessage);
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

  // Check if an email exists in Firebase Auth
  Future<bool> checkEmailExists(String email) async {
    try {
      // First try the deprecated method (still works in most cases)
      try {
        final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
        print('Email existence check result: ${methods.isNotEmpty} for $email');
        return methods.isNotEmpty;
      } catch (deprecatedError) {
        print('Deprecated method failed, trying alternative approach: $deprecatedError');
        
        // Alternative approach: try to send reset email directly
        // If it fails with user-not-found, then the email doesn't exist
        try {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
          print('Email exists (reset email sent successfully)');
          return true;
        } catch (resetError) {
          if (resetError.toString().contains('user-not-found')) {
            print('Email does not exist in Firebase Auth');
            return false;
          } else {
            // If it's not a user-not-found error, the email probably exists
            print('Email likely exists (error was not user-not-found): $resetError');
            return true;
          }
        }
      }
    } catch (e) {
      print('Error checking if email exists: $e');
      // If we can't determine, assume it exists to avoid blocking legitimate users
      return true;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

      if (email.isEmpty) {
        throw Exception('No email provided for password reset');
      }

      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Please enter a valid email address');
      }

      print('Attempting to send password reset email to: $email');

      // Try to send reset email directly using Firebase Auth
      // This is more reliable than the use case approach
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Set success state - don't change authentication status
      state = state.copyWith(status: AuthStatus.authenticated, errorMessage: null);

      print('✅ Password reset email sent successfully to: $email');
      print('📧 Please check the user\'s email inbox (including spam folder)');
      print('🔗 The email should contain a link to reset the password');
    } catch (e) {
      print('❌ Error sending password reset email: $e');

      String errorMessage = 'Failed to send reset email. Please try again.';

      // Provide more specific error messages based on the exception
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'No account found with this email address.';
        print('🔍 User not found in Firebase Auth');
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email format.';
        print('📧 Invalid email format detected');
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many reset attempts. Please try again later.';
        print('⏰ Rate limiting applied');
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection and try again.';
        print('🌐 Network connectivity issue');
      } else if (e.toString().contains('operation-not-allowed')) {
        errorMessage = 'Password reset is not enabled for this project.';
        print('🚫 Password reset not enabled in Firebase Console');
      } else {
        print('❓ Unknown error type: ${e.runtimeType}');
        print('📋 Full error details: $e');
      }

      // Keep the current authentication status but set error message
      state = state.copyWith(errorMessage: errorMessage);
    }
  }

  Future<void> updateUserRole(String newRole) async {
    try {
      // Don't allow role updates for guest users
      if (state.user?.role == 'guest' || state.user?.isGuestUser == true) {
        print('Cannot update role for guest users');
        return;
      }

      state = state.copyWith(status: AuthStatus.loading);

      // Check if user document exists in Firestore
      final userDoc = FirebaseFirestore.instance.collection('users').doc(state.user!.id);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        // Update existing document
        await userDoc.update({'role': newRole, 'updatedAt': FieldValue.serverTimestamp()});
      } else {
        // Create new document if it doesn't exist
        await userDoc.set({
          'email': state.user!.email,
          'name': state.user!.name,
          'role': newRole,
          'phoneNumber': state.user!.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'points': 0,
          'venueId': '',
          'fcmTokens': [],
        });
      }

      // Update local state
      final updatedUser = state.user!.copyWith(role: newRole);
      state = state.copyWith(status: AuthStatus.authenticated, user: updatedUser);

      print('User role updated to: $newRole');
    } catch (e) {
      print('Error updating user role: $e');
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Failed to update role: $e');
    }
  }

  Future<void> updateUser({String? name, String? phoneNumber}) async {
    try {
      if (state.user == null) {
        throw Exception('No user to update');
      }

      state = state.copyWith(status: AuthStatus.loading);

      // Update Firestore document
      final userDoc = FirebaseFirestore.instance.collection('users').doc(state.user!.id);
      final updateData = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};

      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;

      await userDoc.update(updateData);

      // Update local state
      final updatedUser = state.user!.copyWith(
        name: name ?? state.user!.name,
        phoneNumber: phoneNumber ?? state.user!.phoneNumber,
      );

      state = state.copyWith(status: AuthStatus.authenticated, user: updatedUser);

      print('User profile updated successfully');
    } catch (e) {
      print('Error updating user profile: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to update profile: $e',
      );
    }
  }

  // Promote user to admin (for testing purposes)
  Future<void> promoteToAdmin() async {
    await updateUserRole('admin');
  }

  // Promote user to venue owner
  Future<void> promoteToVenueOwner() async {
    await updateUserRole('venue_owner');
  }

  // Demote user to regular user
  Future<void> demoteToUser() async {
    await updateUserRole('user');
  }

  // Convert guest user to registered user
  Future<void> convertGuestToUser({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        throw Exception('No guest user to convert');
      }

      // Create credential with email and password
      final credential = EmailAuthProvider.credential(email: email, password: password);

      // Link the anonymous account with email/password
      final userCredential = await currentUser.linkWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // Save to Firestore as a registered user
        await saveUserToFirestore(
          uid: user.uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
        );

        // Update local state
        final userEntity = UserEntity(
          id: user.uid,
          name: name,
          email: email,
          phoneNumber: phoneNumber ?? '',
          role: 'user',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          isGuestUser: false,
        );

        state = state.copyWith(status: AuthStatus.authenticated, user: userEntity);

        print('Guest user converted to registered user: ${user.uid}');
      }
    } catch (e) {
      print('Error converting guest to user: $e');
      String errorMessage = 'Failed to convert guest user. Please try again.';

      // Provide more specific error messages based on the exception
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'An account with this email already exists. Please try logging in instead.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email format. Please enter a valid email address.';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak. Please choose a stronger password.';
      } else if (e.toString().contains('password-does-not-meet-requirements')) {
        errorMessage =
            'Password does not meet requirements. Please ensure your password contains uppercase, lowercase, number, and special character.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many failed attempts. Please try again later.';
      }

      throw Exception(errorMessage);
    }
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

  // Sign in anonymously (guest user - no database entry)
  Future<void> signInAnonymously() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      // Check if user is already signed in as anonymous
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        // User is already signed in as guest, just update state
        final guestUser = UserEntity(
          id: currentUser.uid,
          name: 'Guest User',
          email: '',
          phoneNumber: '',
          role: 'guest',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          isGuestUser: true,
        );

        state = state.copyWith(status: AuthStatus.unauthenticated, user: guestUser);

        print('User already signed in as guest, updating state');
        return;
      }

      // Sign in anonymously
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        // Create a local user entity for guest users (not saved to Firestore)
        final guestUser = UserEntity(
          id: user.uid,
          name: 'Guest User',
          email: '',
          phoneNumber: '',
          role: 'guest',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          isGuestUser: true,
        );

        state = state.copyWith(
          status: AuthStatus.unauthenticated, // Keep as unauthenticated for guest access
          user: guestUser,
        );

        print('Guest user signed in anonymously, setting as unauthenticated');
      }
    } catch (e) {
      print('Error signing in anonymously: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to sign in anonymously: $e',
      );
    }
  }

  // Change password for the current user
  Future<String?> changePassword(String newPassword) async {
    try {
      final repo = _loginUser.repository as AuthRepository;
      await repo.changePassword(newPassword);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Refresh user data from Firestore
  Future<void> refreshUser() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && !firebaseUser.isAnonymous) {
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
            isGuestUser: false,
          );
          state = state.copyWith(user: user);
          print('User data refreshed from Firestore');
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
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
  final resetPassword = ref.read(resetPasswordUseCaseProvider);
  return AuthNotifier(loginUser, registerUser, resetPassword);
});

// Save user to Firestore (only for registered users, not guests)
Future<void> saveUserToFirestore({
  required String uid,
  required String email,
  required String name,
  String? phoneNumber,
}) async {
  try {
    // Only save to Firestore if this is a registered user (not anonymous)
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && !currentUser.isAnonymous) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber ?? '',
        'role': 'user',
        'points': 0,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'isGuestUser': false,
      });
      print('User saved to Firestore: $uid');
    } else {
      print('Skipping Firestore save for guest user: $uid');
    }
  } catch (e) {
    print('Error saving user to Firestore: $e');
    throw Exception('Failed to save user: $e');
  }
}
