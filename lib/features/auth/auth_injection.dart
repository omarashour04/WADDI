import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:waddi_platform/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:waddi_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:waddi_platform/features/auth/domain/usecases/login_user.dart';
import 'package:waddi_platform/features/auth/domain/usecases/register_user.dart';
import 'package:waddi_platform/features/auth/domain/usecases/get_current_user.dart';
import 'package:waddi_platform/features/auth/domain/usecases/logout_user.dart';
import 'package:waddi_platform/features/auth/domain/usecases/reset_password.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';

// Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// Use Cases
final loginUserUseCaseProvider = Provider<LoginUser>((ref) {
  return LoginUser(ref.read(authRepositoryProvider));
});
final registerUserUseCaseProvider = Provider<RegisterUser>((ref) {
  return RegisterUser(ref.read(authRepositoryProvider));
});
final getCurrentUserUseCaseProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.read(authRepositoryProvider));
});
final logoutUserUseCaseProvider = Provider<LogoutUser>((ref) {
  return LogoutUser(ref.read(authRepositoryProvider));
});
final resetPasswordUseCaseProvider = Provider<ResetPassword>((ref) {
  return ResetPassword(ref.read(authRepositoryProvider));
});

// Presentation Layer Providers
final authStateNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(loginUserUseCaseProvider),
    ref.read(registerUserUseCaseProvider),
  );
}); 