import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:isar/isar.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/providers.dart';
import 'core/services/notification_service.dart';
import 'core/services/location_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/hazard_service.dart';
import 'core/models/hazard.dart';
import 'core/config/app_config.dart';
import 'core/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
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
    // Initialize services
    await ref.read(notificationServiceProvider.notifier).initialize();
    await ref.read(locationServiceProvider.notifier).initialize();
    await ref.read(authServiceProvider.notifier).initialize();
    await ref.read(hazardServiceProvider.notifier).initialize();
    
    // Load saved locale
    await ref.read(localeNotifierProvider.notifier).loadSavedLocale();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'DangR',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: appRouter,
      textScaler: const TextScaler.linear(1.0),
    );
  }
}
