import '../../domain/repositories/auth_repository.dart';
import 'package:waddi_platform/features/users/domain/entities/user_entity.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource = AuthRemoteDataSource();

  @override
  Future<UserEntity?> login(String email, String password) async {
    try {
      // Use Firebase Auth to validate credentials
      final firebaseUser = await _remoteDataSource.login(email, password);
      
      if (firebaseUser != null) {
        // Fetch user data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          return UserEntity(
            id: firebaseUser.uid,
            name: userData['name'] ?? firebaseUser.displayName ?? '',
            email: userData['email'] ?? firebaseUser.email ?? '',
            phoneNumber: userData['phoneNumber'] ?? firebaseUser.phoneNumber ?? '',
            role: userData['role'] ?? 'user',
            createdAt: userData['createdAt'] ?? Timestamp.now(),
            updatedAt: userData['updatedAt'] ?? Timestamp.now(),
            points: userData['points'] ?? 0,
            isGuestUser: false,
          );
        } else {
          // Create user document if it doesn't exist
          final userEntity = UserEntity(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            phoneNumber: firebaseUser.phoneNumber ?? '',
            role: 'user',
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            points: 0,
            isGuestUser: false,
          );
          
          // Save to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .set({
            'name': userEntity.name,
            'email': userEntity.email,
            'phoneNumber': userEntity.phoneNumber,
            'role': userEntity.role,
            'points': userEntity.points,
            'createdAt': userEntity.createdAt,
            'updatedAt': userEntity.updatedAt,
            'isGuestUser': false,
          });
          
          return userEntity;
        }
      }
      
      // Return null if authentication fails
      return null;
    } catch (e) {
      // Log the error for debugging
      print('Login error: $e');
      // Return null for any authentication error
      return null;
    }
  }

  @override
  Future<UserEntity?> register(String name, String email, String password) async {
    final user = await _remoteDataSource.register(email, password);
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      name: name,
      email: user.email ?? '',
      role: 'user',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      points: 0,
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Failed to logout: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final firebaseUser = _remoteDataSource.getCurrentUser();
      if (firebaseUser != null && !firebaseUser.isAnonymous) {
        // Fetch user data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          return UserEntity(
            id: firebaseUser.uid,
            name: userData['name'] ?? firebaseUser.displayName ?? '',
            email: userData['email'] ?? firebaseUser.email ?? '',
            phoneNumber: userData['phoneNumber'] ?? firebaseUser.phoneNumber ?? '',
            role: userData['role'] ?? 'user',
            createdAt: userData['createdAt'] ?? Timestamp.now(),
            updatedAt: userData['updatedAt'] ?? Timestamp.now(),
            points: userData['points'] ?? 0,
            isGuestUser: false,
          );
        }
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    final user = await _remoteDataSource.signInWithGoogle();
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      role: 'user',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      points: 0,
    );
  }

  @override
  Future<UserEntity?> signInAnonymously() async {
    final user = await _remoteDataSource.signInAnonymously();
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      name: 'Guest',
      email: '',
      role: 'user',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      points: 0,
    );
  }

  @override
  Future<void> changePassword(String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    await user.updatePassword(newPassword);
  }
}
