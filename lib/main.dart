import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/providers.dart';
import 'core/services/notification_service.dart';
import 'core/services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration Firebase
  await Firebase.initializeApp();
  
  // Configuration Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN'; // À configurer
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(const ProviderScope(child: DangRApp())),
  );
}

class DangRApp extends ConsumerStatefulWidget {
  const DangRApp({super.key});

  @override
  ConsumerState<DangRApp> createState() => _DangRAppState();
}

class _DangRAppState extends ConsumerState<DangRApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialiser les services
    await ref.read(notificationServiceProvider.notifier).initialize();
    await ref.read(locationServiceProvider.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'DangR',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
