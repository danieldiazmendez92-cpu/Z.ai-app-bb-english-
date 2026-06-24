// =============================================================================
// analytics_service.dart - Wrapper de Firebase Analytics
// -----------------------------------------------------------------------------
// Servicio singleton que envuelve Firebase Analytics con una API tipada.
// Todos los eventos pasan por aqui para garantizar que se loggean con los
// params estandar (sin PII del nio - COPPA compliant).
// =============================================================================

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../utils/logger.dart';

/// Servicio de analytics.
///
/// IMPORTANTE COPPA: nunca loggear child_id real, nombre del nio, ni PII.
/// Si necesitas identificar al nio en analytics, usar un hash (ver
/// AnalyticsEvent.childIdHash en docs/03-data-models.md).
class AnalyticsService {
  AnalyticsService._() : _analytics = FirebaseAnalytics.instance;

  static final AnalyticsService instance = AnalyticsService._();
  final FirebaseAnalytics _analytics;
  bool _initialized = false;

  /// Inicializa el servicio. Debe llamarse en `initializeApp`.
  Future<void> init() async {
    if (_initialized) return;
    // En dev, deshabilitamos analytics para no contaminar los reportes.
    await _analytics.setAnalyticsCollectionEnabled(AppConfig.isProd);
    _initialized = true;
    AppLogger.info('AnalyticsService.init: collectionEnabled=${AppConfig.isProd}');
  }

  /// Loggea un evento con nombre y params tipados.
  ///
  /// [eventName] - max 40 chars, sin espacios, empieza con letra.
  /// [params] - max 25 params, valores String/long/double (no List ni Map).
  Future<void> logEvent({
    required String eventName,
    Map<String, Object>? params,
  }) async {
    if (!_initialized || !AppConfig.isProd) {
      // En dev solo loggeamos a consola.
      AppLogger.debug('analytics.event: $eventName params=$params');
      return;
    }
    try {
      await _analytics.logEvent(name: eventName, parameters: params);
    } catch (e, st) {
      AppLogger.error('AnalyticsService.logEvent($eventName) error', e, st);
    }
  }

  /// Identifica al usuario padre (NO al nio) en analytics.
  /// Llamar al hacer login.
  Future<void> setUserId(String? userUid) async {
    try {
      await _analytics.setUserId(id: userUid);
    } catch (e, st) {
      AppLogger.error('AnalyticsService.setUserId error', e, st);
    }
  }

  /// Marca propiedad de usuario (ej: 'premium' = 'true').
  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e, st) {
      AppLogger.error('AnalyticsService.setUserProperty($name) error', e, st);
    }
  }

  /// Loggea screen view (llamado desde GoRouter observer).
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_initialized) return;
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e, st) {
      AppLogger.error('AnalyticsService.logScreenView($screenName) error', e, st);
    }
  }

  // ---- Eventos predefinidos (mantener nombres estables) ----

  Future<void> logSignUp({required String method}) =>
      logEvent(eventName: 'sign_up', params: {'method': method});

  Future<void> logLogin({required String method}) =>
      logEvent(eventName: 'login', params: {'method': method});

  Future<void> logStoryStarted({required String storyIdHash}) =>
      logEvent(eventName: 'story_started', params: {'story_id_hash': storyIdHash});

  Future<void> logStoryCompleted({required String storyIdHash}) =>
      logEvent(eventName: 'story_completed', params: {'story_id_hash': storyIdHash});

  Future<void> logSubscriptionStarted({
    required String plan,
    required String platform,
  }) =>
      logEvent(eventName: 'subscription_started', params: {
        'plan': plan,
        'platform': platform,
      });

  Future<void> logAchievementUnlocked({required String achievementId}) =>
      logEvent(eventName: 'achievement_unlocked', params: {
        'achievement_id': achievementId,
      });
}

/// Provider de Riverpod para `AnalyticsService`.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService.instance;
});
