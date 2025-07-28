import '../repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository repository;
  ChangePassword(this.repository);

  Future<void> call(String newPassword) {
    return repository.changePassword(newPassword);
  }
}
