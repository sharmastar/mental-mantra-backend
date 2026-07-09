import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/notification_service.dart';
import 'core/storage/secure_storage.dart';
import 'core/storage/hive_storage.dart';
import 'core/security/session_timeout_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await HiveStorage.init();
  } catch (e) {
    debugPrint('[Main] Hive init error: $e');
  }

  try {
    await SecureStorage.init();
  } catch (e) {
    debugPrint('[Main] SecureStorage init error: $e');
  }

  try {
    await AppConfig.init();
  } catch (e) {
    debugPrint('[Main] AppConfig init error: $e');
  }

  try {
    ApiClient.init();
  } catch (e) {
    debugPrint('[Main] ApiClient init error: $e');
  }

  runApp(const ProviderScope(child: MentalMantraApp()));

  _initBackgroundServices();
}

Future<void> _initBackgroundServices() async {
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('[Main] NotificationService init error: $e');
  }
}

class MentalMantraApp extends ConsumerWidget {
  const MentalMantraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Mental Mantra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
            ),
          ),
          child: SessionTimeoutWrapper(child: child!),
        );
      },
    );
  }
}
