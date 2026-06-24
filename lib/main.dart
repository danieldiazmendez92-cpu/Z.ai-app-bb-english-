// =============================================================================
// main.dart - Entry point comun para StoryEnglish Kids
// -----------------------------------------------------------------------------
// No se ejecuta directamente. Los entry points reales son:
//   - main_dev.dart  (Firebase dev project, flavor dev)
//   - main_prod.dart (Firebase prod project, flavor prod)
//
// Ambos llaman a `initializeApp(flavor: ...)` y luego a `runApp(StoryEnglishApp())`.
// =============================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/firebase_config.dart';
import 'core/config/theme.dart';
import 'core/router/app_router.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/utils/logger.dart';

/// Inicializacion comun a todos los flavors.
///
/// [flavor] - 'dev' | 'prod' (define AppConfig.currentFlavor).
///
/// Orden:
///  1. WidgetsFlutterBinding (necesario antes de cualquier plugin).
///  2. AppConfig (lee --dart-define / env vars segun flavor).
///  3. Hive (cache local).
///  4. Firebase (auth, firestore, crashlytics, analytics).
///  5. Crashlytics y Analytics singletons.
///  6. Logger.
Future<void> initializeApp({required String flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Configuracion por flavor (lee --dart-define si los hubiera).
  AppConfig.init(flavor: flavor);

  // 2) Cache local con Hive.
  await Hive.initFlutter();

  // 3) Firebase - el options se resuelve segun flavor en FirebaseConfig.
  final firebaseOptions = FirebaseConfig.optionsFor(flavor: flavor);
  await Firebase.initializeApp(options: firebaseOptions);

  // 4) Crashlytics - captura errores no atrapados en zona de Flutter y en async.
  final crashlytics = FirebaseCrashlytics.instance;
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  // 5) Servicios singleton (analytics, crashlytics wrappers).
  await AnalyticsService.instance.init();
  await CrashlyticsService.instance.init();

  // 6) Logger (solo loggea en debug; en prod va a Crashlytics).
  AppLogger.init(enabled: kDebugMode);
}

/// Widget raiz de la app.
///
/// Se construye despues de [initializeApp]. Usa:
///  - `ProviderScope` de Riverpod para todo el arbol.
///  - `MaterialApp.router` con GoRouter configurado en [appRouter].
///  - Tema lúdico para nios definido en [AppTheme].
class StoryEnglishApp extends ConsumerWidget {
  const StoryEnglishApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'StoryEnglish Kids',
      debugShowCheckedModeBanner: AppConfig.isDev,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // MVP solo light; los nios no usan dark mode
      routerConfig: router,
    );
  }
}
