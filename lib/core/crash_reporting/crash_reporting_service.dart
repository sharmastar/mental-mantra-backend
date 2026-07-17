// lib/core/crash_reporting/crash_reporting_service.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CrashReportingService {
  CrashReportingService._();

  static bool _initialized = false;
  static bool _firebaseReady = false;
  static bool _sentryReady = false;

  /// Initializes error capturing engines gracefully
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Check if Sentry is active
    _sentryReady = Sentry.isEnabled;

    try {
      // Firebase Crashlytics initialization check
      if (!kIsWeb) {
        _firebaseReady = true;
        // In dev or without firebase configured, this might throw. We wrap in try/catch.
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      }
      debugPrint('[CrashReporting] CrashReportingService initialized. (Sentry: $_sentryReady, Crashlytics: $_firebaseReady)');
    } catch (e) {
      _firebaseReady = false;
      debugPrint('[CrashReporting] Firebase Crashlytics could not initialize. Fallback to default logging. Error: $e');
    }
  }

  /// Records non-fatal errors
  static Future<void> recordError(
    dynamic error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    debugPrint('[CrashReporting] Error Recorded: $error');
    if (stack != null) {
      debugPrint(stack.toString());
    }

    if (_firebaseReady) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          reason: reason,
          fatal: fatal,
        );
      } catch (e) {
        debugPrint('[CrashReporting] Failed to record error on Firebase: $e');
      }
    }

    if (_sentryReady) {
      try {
        await Sentry.captureException(
          error,
          stackTrace: stack,
          withScope: (scope) {
            if (reason != null) {
              scope.setTag('reason', reason);
            }
            if (fatal) {
              scope.level = SentryLevel.fatal;
            }
          },
        );
      } catch (e) {
        debugPrint('[CrashReporting] Failed to record error on Sentry: $e');
      }
    }
  }

  /// Records log messages (breadcrumb)
  static void log(String message) {
    debugPrint('[CrashReportingLog] $message');
    if (_firebaseReady) {
      try {
        FirebaseCrashlytics.instance.log(message);
      } catch (_) {}
    }
    if (_sentryReady) {
      try {
        Sentry.addBreadcrumb(Breadcrumb(message: message));
      } catch (_) {}
    }
  }
}
