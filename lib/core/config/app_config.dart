// =============================================================================
// app_config.dart - Configuracion por flavor (dev / prod)
// -----------------------------------------------------------------------------
// Define AppConfig que guarda en memoria el flavor activo y expone helpers
// `isDev`, `isProd`, `appName`, `version`. Tambien sirve como punto central
// para variables de entorno que se leen via --dart-define o String.fromEnvironment.
// =============================================================================

/// Flavor de la app. Define que Firebase project y que endpoints usar.
enum AppFlavor {
  /// Desarrollo - Firebase project dev, datos de prueba.
  dev,

  /// Produccion - Firebase project prod, datos reales.
  prod,
}

/// Configuracion global de la app.
///
/// Se inicializa desde `main_dev.dart` / `main_prod.dart` llamando a
/// [AppConfig.init] antes de `runApp`. Despues de eso, cualquier parte de la
/// app puede leer [AppConfig.flavor], [AppConfig.isDev], etc.
class AppConfig {
  AppConfig._(); // no instanciable

  static late final AppFlavor _flavor;
  static late final String _appName;
  static late final String _version;

  /// Inicializa la config. Debe llamarse una sola vez en `initializeApp`.
  static void init({required String flavor}) {
    _flavor = switch (flavor) {
      'dev' => AppFlavor.dev,
      'prod' => AppFlavor.prod,
      _ => throw ArgumentError.value(
          flavor, 'flavor', 'Flavor no soportado. Use "dev" o "prod".'),
    };
    _appName = _readDartDefine('APP_NAME',
        defaultValue: _flavor == AppFlavor.dev
            ? 'StoryEnglish Kids (Dev)'
            : 'StoryEnglish Kids');
    _version = _readDartDefine('APP_VERSION', defaultValue: '0.1.0');
  }

  /// Flavor activo.
  static AppFlavor get flavor => _flavor;

  /// `true` si estamos en dev.
  static bool get isDev => _flavor == AppFlavor.dev;

  /// `true` si estamos en prod.
  static bool get isProd => _flavor == AppFlavor.prod;

  /// Nombre visible de la app (para `MaterialApp.title`).
  static String get appName => _appName;

  /// Version de la app (formato semver `MAJOR.MINOR.PATCH`).
  static String get version => _version;

  /// URL base para Cloud Functions (region us-central1 por defecto).
  /// En prod se recomienda region cercana al usuario (ej: us-east1).
  static String get functionsBaseUrl {
    const region = String.fromEnvironment(
      'FUNCTIONS_REGION',
      defaultValue: 'us-central1',
    );
    final projectId = String.fromEnvironment('FIREBASE_PROJECT_ID',
        defaultValue: AppConfig.isDev
            ? 'storyenglish-kids-dev'
            : 'storyenglish-kids-prod');
    return 'https://$region-$projectId.cloudfunctions.net';
  }

  /// Lee una variable de entorno pasada via `--dart-define=KEY=value`.
  static String _readDartDefine(String key, {required String defaultValue}) {
    return String.fromEnvironment(key, defaultValue: defaultValue);
  }
}
