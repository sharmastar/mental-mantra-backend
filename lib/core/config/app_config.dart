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

  // Callback when backend URL resolves dynamically
  static void Function(String)? onBackendUrlResolved;

  // Compile-time override via --dart-define=BACKEND_URL=http://...
  static const String _compileOverride = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: '',
  );

  // ── Timeouts ──────────────────────────────────────────────────────
  // Increased from 5s to accommodate mobile networks and bcrypt hashing.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration healthCheckTimeout = Duration(seconds: 3);
  static const int healthCheckRetries = 2;

  static bool _healthCheckCompleted = false;
  static bool get hasCompletedHealthCheck => _healthCheckCompleted;
  static bool get isBackendHealthy => _healthCheckDone;

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
    // Production: require explicit BACKEND_URL via --dart-define
    if (isProduction) {
      return 'https://api.mentalmantra.com';
    }

    if (kIsWeb) return 'http://localhost:3000';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
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
      return ['https://api.mentalmantra.com'];
    }

    if (kIsWeb) {
      const host = 'http://localhost:3000';
      return [host];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return [
        'http://10.0.2.2:3000', // Android emulator → host machine
        'http://10.0.3.2:3000', // Genymotion emulator → host machine
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
    for (int attempt = 0; attempt < healthCheckRetries; attempt++) {
      try {
        final response = await http
            .get(Uri.parse('$url/api/health'))
            .timeout(healthCheckTimeout);
        if (response.statusCode == 200) {
          debugPrint(
            '[Config] Health check passed for $url (attempt ${attempt + 1})',
          );
          return true;
        }
        debugPrint(
          '[Config] Health check returned ${response.statusCode} for $url',
        );
      } catch (e) {
        debugPrint(
          '[Config] Health check attempt ${attempt + 1}/$healthCheckRetries '
          'failed for $url: $e',
        );
      }
    }
    return false;
  }

  /// Try all candidate URLs and return the first responsive one
  static Future<String> resolveBackendUrl() async {
    if (_compileOverride.isNotEmpty) {
      debugPrint('[Config] Using compile-time override: $_compileOverride');
      _resolvedBaseUrl = _compileOverride;
      _healthCheckDone = true;
      _healthCheckCompleted = true;
      onBackendUrlResolved?.call(_resolvedBaseUrl);
      return _resolvedBaseUrl;
    }

    if (_healthCheckDone) return _resolvedBaseUrl;

    debugPrint('[Config] Auto-detecting backend URL concurrently...');
    debugPrint('[Config] Candidate URLs: $_candidateUrls');
    final completer = Completer<String>();

    // Overall timeout of 5 seconds (increased from 2s)
    Future.delayed(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        debugPrint('[Config] Backend URL resolution timed out after 5s');
        completer.complete('');
      }
    });

    int failedCount = 0;
    for (final url in _candidateUrls) {
      Future.microtask(() async {
        if (await _pingHealth(url)) {
          if (!completer.isCompleted) {
            debugPrint('[Config] ✅ Backend resolved: $url');
            completer.complete(url);
          }
        } else {
          failedCount++;
          if (failedCount == _candidateUrls.length && !completer.isCompleted) {
            completer.complete(''); // All failed
          }
        }
      });
    }

    final result = await completer.future;

    if (result.isNotEmpty) {
      _resolvedBaseUrl = result;
      _healthCheckDone = true;
    } else {
      _resolvedBaseUrl = _candidateUrls.first;
      _healthCheckDone = false;
      debugPrint(
        '[Config] ⚠️ No backend responded. Fallback: $_resolvedBaseUrl',
      );
    }

    _healthCheckCompleted = true;
    onBackendUrlResolved?.call(_resolvedBaseUrl);
    debugPrint('[Config] Final API base URL: $apiBaseUrl');
    return _resolvedBaseUrl;
  }

  /// Check if the backend is reachable (call before auth)
  static Future<bool> isBackendReachable() async {
    if (_healthCheckDone && _resolvedBaseUrl.isNotEmpty) return true;
    // Try resolving now — block briefly to give the best chance
    await resolveBackendUrl();
    return _healthCheckDone;
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // FIXED: Await resolveBackendUrl so ApiClient reads the correct URL.
    // Previously this was fire-and-forget, causing a race condition where
    // ApiClient.init() would read the default/production URL before
    // auto-discovery completed.
    await resolveBackendUrl();
  }

  static SharedPreferences get prefs => _prefs;
}
