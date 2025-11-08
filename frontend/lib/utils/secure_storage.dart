import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> saveUser(String userData) async {
    await _storage.write(key: 'user', value: userData);
  }

  static Future<String?> getUser() async {
    return await _storage.read(key: 'user');
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
