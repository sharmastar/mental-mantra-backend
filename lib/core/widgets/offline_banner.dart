import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/connectivity_provider.dart';

class OfflineBanner extends ConsumerStatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityProvider);
    final isOnline = connectivity.valueOrNull ?? true;

    // Auto-reset dismissed flag when back online so banner reappears next disconnect
    if (isOnline && _dismissed) {
      _dismissed = false;
    }

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isOnline || _dismissed
              ? const SizedBox.shrink()
              : MaterialBanner(
                  key: const ValueKey('offline'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: Colors.orange.shade800,
                  content: const Text(
                    'You are offline. Some features may be unavailable.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => setState(() => _dismissed = true),
                      child: const Text('Dismiss',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
