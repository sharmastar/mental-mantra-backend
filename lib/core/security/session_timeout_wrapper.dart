// lib/core/security/session_timeout_wrapper.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/security/biometric_service.dart';
import 'package:mental_mantra/core/storage/secure_storage.dart';

class SessionTimeoutWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const SessionTimeoutWrapper({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 15),
  });

  @override
  ConsumerState<SessionTimeoutWrapper> createState() => _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends ConsumerState<SessionTimeoutWrapper> {
  Timer? _timer;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeoutDuration, _onTimeout);
  }

  void _resetTimer() {
    if (_isLocked) return;
    _startTimer();
  }

  Future<void> _onTimeout() async {
    final isBioEnabled = await SecureStorage.isBiometricEnabled();
    if (!isBioEnabled) return;

    setState(() {
      _isLocked = true;
    });

    final authenticated = await BiometricService.instance.authenticate(
      localizedReason: 'Session timed out due to inactivity. Please authenticate.',
    );

    if (authenticated) {
      setState(() {
        _isLocked = false;
      });
      _startTimer();
    } else {
      // Keep locked until authenticated or user decides to authenticate again
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      child: Stack(
        children: [
          widget.child,
          if (_isLocked)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.95),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 72,
                        color: Color(0xFF6C63FF),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Session Locked',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Mental Mantra was locked due to inactivity.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          final authenticated = await BiometricService.instance.authenticate(
                            localizedReason: 'Unlock Mental Mantra',
                          );
                          if (authenticated) {
                            setState(() {
                              _isLocked = false;
                            });
                            _startTimer();
                          }
                        },
                        icon: const Icon(Icons.fingerprint, color: Colors.white),
                        label: const Text(
                          'Unlock App',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
