import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../../../core/errors/app_exceptions.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final String? errorCode;
  final bool isOnboarded;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.errorCode,
    this.isOnboarded = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    String? errorCode,
    bool? isOnboarded,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  bool _initialized = false;

  AuthNotifier(this._repository) : super(const AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final user = await _repository.restoreSession();
      state = AuthState(
        user: user,
        isOnboarded: user?.onboardingCompleted ?? false,
        isLoading: false,
      );
    } catch (_) {
      state = const AuthState(isLoading: false);
    }
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signUpWithEmail(
        name: name, email: email, password: password,
      );
      state = AuthState(user: user, isOnboarded: user.onboardingCompleted);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false, errorMessage: e.message, errorCode: e.code,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred: $e',
        errorCode: 'UNKNOWN',
      );
      return false;
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signInWithEmail(
        email: email, password: password, rememberMe: rememberMe,
      );
      state = AuthState(user: user, isOnboarded: user.onboardingCompleted);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false, errorMessage: e.message, errorCode: e.code,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred: $e',
        errorCode: 'UNKNOWN',
      );
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signInAnonymously();
      state = AuthState(user: user, isOnboarded: user.onboardingCompleted);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message, errorCode: e.code);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Anonymous sign-in failed.', errorCode: 'UNKNOWN');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signInWithGoogle();
      state = AuthState(user: user, isOnboarded: user.onboardingCompleted);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false, errorMessage: e.message, errorCode: e.code,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google Sign-In failed: $e',
        errorCode: 'UNKNOWN',
      );
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false, errorMessage: e.message, errorCode: e.code,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send reset email. Please try again.',
        errorCode: 'UNKNOWN',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sign out failed. Please try again.',
        errorCode: 'SIGN_OUT_FAILED',
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.deleteAccount();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Account deletion failed. Please try again.',
        errorCode: 'DELETE_FAILED',
      );
    }
  }

  Future<void> markOnboardingComplete(Map<String, dynamic> data) async {
    try {
      await _repository.markOnboardingComplete(data);
      final updatedUser = state.user?.copyWith(
        onboardingCompleted: true,
        nickname: data['nickname'] as String?,
        gender: data['gender'] as String?,
        country: data['country'] as String?,
        relationshipStatus: data['relationship_status'] as String?,
        livingSituation: data['living_situation'] as String?,
        occupation: data['occupation'] as String?,
        ageGroup: data['age_group'] as String?,
      );
      state = state.copyWith(user: updatedUser, isOnboarded: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save onboarding data.',
        errorCode: 'ONBOARDING_FAILED',
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final user = await _repository.updateProfile(updates);
      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update profile.',
        errorCode: 'PROFILE_UPDATE_FAILED',
      );
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    final success = await _repository.verifyOtp(email: email, otp: otp);
    if (!success) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'OTP verification failed.',
        errorCode: 'OTP_VERIFICATION_FAILED',
      );
    }
    return success;
  }


  Future<bool> resendOtp(String email) async {
    final success = await _repository.resendOtp(email);
    if (!success) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'OTP resend failed.',
        errorCode: 'OTP_RESEND_FAILED',
      );
    }
    return success;
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});
