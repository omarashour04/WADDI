import 'package:waddi_platform/core/services/local_storage_service.dart';

class AuthLocalDataSource {
  final LocalStorageService _storage = LocalStorageService();

  Future<void> saveToken(String token) async {
    await _storage.saveString('auth_token', token);
  }

  Future<String?> getToken() async {
    return _storage.getString('auth_token');
  }

  Future<void> clearToken() async {
    await _storage.remove('auth_token');
  }
} 