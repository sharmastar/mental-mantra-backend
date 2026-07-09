import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/connectivity_provider.dart';

class OfflineBanner extends ConsumerWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final isOnline = connectivity.valueOrNull ?? true;

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isOnline
              ? const SizedBox.shrink()
              : MaterialBanner(
                  key: const ValueKey('offline'),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: Colors.orange.shade800,
                  content: const Text(
                    'You are offline. Some features may be unavailable.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Dismiss', style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
