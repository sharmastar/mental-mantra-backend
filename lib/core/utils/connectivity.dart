import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtil {
  ConnectivityUtil._();

  static final _connectivity = Connectivity();
  static bool _hasInternet = true;
  static DateTime _lastCheck = DateTime.now().subtract(const Duration(seconds: 31));
  static const Duration _cacheDuration = Duration(seconds: 30);

  static Future<bool> hasInternet() async {
    if (DateTime.now().difference(_lastCheck) < _cacheDuration) {
      return _hasInternet;
    }

    try {
      final results = await _connectivity.checkConnectivity();
      _hasInternet = results.any((r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet);

      if (_hasInternet) {
        try {
          final result = await InternetAddress.lookup('google.com')
              .timeout(const Duration(seconds: 3));
          _hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } catch (_) {
          _hasInternet = false;
        }
      }
    } catch (_) {
      _hasInternet = true;
    }

    _lastCheck = DateTime.now();
    return _hasInternet;
  }

  static Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
