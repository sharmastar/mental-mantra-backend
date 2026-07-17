import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mental_mantra/core/network/api_client.dart';
import 'package:mental_mantra/core/storage/secure_storage.dart';
import 'package:mental_mantra/core/storage/hive_storage.dart';
import 'package:mental_mantra/core/errors/app_exceptions.dart';
import 'package:mental_mantra/core/utils/connectivity.dart';
import '../models/user_model.dart';
import 'package:mental_mantra/core/config/app_config.dart';

class AuthRepository {
  static const _fallbackWebClientId =
      '209321341979-m1rj7jn5b73b9gk0saiqumi393o52n1n.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? (const String.fromEnvironment(
            'GOOGLE_CLIENT_ID',
            defaultValue: '',
          )).isEmpty
            ? _fallbackWebClientId
            : const String.fromEnvironment(
                'GOOGLE_CLIENT_ID',
                defaultValue: '',
              )
        : null,
    scopes: ['email', 'profile'],
    serverClientId: kIsWeb
        ? null
        : (const String.fromEnvironment(
            'GOOGLE_CLIENT_ID',
            defaultValue: '',
          )).isEmpty
            ? _fallbackWebClientId
            : const String.fromEnvironment(
                'GOOGLE_CLIENT_ID',
                defaultValue: '',
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

  /// Pre-flight check: ensure network + backend are available before auth calls.
  Future<void> _ensureBackendReachable() async {
    final hasNet = await ConnectivityUtil.hasInternet();
    if (!hasNet) {
      throw const NetworkException(
        message:
            'No internet connection. Please check your network and try again.',
        code: 'NETWORK_ERROR',
      );
    }

    // If health check hasn't completed or failed, try one more resolution
    if (!AppConfig.isBackendHealthy) {
      debugPrint(
        '[AuthRepo] Backend not yet verified healthy. '
        'Attempting last-chance resolution...',
      );
      final reachable = await AppConfig.isBackendReachable();
      debugPrint('[AuthRepo] Backend reachable: $reachable');
      // Don't block — the API call will surface the real error
    }

    debugPrint('[AuthRepo] Using API URL: ${AppConfig.apiBaseUrl}');
  }

  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _ensureBackendReachable();

      // OFFLINE TEST MODE BYPASS
      if (AppConfig.hasCompletedHealthCheck && !AppConfig.isBackendHealthy) {
        final user = UserModel(
          uid: 'offline_user',
          email: email.trim().toLowerCase(),
          displayName: name,
          onboardingCompleted: true,
          createdAt: DateTime.now(),
        );
        await SecureStorage.saveAccessToken('offline_token');
        await SecureStorage.saveRefreshToken('offline_refresh');
        await _persistUser(user);
        return user;
      }

      debugPrint('[AuthRepo] Calling /auth/register for ${email.trim()}...');
      final stopwatch = Stopwatch()..start();

      final response = await ApiClient.post('/auth/register', data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      stopwatch.stop();
      debugPrint(
        '[AuthRepo] /auth/register completed in ${stopwatch.elapsedMilliseconds}ms',
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        final rawMsg = data['message'];
        throw AppException(
          message: rawMsg is List
              ? rawMsg.join(', ')
              : (rawMsg?.toString() ?? 'Sign up failed'),
          code: data['code']?.toString() ?? 'SIGNUP_ERROR',
        );
      }

      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final user = _parseUser(Map<String, dynamic>.from(data['user'] as Map? ?? {}));

      if (accessToken == null || refreshToken == null) {
        throw const AppException(
          message: 'Invalid response from server: missing tokens.',
          code: 'SIGNUP_ERROR',
        );
      }

      await SecureStorage.saveAccessToken(accessToken);
      await SecureStorage.saveRefreshToken(refreshToken);
      await _persistUser(user);

      return user;
    } catch (e, stack) {
      if (e is AppException) rethrow;
      debugPrint('[AuthRepo] Sign up failed: $e\n$stack');
      throw AppException(message: 'Sign up failed: $e', code: 'SIGNUP_ERROR');
    }
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      await _ensureBackendReachable();

      // OFFLINE TEST MODE BYPASS
      if (AppConfig.hasCompletedHealthCheck && !AppConfig.isBackendHealthy) {
        final user = UserModel(
          uid: 'offline_user',
          email: email.trim().toLowerCase(),
          displayName: 'Offline Tester',
          onboardingCompleted: true,
          createdAt: DateTime.now(),
        );
        await SecureStorage.saveAccessToken('offline_token');
        await SecureStorage.saveRefreshToken('offline_refresh');
        await _persistUser(user);
        return user;
      }

      debugPrint('[AuthRepo] Calling /auth/login for ${email.trim()}...');
      final stopwatch = Stopwatch()..start();

      final response = await ApiClient.post('/auth/login', data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      stopwatch.stop();
      debugPrint(
        '[AuthRepo] /auth/login completed in ${stopwatch.elapsedMilliseconds}ms',
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        final rawMsg = data['message'];
        throw AppException(
          message: rawMsg is List
              ? rawMsg.join(', ')
              : (rawMsg?.toString() ?? 'Login failed'),
          code: data['code']?.toString() ?? 'LOGIN_ERROR',
        );
      }

      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final user = _parseUser(Map<String, dynamic>.from(data['user'] as Map? ?? {}));

      if (accessToken == null || refreshToken == null) {
        throw const AppException(
          message: 'Invalid response from server: missing tokens.',
          code: 'LOGIN_ERROR',
        );
      }

      await SecureStorage.saveAccessToken(accessToken);
      await SecureStorage.saveRefreshToken(refreshToken);
      await SecureStorage.setRememberMe(rememberMe);
      await _persistUser(user);

      return _mergeWithCache(user);
    } catch (e, stack) {
      if (e is AppException) rethrow;
      debugPrint('[AuthRepo] Sign in failed: $e\n$stack');
      throw AppException(message: 'Login failed: $e', code: 'LOGIN_ERROR');
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      debugPrint('[AuthRepo] signInWithGoogle starting...');
      await _ensureBackendReachable();

      // OFFLINE TEST MODE BYPASS
      if (AppConfig.hasCompletedHealthCheck && !AppConfig.isBackendHealthy) {
        debugPrint(
            '[AuthRepo] Backend is unhealthy, bypassing with offline Google user');
        final user = UserModel(
          uid: 'offline_google_user',
          email: 'offline.google@test.com',
          displayName: 'Google Offline Tester',
          onboardingCompleted: true,
          createdAt: DateTime.now(),
        );
        await SecureStorage.saveAccessToken('offline_token');
        await SecureStorage.saveRefreshToken('offline_refresh');
        await _persistUser(user);
        return user;
      }

      GoogleSignInAccount? googleUser;
      try {
        debugPrint('[AuthRepo] Triggering _googleSignIn.signIn()...');
        googleUser = await _googleSignIn.signIn();
        debugPrint('[AuthRepo] googleUser resolved: $googleUser');
      } catch (e, stack) {
        debugPrint(
            '[AuthRepo] Exception during _googleSignIn.signIn(): $e\n$stack');
        final errStr = e.toString();
        if (errStr.contains('sign_in_aborted') ||
            errStr.contains('cancelled')) {
          throw const AuthException(
              message: 'Google Sign-In was cancelled.',
              code: 'GOOGLE_CANCELLED');
        }
        if (errStr.contains('network_error') || errStr.contains('7:')) {
          throw const NetworkException(
              message: 'Network error during Google Sign-In.',
              code: 'NETWORK_ERROR');
        }
        if (errStr.contains('people.googleapis.com') ||
            errStr.contains('People API') ||
            errStr.contains('PERMISSION_DENIED')) {
          throw const AuthException(
              message: 'Google Sign-In is temporarily unavailable. Please try again in a few minutes.',
              code: 'PEOPLE_API_DISABLED');
        }
        rethrow;
      }

      if (googleUser == null) {
        debugPrint(
            '[AuthRepo] Google User is null (sign-in cancelled by user)');
        throw const AuthException(
            message: 'Google Sign-In was cancelled.', code: 'GOOGLE_CANCELLED');
      }

      debugPrint('[AuthRepo] Requesting authentication details...');
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      debugPrint(
          '[AuthRepo] googleAuth.idToken: ${idToken != null ? "Fetched" : "NULL"}');
      debugPrint(
          '[AuthRepo] googleAuth.accessToken: ${accessToken != null ? "Fetched" : "NULL"}');

      if (idToken == null && accessToken == null) {
        throw const AuthException(
            message: 'Unable to complete Google Sign-In. No token returned.',
            code: 'GOOGLE_NO_TOKEN');
      }

      debugPrint('[AuthRepo] Sending Google token details to backend...');
      final stopwatch = Stopwatch()..start();

      final response = await ApiClient.post('/auth/google', data: {
        'idToken': idToken,
        'accessToken': accessToken,
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
      });

      stopwatch.stop();
      debugPrint(
        '[AuthRepo] /auth/google completed in ${stopwatch.elapsedMilliseconds}ms',
      );

      final data = response.data as Map<String, dynamic>;
      debugPrint(
          '[AuthRepo] Backend response success status: ${data['success']}');
      if (data['success'] != true) {
        final rawMsg = data['message'];
        throw AppException(
          message: rawMsg is List
              ? rawMsg.join(', ')
              : (rawMsg?.toString() ?? 'Google Sign-In failed'),
          code: data['code']?.toString() ?? 'GOOGLE_ERROR',
        );
      }

      final serverAccessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final user = _parseUser(Map<String, dynamic>.from(data['user'] as Map? ?? {}));

      if (serverAccessToken == null || refreshToken == null) {
        throw const AppException(
          message: 'Invalid response from server: missing tokens.',
          code: 'GOOGLE_ERROR',
        );
      }

      await SecureStorage.saveAccessToken(serverAccessToken);
      await SecureStorage.saveRefreshToken(refreshToken);
      await _persistUser(user);

      debugPrint('[AuthRepo] Google sign-in workflow successfully completed');
      return _mergeWithCache(user);
    } on AppException catch (e, stack) {
      debugPrint('[AuthRepo] AppException caught and rethrown: $e\n$stack');
      rethrow;
    } catch (e, stack) {
      debugPrint('[AuthRepo] Google Sign in failed: $e\n$stack');
      throw AuthException(
          message: 'Google Sign-In failed: $e', code: 'GOOGLE_ERROR');
    }
  }

  Future<UserModel?> restoreSession() async {
    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;

    try {
      ApiClient.init();

      // Return cached user immediately for fast startup, update in background
      final cachedMap = HiveStorage.getUser();
      if (cachedMap.isNotEmpty) {
        Future.microtask(() async {
          try {
            final response = await ApiClient.get('/users/me');
            final data = response.data as Map<String, dynamic>;
            if (data['success'] == true && data['data'] != null) {
              final user = _parseUser(Map<String, dynamic>.from(data['data'] as Map? ?? {}));
              await _persistUser(user);
            }
          } catch (e) {
            debugPrint('[AuthRepo] Background session refresh failed: $e');
          }
        });

        return UserModel.fromJson(cachedMap);
      }

      final response = await ApiClient.get('/users/me');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final user = _parseUser(Map<String, dynamic>.from(data['data'] as Map? ?? {}));
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
      await _ensureBackendReachable();
      await ApiClient.post('/auth/forgot-password', data: {
        'email': email.trim().toLowerCase(),
      });
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('[Auth] Forgot password failed: $e');
      throw const AppException(
          message: 'Failed to send reset email. Please try again.',
          code: 'RESET_ERROR');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await ApiClient.delete('/users/me');
    } catch (e) {
      debugPrint('[AuthRepo] Account deletion API error: $e');
    }
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
      await ApiClient.post('/auth/logout',
          data: {'refreshToken': refreshToken});
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
    ApiClient.cancelAll();
  }

  Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await ApiClient.put('/users/me', data: updates);
      final data = response.data as Map<String, dynamic>;
      final user = _parseUser(Map<String, dynamic>.from(data['data'] as Map? ?? {}));
      await _persistUser(user);
      return user;
    } catch (e) {
      debugPrint('[AuthRepo] Profile update failed: $e');
      rethrow;
    }
  }

  Future<void> markOnboardingComplete(
      Map<String, dynamic> onboardingData) async {
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
      await ApiClient.post('/auth/verify-otp',
          data: {'email': email, 'otp': otp});
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
      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final user = _parseUser(Map<String, dynamic>.from(data['user'] as Map? ?? {}));

      if (accessToken == null || refreshToken == null) {
        throw const AppException(
          message: 'Invalid response from server: missing tokens.',
          code: 'ANON_ERROR',
        );
      }

      await SecureStorage.saveAccessToken(accessToken);
      await SecureStorage.saveRefreshToken(refreshToken);
      await _persistUser(user);

      return _mergeWithCache(user);
    } catch (e) {
      debugPrint('[AuthRepo] Anonymous sign in failed: $e');
      throw const AppException(
          message: 'Anonymous sign in failed', code: 'ANON_ERROR');
    }
  }
}
