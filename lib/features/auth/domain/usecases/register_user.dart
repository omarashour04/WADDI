import '../repositories/auth_repository.dart';
import 'package:waddi_platform/features/users/domain/entities/user_entity.dart';

class RegisterUser {
  final AuthRepository repository;
  RegisterUser(this.repository);

  Future<UserEntity?> call(String name, String email, String password) {
    return repository.register(name, email, password);
  }
} 