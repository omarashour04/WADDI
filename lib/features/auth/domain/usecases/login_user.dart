import '../repositories/auth_repository.dart';
import 'package:waddi_platform/features/users/domain/entities/user_entity.dart';

class LoginUser {
  final AuthRepository repository;
  LoginUser(this.repository);

  Future<UserEntity?> call(String email, String password) {
    return repository.login(email, password);
  }
} 