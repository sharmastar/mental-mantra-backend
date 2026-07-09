// lib/core/security/biometric_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometric hardware and enrollment are available on device
  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false;
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Biometric availability check failed: ${e.message}');
      return false;
    }
  }

  /// Get list of enrolled biometric types (e.g. fingerprint, face)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return [];
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('Error fetching available biometrics: ${e.message}');
      return [];
    }
  }

  /// Prompt user for biometric verification
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to access Mental Mantra',
  }) async {
    if (kIsWeb) return true;
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        debugPrint('Biometrics not available on device');
      } else if (e.code == auth_error.notEnrolled) {
        debugPrint('No biometrics enrolled on device');
      } else if (e.code == auth_error.lockedOut ||
                 e.code == auth_error.permanentlyLockedOut) {
        debugPrint('Biometrics locked out');
      } else {
        debugPrint('Biometric auth error: ${e.message}');
      }
      return false;
    }
  }
}
