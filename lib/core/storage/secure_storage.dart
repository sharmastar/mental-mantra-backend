import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static FlutterSecureStorage? _storage;

  static Future<void> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(),
    );
  }

  static Future<void> saveAccessToken(String token) async {
    try {
      await _storage?.write(key: 'access_token', value: token);
    } catch (e) {
      debugPrint('[SecureStorage] Error writing access_token: $e');
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      return await _storage?.read(key: 'access_token');
    } catch (e) {
      debugPrint('[SecureStorage] Error reading access_token: $e');
      return null;
    }
  }

  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage?.write(key: 'refresh_token', value: token);
    } catch (e) {
      debugPrint('[SecureStorage] Error writing refresh_token: $e');
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage?.read(key: 'refresh_token');
    } catch (e) {
      debugPrint('[SecureStorage] Error reading refresh_token: $e');
      return null;
    }
  }

  static Future<void> saveUserId(String id) async {
    try {
      await _storage?.write(key: 'user_id', value: id);
    } catch (e) {
      debugPrint('[SecureStorage] Error writing user_id: $e');
    }
  }

  static Future<String?> getUserId() async {
    try {
      return await _storage?.read(key: 'user_id');
    } catch (e) {
      debugPrint('[SecureStorage] Error reading user_id: $e');
      return null;
    }
  }

  static Future<void> saveUserEmail(String email) async {
    try {
      await _storage?.write(key: 'user_email', value: email);
    } catch (e) {
      debugPrint('[SecureStorage] Error writing user_email: $e');
    }
  }

  static Future<String?> getUserEmail() async {
    try {
      return await _storage?.read(key: 'user_email');
    } catch (e) {
      debugPrint('[SecureStorage] Error reading user_email: $e');
      return null;
    }
  }

  static Future<void> setRememberMe(bool value) async {
    try {
      await _storage?.write(key: 'remember_me', value: value.toString());
    } catch (e) {
      debugPrint('[SecureStorage] Error writing remember_me: $e');
    }
  }

  static Future<bool> getRememberMe() async {
    try {
      final val = await _storage?.read(key: 'remember_me');
      return val == 'true';
    } catch (e) {
      debugPrint('[SecureStorage] Error reading remember_me: $e');
      return false;
    }
  }

  static Future<void> clearAuth() async {
    try {
      // Only delete session tokens; preserve biometric/remember_me preferences
      await _storage?.delete(key: 'access_token');
      await _storage?.delete(key: 'refresh_token');
      await _storage?.delete(key: 'user_id');
      await _storage?.delete(key: 'user_email');
    } catch (e) {
      debugPrint('[SecureStorage] Error clearing auth storage: $e');
    }
  }

  static Future<void> setBiometricEnabled(bool value) async {
    try {
      await _storage?.write(key: 'biometric_enabled', value: value.toString());
    } catch (e) {
      debugPrint('[SecureStorage] Error writing biometric_enabled: $e');
    }
  }

  static Future<bool> isBiometricEnabled() async {
    try {
      final val = await _storage?.read(key: 'biometric_enabled');
      return val == 'true';
    } catch (e) {
      debugPrint('[SecureStorage] Error reading biometric_enabled: $e');
      return false;
    }
  }
}
