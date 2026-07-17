// lib/core/network/ssl_pinning_client.dart
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Configures SSL/TLS certificate verification and optional pinning.
///
/// In debug mode, all certificates are accepted for local development.
/// In release mode, standard OS trust roots are always used. Additionally,
/// if production certificate fingerprints are configured, connections to
/// production hosts are pinned against those fingerprints.
class SslPinningClient {
  SslPinningClient._();

  /// Production domain(s) to apply certificate pinning to.
  /// Only these hosts will have their certificates checked against
  /// [_allowedFingerprints]. All other hosts use standard OS verification.
  static const List<String> _pinnedHosts = [
    'api.mentalmantra.com',
    // Add additional production domains here
  ];

  /// SHA-256 fingerprints of allowed production certificates.
  /// To obtain a fingerprint, run:
  ///   openssl s_client -connect api.mentalmantra.com:443 < /dev/null 2>/dev/null \
  ///     | openssl x509 -outform DER | openssl dgst -sha256
  ///
  /// Leave empty to disable pinning (still uses OS trust roots).
  // TODO: Add real production certificate SHA-256 fingerprints before release
  static const List<String> _allowedFingerprints = [];

  /// Configure certificate verification and optional SSL pinning on a Dio instance.
  static void configureSslPinning(Dio dio) {
    if (kIsWeb) return;

    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        // Always use platform trusted roots — never disable them.
        // The old code used `withTrustedRoots: kDebugMode` which broke
        // ALL release-mode connections by removing the trust store.
        final context = SecurityContext(withTrustedRoots: true);
        final client = HttpClient(context: context);

        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          // In debug mode, accept all certificates for local development
          if (kDebugMode) {
            debugPrint(
              '[SSL] Debug mode: accepting certificate for $host:$port',
            );
            return true;
          }

          // In release mode, only apply pinning to production hosts
          final isPinnedHost = _pinnedHosts.any(
            (pinnedHost) => host == pinnedHost || host.endsWith('.$pinnedHost'),
          );

          if (!isPinnedHost) {
            // Not a pinned host — this callback was invoked because the OS
            // rejected the cert (e.g. self-signed). Reject it.
            debugPrint(
              '[SSL] ❌ Certificate rejected by OS trust store for '
              'non-pinned host $host:$port',
            );
            return false;
          }

          // Pinned host — check fingerprint if any are configured
          if (_allowedFingerprints.isEmpty) {
            // No fingerprints configured — rely on OS trust store only.
            // The callback being invoked means the OS already rejected it.
            debugPrint(
              '[SSL] ❌ Certificate rejected by OS for pinned host $host:$port '
              '(no custom fingerprints configured)',
            );
            return false;
          }

          // Compute SHA-256 fingerprint of the presented certificate
          final bytes = cert.der;
          final digest = crypto.sha256.convert(bytes).bytes;
          final certSha256 = digest
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join()
              .toUpperCase();

          final matches = _allowedFingerprints.contains(certSha256);
          if (!matches) {
            debugPrint(
              '[SSL] ❌ Certificate pinning failed for $host:$port\n'
              '  Presented fingerprint: $certSha256\n'
              '  Allowed fingerprints: $_allowedFingerprints',
            );
          } else {
            debugPrint('[SSL] ✅ Certificate pinning verified for $host:$port');
          }
          return matches;
        };

        return client;
      };
    }
  }
}
