// =============================================================================
// firebase_config.dart - Inicializacion Firebase por flavor
// -----------------------------------------------------------------------------
// Provee [FirebaseConfig.optionsFor(flavor)] que devuelve el `FirebaseOptions`
// adecuado para dev o prod.
//
// RECOMENDACION: cuando se configure FlutterFire CLI, este archivo puede ser
// reemplazado por `lib/firebase_options.dart` generado automaticamente. Lo
// mantenemos manualmente aqui para que el scaffold compile sin FlutterFire.
// =============================================================================

import 'package:firebase_core/firebase_core.dart';

import 'app_config.dart';

/// Configuracion de Firebase por flavor.
///
/// Los valores se leen via `--dart-define` para no commitear secretos.
/// Alternativamente, se puede usar `flutterfire configure` que genera
/// `firebase_options.dart` con los valores embebidos.
class FirebaseConfig {
  FirebaseConfig._(); // no instanciable

  /// Devuelve el `FirebaseOptions` para el flavor indicado.
  ///
  /// Ejecutar la app con:
  /// ```
  /// flutter run \
  ///   --flavor dev -t lib/main_dev.dart \
  ///   --dart-define=FIREBASE_API_KEY=... \
  ///   --dart-define=FIREBASE_APP_ID=... \
  ///   --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  ///   --dart-define=FIREBASE_PROJECT_ID=storyenglish-kids-dev \
  ///   --dart-define=FIREBASE_STORAGE_BUCKET=storyenglish-kids-dev.appspot.com
  /// ```
  static FirebaseOptions optionsFor({required String flavor}) {
    final isDev = flavor == 'dev';
    final projectId = String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue:
          isDev ? 'storyenglish-kids-dev' : 'storyenglish-kids-prod',
    );

    final apiKey = String.fromEnvironment(
      'FIREBASE_API_KEY',
      defaultValue: _placeholder(isDev, 'FIREBASE_API_KEY'),
    );
    final appId = String.fromEnvironment(
      'FIREBASE_APP_ID',
      defaultValue: _placeholder(isDev, 'FIREBASE_APP_ID'),
    );
    final messagingSenderId = String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: _placeholder(isDev, 'FIREBASE_MESSAGING_SENDER_ID'),
    );
    final storageBucket = String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue:
          isDev ? 'storyenglish-kids-dev.appspot.com' : 'storyenglish-kids-prod.appspot.com',
    );

    // Asumimos Android/iOS en el mismo proyecto Firebase.
    // Para plataformas adicionales (web, macos, windows) ver FirebaseOptions.platformSpecific.
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: storageBucket,
    );
  }

  /// Placeholder claro cuando falta una var de entorno (ayuda a detectar
  /// configuracion incompleta en lugar de crash mistico).
  static String _placeholder(bool isDev, String key) {
    if (AppConfig.isDev) {
      // En dev dejamos strings obvios para que se vea en logs.
      return 'MISSING_$key';
    }
    // En prod, lanzar tarde o temprano: Firebase rechazara credenciales vacias.
    return '';
  }
}
