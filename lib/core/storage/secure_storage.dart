
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static FlutterSecureStorage? _storage;

  static Future<void> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
  }

  static Future<void> saveAccessToken(String token) async {
    await _storage?.write(key: 'access_token', value: token);
  }

  static Future<String?> getAccessToken() async {
    return _storage?.read(key: 'access_token');
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage?.write(key: 'refresh_token', value: token);
  }

  static Future<String?> getRefreshToken() async {
    return _storage?.read(key: 'refresh_token');
  }

  static Future<void> saveUserId(String id) async {
    await _storage?.write(key: 'user_id', value: id);
  }

  static Future<String?> getUserId() async {
    return _storage?.read(key: 'user_id');
  }

  static Future<void> saveUserEmail(String email) async {
    await _storage?.write(key: 'user_email', value: email);
  }

  static Future<String?> getUserEmail() async {
    return _storage?.read(key: 'user_email');
  }

  static Future<void> setRememberMe(bool value) async {
    await _storage?.write(key: 'remember_me', value: value.toString());
  }

  static Future<bool> getRememberMe() async {
    final val = await _storage?.read(key: 'remember_me');
    return val == 'true';
  }

  static Future<void> clearAuth() async {
    await _storage?.deleteAll();
  }

  static Future<void> setBiometricEnabled(bool value) async {
    await _storage?.write(key: 'biometric_enabled', value: value.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final val = await _storage?.read(key: 'biometric_enabled');
    return val == 'true';
  }
}
