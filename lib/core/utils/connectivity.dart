import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtil {
  ConnectivityUtil._();

  static final _connectivity = Connectivity();
  static bool _hasInternet = true;
  static DateTime _lastCheck =
      DateTime.now().subtract(const Duration(seconds: 11));
  // Reduced from 30s to 10s for faster recovery after connectivity changes
  static const Duration _cacheDuration = Duration(seconds: 10);

  /// Mock override for testing
  static bool? overrideHasInternet;

  static Future<bool> hasInternet() async {
    if (overrideHasInternet != null) {
      return overrideHasInternet!;
    }
    if (DateTime.now().difference(_lastCheck) < _cacheDuration) {
      return _hasInternet;
    }

    try {
      final results = await _connectivity.checkConnectivity();
      _hasInternet = results.any((r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn);

      debugPrint(
        '[Connectivity] Network interfaces: '
        '${results.map((r) => r.name).join(', ')} → '
        '${_hasInternet ? "connected" : "disconnected"}',
      );

      if (_hasInternet) {
        try {
          if (kIsWeb) {
            // Web does not support InternetAddress.lookup, rely on connectivity status
          } else {
            final result = await InternetAddress.lookup('google.com')
                .timeout(const Duration(seconds: 3));
            _hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
            if (!_hasInternet) {
              debugPrint(
                '[Connectivity] DNS lookup succeeded but no address returned',
              );
            }
          }
        } catch (e) {
          debugPrint(
            '[Connectivity] DNS lookup failed (no real internet): $e',
          );
          _hasInternet = false;
        }
      }
    } catch (e) {
      // Fail closed: assume no internet on error to prevent
      // sending auth data over an unknown network
      debugPrint('[Connectivity] Check failed, assuming offline: $e');
      _hasInternet = false;
    }

    _lastCheck = DateTime.now();
    return _hasInternet;
  }

  /// Force refresh connectivity on next check (e.g. after network change)
  static void invalidateCache() {
    _lastCheck = DateTime.now().subtract(_cacheDuration * 2);
  }

  static Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
