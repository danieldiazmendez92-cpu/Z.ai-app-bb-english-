// =============================================================================
// crashlytics_service.dart - Wrapper de Firebase Crashlytics
// -----------------------------------------------------------------------------
// Servicio singleton que envuelve Firebase Crashlytics.
// Permite loggear errores no fatales con contexto, setear user uid, y dejar
// "breadcrumbs" para depuracion post-mortem.
// =============================================================================

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../utils/logger.dart';

/// Servicio de Crashlytics.
class CrashlyticsService {
  CrashlyticsService._() : _crashlytics = FirebaseCrashlytics.instance;

  static final CrashlyticsService instance = CrashlyticsService._();
  final FirebaseCrashlytics _crashlytics;
  bool _initialized = false;

  /// Inicializa el servicio. Debe llamarse en `initializeApp`.
  Future<void> init() async {
    if (_initialized) return;
    // En dev deshabilitamos crashlytics para no ruidar el dashboard.
    await _crashlytics.setCrashlyticsCollectionEnabled(AppConfig.isProd);
    _initialized = true;
    AppLogger.info('CrashlyticsService.init: collectionEnabled=${AppConfig.isProd}');
  }

  /// Identifica al usuario padre (no al nio) en crashlytics.
  Future<void> setUserIdentifier(String? userUid) async {
    try {
      if (userUid != null) {
        await _crashlytics.setUserIdentifier(userUid);
      } else {
        await _crashlytics.setUserIdentifier('');
      }
    } catch (e, st) {
      AppLogger.error('CrashlyticsService.setUserIdentifier error', e, st);
    }
  }

  /// Marca un key/value custom (ej: 'active_child_id_hash' = '...').
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _crashlytics.setCustomKey(key, value.toString());
    } catch (e, st) {
      AppLogger.error('CrashlyticsService.setCustomKey($key) error', e, st);
    }
  }

  /// Loggea un error NO fatal (no crashea la app).
  ///
  /// [reason] - mensaje corto para identificar el contexto (ej: 'auth login flow').
  /// [fatal] - si true, se reporta como crash fatal (no termina la app, solo reporta).
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!_initialized || !AppConfig.isProd) {
      AppLogger.error('crashlytics.recordError: $reason', error, stackTrace);
      return;
    }
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e, st) {
      AppLogger.error('CrashlyticsService.recordError error', e, st);
    }
  }

  /// Loggea un breadcrumb (mensaje corto) que aparece en el reporte de crash.
  /// Util para trazas tipo 'login_button_tapped', 'audio_loaded'.
  Future<void> log(String message) async {
    if (!_initialized) return;
    try {
      await _crashlytics.log(message);
    } catch (e, st) {
      AppLogger.error('CrashlyticsService.log error', e, st);
    }
  }

  /// Fuerza un crash de prueba (solo dev). Util para verificar integracion.
  Future<void> crash() async {
    if (!AppConfig.isDev) {
      throw StateError('CrashlyticsService.crash() solo permitido en dev.');
    }
    await _crashlytics.crash();
  }
}

/// Provider de Riverpod para `CrashlyticsService`.
final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  return CrashlyticsService.instance;
});
