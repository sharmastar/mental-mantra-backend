// lib/core/security/security_service.dart
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class DeviceIntegrityResult {
  final bool isRooted;
  final bool isEmulator;

  DeviceIntegrityResult({
    required this.isRooted,
    required this.isEmulator,
  });
}

class SecurityService {
  SecurityService._();
  static final SecurityService instance = SecurityService._();

  static const MethodChannel _channel =
      MethodChannel('com.mentalmantra.mental_mantra/security');

  /// Enable FLAG_SECURE on Android / prevent screenshots
  Future<bool> enableScreenshotProtection() async {
    if (kIsWeb) return false;
    try {
      final bool result =
          await _channel.invokeMethod('enableScreenshotProtection');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error enabling screenshot protection: ${e.message}');
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Disable FLAG_SECURE on Android / allow screenshots
  Future<bool> disableScreenshotProtection() async {
    if (kIsWeb) return false;
    try {
      final bool result =
          await _channel.invokeMethod('disableScreenshotProtection');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error disabling screenshot protection: ${e.message}');
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Performs device integrity checks (Root / Jailbreak & Emulator detection)
  Future<DeviceIntegrityResult> checkDeviceIntegrity() async {
    if (kIsWeb) {
      return DeviceIntegrityResult(isRooted: false, isEmulator: false);
    }
    try {
      final dynamic result = await _channel.invokeMethod('checkDeviceIntegrity');
      if (result is Map) {
        return DeviceIntegrityResult(
          isRooted: result['isRooted'] ?? false,
          isEmulator: result['isEmulator'] ?? false,
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Error checking device integrity: ${e.message}');
    } catch (e) {
      debugPrint('Unknown error checking device integrity: $e');
    }
    return DeviceIntegrityResult(isRooted: false, isEmulator: false);
  }
}
