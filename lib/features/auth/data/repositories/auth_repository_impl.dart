import '../../domain/repositories/auth_repository.dart';
import 'package:waddi_platform/features/users/domain/entities/user_entity.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource = AuthRemoteDataSource();

  @override
  Future<UserEntity?> login(String email, String password) async {
    // TODO: Integrate with Firebase Auth
    return UserEntity(
      id: '1',
      name: 'Test User',
      email: email,
      role: 'user',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      points: 0,
    );
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
    // TODO: Integrate with Firebase Auth
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // TODO: Integrate with Firebase Auth
    return null;
  }

  @override
  Future<void> resetPassword(String email) async {
    // TODO: Integrate with Firebase Auth
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
}
