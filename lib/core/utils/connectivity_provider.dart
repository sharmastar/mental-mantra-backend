import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();
  final controller = StreamController<bool>.broadcast();

  void emit(List<ConnectivityResult> results) {
    controller.add(results.any((r) => r != ConnectivityResult.none));
  }

  connectivity.onConnectivityChanged.listen(emit);
  connectivity.checkConnectivity().then(emit);

  ref.onDispose(() => controller.close());
  return controller.stream;
});
