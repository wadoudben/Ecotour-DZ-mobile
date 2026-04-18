import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'auth_role';

  final FlutterSecureStorage _storage;

  const SecureStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveAuth({required String token, required String role}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<String?> readRole() {
    return _storage.read(key: _roleKey);
  }

  Future<String?> getRole() {
    return readRole();
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }
}
