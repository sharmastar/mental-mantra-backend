import 'dart:async';
import 'package:flutter/material.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() => _timer?.cancel();

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

class Throttler {
  final Duration interval;
  bool _canRun = true;

  Throttler({this.interval = const Duration(milliseconds: 500)});

  bool tryRun() {
    if (!_canRun) return false;
    _canRun = false;
    Future.delayed(interval, () => _canRun = true);
    return true;
  }

  void reset() => _canRun = true;
}
