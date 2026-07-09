import 'dart:async';
import 'package:flutter/material.dart';

class DebounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration debounceDelay;
  final bool absorptive;

  const DebounceButton({
    super.key,
    required this.child,
    this.onTap,
    this.debounceDelay = const Duration(milliseconds: 500),
    this.absorptive = true,
  });

  @override
  State<DebounceButton> createState() => _DebounceButtonState();
}

class _DebounceButtonState extends State<DebounceButton> {
  bool _isProcessing = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (_isProcessing || widget.onTap == null) return;
    _timer?.cancel();
    setState(() => _isProcessing = true);
    widget.onTap!();
    _timer = Timer(widget.debounceDelay, () {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: widget.absorptive ? HitTestBehavior.opaque : HitTestBehavior.translucent,
        child: Opacity(
          opacity: _isProcessing ? 0.6 : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}
