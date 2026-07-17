import 'package:flutter/foundation.dart';
import '../crash_reporting/crash_reporting_service.dart';

class ObservabilityService {
  ObservabilityService._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await CrashReportingService.init();
      debugPrint('[Observability] ObservabilityService initialized successfully.');
    } catch (e) {
      debugPrint('[Observability] Initialization failed: $e');
    }
  }

  static void logInfo(String message, {String? tag}) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag != null ? '[$tag]' : '';
    debugPrint('{"time": "$timestamp", "level": "INFO", "tag": "$logTag", "message": "$message"}');
    CrashReportingService.log('INFO: $logTag $message');
  }

  static void logWarning(String message, {String? tag}) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag != null ? '[$tag]' : '';
    debugPrint('{"time": "$timestamp", "level": "WARN", "tag": "$logTag", "message": "$message"}');
    CrashReportingService.log('WARN: $logTag $message');
  }

  static void logError(dynamic error, StackTrace? stack, {String? message, String? tag}) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag != null ? '[$tag]' : '';
    debugPrint('{"time": "$timestamp", "level": "ERROR", "tag": "$logTag", "message": "${message ?? ''}", "error": "$error"}');
    
    CrashReportingService.recordError(error, stack, reason: message, fatal: false);
  }

  static void recordFatalError(dynamic error, StackTrace stack, {String? reason}) {
    logError(error, stack, message: 'FATAL: ${reason ?? ''}', tag: 'FATAL');
    CrashReportingService.recordError(error, stack, reason: reason, fatal: true);
  }
}
