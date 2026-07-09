import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  AppConfig._();

  static late SharedPreferences _prefs;

  // Runtime-resolved backend URL (set by health check)
  static String _resolvedBaseUrl = '';
  static bool _healthCheckDone = false;

  // Compile-time override via --dart-define=BACKEND_URL=http://...
  static const String _compileOverride = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: '',
  );

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration healthCheckTimeout = Duration(seconds: 5);
  static const int healthCheckRetries = 3;

  // Auto-detected API base URL
  static String get apiBaseUrl {
    if (_resolvedBaseUrl.isNotEmpty) return '$_resolvedBaseUrl/api';
    if (_compileOverride.isNotEmpty) return '$_compileOverride/api';
    return '${_getDefaultUrl()}/api';
  }

  // Raw backend host (for direct use)
  static String get backendHost => _resolvedBaseUrl.isNotEmpty
      ? _resolvedBaseUrl
      : _compileOverride.isNotEmpty
          ? _compileOverride
          : _getDefaultUrl();

  static const bool isProduction = !kDebugMode;
  static const String appName = 'Mental Mantra';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
  static const String packageName = 'com.mentalmantra.mental_mantra';

  // Feature flags
  static const bool enableAIChat = true;
  static const bool enablePremium = true;
  static const bool enableCommunity = false;

  /// Platform-appropriate default backend URL
  static String _getDefaultUrl() {
    if (isProduction) return '';

    if (kIsWeb) return 'http://localhost:3000';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://172.26.78.41:3000';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://localhost:3000';
    }
    return 'http://localhost:3000';
  }

  /// Candidate URLs to try for backend auto-discovery
  static List<String> get _candidateUrls {
    if (_compileOverride.isNotEmpty) {
      return [_compileOverride];
    }

    if (isProduction) {
      return [''];
    }

    if (kIsWeb) {
      const host = 'http://localhost:3000';
      return [host];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return [
        'http://172.26.78.41:3000',
        'http://10.0.2.2:3000',
        'http://10.0.3.2:3000',
        'http://localhost:3000',
      ];
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return [
        'http://localhost:3000',
        'http://127.0.0.1:3000',
      ];
    }

    return ['http://localhost:3000'];
  }

  /// Ping a single URL with a health check
  static Future<bool> _pingHealth(String url) async {
    try {
      final response = await http
          .get(Uri.parse('$url/api/health'))
          .timeout(healthCheckTimeout);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[Config] Health check failed for $url: $e');
      return false;
    }
  }

  /// Try all candidate URLs and return the first responsive one
  static Future<String> resolveBackendUrl() async {
    if (_compileOverride.isNotEmpty) {
      debugPrint('[Config] Using compile-time override: $_compileOverride');
      _resolvedBaseUrl = _compileOverride;
      _healthCheckDone = true;
      return _resolvedBaseUrl;
    }

    if (_healthCheckDone) return _resolvedBaseUrl;

    debugPrint('[Config] Auto-detecting backend URL...');
    for (final url in _candidateUrls) {
      debugPrint('[Config] Trying: $url');
      for (int attempt = 1; attempt <= healthCheckRetries; attempt++) {
        if (await _pingHealth(url)) {
          debugPrint('[Config] Backend resolved: $url (attempt $attempt)');
          _resolvedBaseUrl = url;
          _healthCheckDone = true;
          return url;
        }
        if (attempt < healthCheckRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }

    _resolvedBaseUrl = _candidateUrls.first;
    _healthCheckDone = false;
    debugPrint('[Config] No backend responded. Fallback: $_resolvedBaseUrl');
    return _resolvedBaseUrl;
  }

  /// Check if the backend is reachable (call before auth)
  static Future<bool> isBackendReachable() async {
    if (_healthCheckDone && _resolvedBaseUrl.isNotEmpty) return true;
    // Fire-and-forget in background, don't block
    resolveBackendUrl();
    return false;
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Don't block on health checks — resolve in background
    resolveBackendUrl();
  }

  static SharedPreferences get prefs => _prefs;

}
