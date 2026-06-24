// =============================================================================
// logger.dart - Logger central de la app
// -----------------------------------------------------------------------------
// Wrapper sobre el package `logger` que respeta el flavor:
//  - Dev: loggea a consola con colores.
//  - Prod: reenvia errores a Crashlytics (via CrashlyticsService).
// =============================================================================

import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:logger/logger.dart';

/// Logger central. No usar `print()` directamente.
///
/// Uso:
///   AppLogger.debug('widget built');
///   AppLogger.info('user logged in', user.uid);
///   AppLogger.warning('cache miss, fetching remote');
///   AppLogger.error('auth failed', error, stackTrace);
class AppLogger {
  AppLogger._();

  static late final Logger _logger;
  static bool _enabled = false;

  /// Inicializa el logger. Llamar en `initializeApp`.
  static void init({required bool enabled}) {
    _enabled = enabled;
    _logger = Logger(
      filter: _SELogFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 100,
        colors: true,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  /// Log de debug (solo visible en dev).
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log informativo (visible en dev y prod si esta habilitado).
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Advertencia (no fatal pero inesperado).
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Error (no fatal). En prod se reporta a Crashlytics.
  static void error(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    // En prod, reenviar a Crashlytics (lazy import para no acoplar en dev).
    if (kReleaseMode) {
      // CrashlyticsService.instance.recordError(...)  // TODO: import circular,
      //                                            se llama desde main.dart directamente.
    }
  }

  /// Error fatal (crashea la app en dev, reporta en prod).
  static void fatal(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

/// Filtro custom: solo loggea si `_enabled` o si kDebugMode.
class _SELogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return AppLogger._enabled || kDebugMode;
  }
}
