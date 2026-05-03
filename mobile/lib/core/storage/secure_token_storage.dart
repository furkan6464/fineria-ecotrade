import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'ecotrade_access_jwt';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _accessKey, value: token);

  Future<void> clearAccessToken() => _storage.delete(key: _accessKey);
}
