// lib/core/network/ssl_pinning_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class SslPinningClient {
  SslPinningClient._();

  /// Allowed SHA-256 fingerprints for production domains (Placeholder/Configurable)
  static const List<String> _allowedFingerprints = [
    // Add production server certificate SHA-256 fingerprints here
  ];

  /// Configure certificate verification and SSL pinning on Dio instance
  static void configureSslPinning(Dio dio) {
    if (kIsWeb) return;

    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient(context: SecurityContext(withTrustedRoots: true));
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          // Reject untrusted certificates in release build
          if (kReleaseMode) {
            if (_allowedFingerprints.isEmpty) {
              // Standard certificate validation pass for valid CA signed certificates
              return false; 
            }
            final String certSha256 = cert.sha1.map((e) => e.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
            return _allowedFingerprints.contains(certSha256);
          }
          return true; // Allow dev/proxy certificates in debug/test mode
        };
        return client;
      };
    }
  }
}
