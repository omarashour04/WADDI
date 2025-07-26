import '../repositories/auth_repository.dart';
import 'package:waddi_platform/features/users/domain/entities/user_entity.dart';

class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
} 