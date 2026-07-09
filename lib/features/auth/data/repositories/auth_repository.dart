import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mental_mantra/core/network/api_client.dart';
import 'package:mental_mantra/core/storage/secure_storage.dart';
import 'package:mental_mantra/core/storage/hive_storage.dart';
import 'package:mental_mantra/core/errors/app_exceptions.dart';
import 'package:mental_mantra/core/utils/connectivity.dart';
import '../models/user_model.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: const String.fromEnvironment(
      'GOOGLE_CLIENT_ID',
      defaultValue: '209321341979-m1rj7jn5b73b9gk0saiqumi393o52n1n.apps.googleusercontent.com',
    ),
  );

  UserModel _parseUser(Map<String, dynamic> json) {
    return UserModel.fromJson({
      ...json,
      'uid': json['uid'] ?? json['id'] ?? '',
    });
  }

  UserModel _mergeWithCache(UserModel model) {
    try {
      final cached = HiveStorage.getUser();
      if (cached.isNotEmpty) {
        final cachedModel = UserModel.fromJson(cached);
        return model.copyWith(
          onboardingCompleted: cachedModel.onboardingCompleted,
          streakDays: cachedModel.streakDays,
          totalPoints: cachedModel.totalPoints,
          level: cachedModel.level,
          nickname: cachedModel.nickname,
          age: cachedModel.age,
          gender: cachedModel.gender,
          country: cachedModel.country,
        );
      }
    } catch (e) {
      debugPrint('[AuthRepo] Cache merge failed: $e');
    }
    return model;
  }

  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final hasNet = await ConnectivityUtil.hasInternet();
      if (!hasNet) {
        throw const NetworkException(
          message: 'No internet connection. Please check your network and try again.',
          code: 'NETWORK_ERROR',
        );
      }

      final response = await ApiClient.post('/auth/register', data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        final rawMsg = data['message'];
        throw AppException(
          message: rawMsg is List ? rawMsg.join(', ') : (rawMsg?.toString() ?? 'Sign up failed'),
          code: data['code']?.toString() ?? 'SIGNUP_ERROR',
        );
      }

      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      final user = _parseUser(data['user'] as Map<String, dynamic>);

      await SecureStorage.saveAccessToken(accessToken);
      await SecureStorage.saveRefreshToken(refreshToken);
      await _persistUser(user);

      return user;
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('[AuthRepo] Sign up failed: $e');
      throw AppException(message: 'Sign up failed: $e', code: 'SIGNUP_ERROR');
    }
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final hasNet = await ConnectivityUtil.hasInternet();
      if (!hasNet) {
        throw const NetworkException(
          message: 'No internet connection. Please check your network and try again.',
          code: 'NETWORK_ERROR',
        );
      }

      final response = await ApiClient.post('/auth/login', data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        final rawMsg = data['message'];
        throw AppException(
          message: rawMsg is List ? rawMsg.join(', ') : (rawMsg?.toString() ?? 'Login failed'),
          code: data['code']?.toString() ?? 'LOGIN_ERROR',
        );
      }

      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      final user = _parseUser(data['user'] as Map<String, dynamic>);

      await SecureStorage.saveAccessToken(accessToken);
      await SecureStorage.saveRefreshToken(refreshToken);
      await SecureStorage.setRememberMe(rememberMe);
      await _persistUser(user);

      return _mergeWithCache(user);
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('[AuthRepo] Sign in failed: $e');
      throw AppException(message: 'Login failed: $e', code: 'LOGIN_ERROR');
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final hasNet = await ConnectivityUtil.hasInternet();
      if (!hasNet) {
        throw const NetworkException(
          message: 'No internet connection detected.',
          code: 'NETWORK_ERROR',
        );
      }

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        final errStr = e.toString();
        if (errStr.contains('sign_in_aborted') || errStr.contains('cancelled')) {
          throw const AuthException(message: 'Google Sign-In was cancelled.', code: 'GOOGLE_CANCELLED');
        }
        if (errStr.contains('network_error') || errStr.contains('7:')) {
          throw const NetworkException(message: 'Network error during Google Sign-In.', code: 'NETWORK_ERROR');
        }
        rethrow;
      }

      if (googleUser == null) {
        throw const AuthException(message: 'Google Sign-In was cancelled.', code: 'GOOGLE_CANCELLED');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthException(message: 'Unable to complete Google Sign-In.', code: 'GOOGLE_NO_TOKEN');
      }

      final response = await ApiClient.post('/auth/google', data: {
        'idToken': idToken,
        'accessToken': googleAuth.accessToken,
        'serverAuthCode': googleUser.serverAuthCode,
        'device': 'android', // Or targetPlatform check if needed
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
      });

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        final rawMsg = data['message'];
        throw AppException(
          message: rawMsg is List ? rawMsg.join(', ') : (rawMsg?.toString() ?? 'Google Sign-In failed'),
          code: data['code']?.toString() ?? 'GOOGLE_ERROR',
        );
      }

      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      final user = _parseUser(data['user'] as Map<String, dynamic>);

      await SecureStorage.saveAccessToken(accessToken);
      await SecureStorage.saveRefreshToken(refreshToken);
      await _persistUser(user);

      return _mergeWithCache(user);
    } on AppException {
      rethrow;
    } catch (e, stack) {
      debugPrint('[GoogleAuth] Error: $e\n$stack');
      throw AuthException(message: 'Google Sign-In failed: $e', code: 'GOOGLE_ERROR');
    }
  }

  Future<UserModel?> restoreSession() async {
    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;

    try {
      ApiClient.init();
      final response = await ApiClient.get('/users/me');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final user = _parseUser(data['data'] as Map<String, dynamic>);
        await _persistUser(user);
        return _mergeWithCache(user);
      }
    } catch (e) {
      debugPrint('[AuthRepo] Session restore failed: $e');
      return null;
    }
    return null;
  }

  Future<void> forgotPassword(String email) async {
    try {
      final hasNet = await ConnectivityUtil.hasInternet();
      if (!hasNet) {
        throw const NetworkException(
          message: 'No internet connection. Please check your network and try again.',
          code: 'NETWORK_ERROR',
        );
      }
      await ApiClient.post('/auth/forgot-password', data: {
        'email': email.trim().toLowerCase(),
      });
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('[Auth] Forgot password failed: $e');
      throw const AppException(message: 'Failed to send reset email. Please try again.', code: 'RESET_ERROR');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('[AuthRepo] Google sign out on delete error: $e');
    }
    await SecureStorage.clearAuth();
    await HiveStorage.clearUser();
  }

  Future<void> signOut() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      await ApiClient.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (e) {
      debugPrint('[AuthRepo] Logout backend error: $e');
    }
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('[AuthRepo] Google sign out error: $e');
    }
    await SecureStorage.clearAuth();
    await HiveStorage.clearUser();
  }

  Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await ApiClient.put('/users/me', data: updates);
      final data = response.data as Map<String, dynamic>;
      final user = _parseUser(data['data'] as Map<String, dynamic>);
      await _persistUser(user);
      return user;
    } catch (e) {
      debugPrint('[AuthRepo] Profile update failed: $e');
      rethrow;
    }
  }

  Future<void> markOnboardingComplete(Map<String, dynamic> onboardingData) async {
    await HiveStorage.saveOnboardingData(onboardingData);
    try {
      final cachedUser = HiveStorage.getUser();
      if (cachedUser.isNotEmpty) {
        final model = UserModel.fromJson(cachedUser).copyWith(
          onboardingCompleted: true,
          nickname: onboardingData['nickname'] as String?,
          gender: onboardingData['gender'] as String?,
          country: onboardingData['country'] as String?,
          relationshipStatus: onboardingData['relationship_status'] as String?,
          livingSituation: onboardingData['living_situation'] as String?,
          occupation: onboardingData['occupation'] as String?,
          ageGroup: onboardingData['age_group'] as String?,
        );
        await HiveStorage.saveUser(model.toJson());
      }
    } catch (e) {
      debugPrint('[AuthRepo] Onboarding cache update failed: $e');
    }

    try {
      await ApiClient.post('/users/me/onboarding', data: {
        ...onboardingData,
        'onboardingCompleted': true,
      });
    } catch (e) {
      debugPrint('[AuthRepo] Onboarding backend sync failed: $e');
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    try {
      await ApiClient.post('/auth/verify-otp', data: {'email': email, 'otp': otp});
      return true;
    } catch (e) {
      debugPrint('[AuthRepo] OTP verification API error: $e');
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    try {
      await ApiClient.post('/auth/resend-otp', data: {'email': email});
      return true;
    } catch (e) {
      debugPrint('[AuthRepo] OTP resend API error: $e');
      return false;
    }
  }

  Future<void> _persistUser(UserModel user) async {
    await SecureStorage.saveUserId(user.uid);
    await SecureStorage.saveUserEmail(user.email);
    await HiveStorage.saveUser(user.toJson());
  }

  Future<UserModel> signInAnonymously() async {
    try {
      final response = await ApiClient.post('/auth/anonymous');
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      final user = _parseUser(data['user'] as Map<String, dynamic>);
      
      await SecureStorage.saveAccessToken(accessToken);
      await SecureStorage.saveRefreshToken(refreshToken);
      await _persistUser(user);
      
      return _mergeWithCache(user);
    } catch (e) {
      debugPrint('[AuthRepo] Anonymous sign in failed: $e');
      throw const AppException(message: 'Anonymous sign in failed', code: 'ANON_ERROR');
    }
  }
}
