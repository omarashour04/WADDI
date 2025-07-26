// Abstract repository for authentication
import 'package:waddi_platform/features/users/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> register(String name, String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<void> resetPassword(String email);
  Future<UserEntity?> signInWithGoogle();
  Future<UserEntity?> signInAnonymously();
}
